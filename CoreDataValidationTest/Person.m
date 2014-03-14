//
//  Person.m
//  CoreDataValidationTest
//
//  Created by Murray Sagal on 1/18/2014.
//  Copyright (c) 2014 Murray Sagal. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic firstName;
@dynamic lastName;

-(NSDictionary *)privateValidationPredicates { // used in case the model does not define limits
    return @{@"firstName"   : @[[NSPredicate predicateWithFormat:@"length >= 2"],[NSPredicate predicateWithFormat:@"length <= 10"]],
             @"lastName"    : @[[NSPredicate predicateWithFormat:@"length >= 2"],[NSPredicate predicateWithFormat:@"length <= 10"]],
             @"someNumber"  : @[[NSPredicate predicateWithFormat:@"self >= 2"],[NSPredicate predicateWithFormat:@"self <= 10"]]};
}

-(BOOL)validateValue:(__autoreleasing id *)value forKey:(NSString *)key error:(NSError *__autoreleasing *)outError {
    NSString *errorMessage;
    NSInteger code;
    BOOL isValid;
    NSAttributeDescription *mad = [[[self entity] propertiesByName] valueForKey:key]; // refractor and don't shorten My Attribute Description ;)
    if (NO == [mad isOptional] && nil == *value) {
        // raise error because values must not be nil
        errorMessage = NSLocalizedStringFromTableInBundle(@"fw_val_expectedNoNil", @"fwLocalizedStrings" , [NSBundle mainBundle], @"did not expected a nil value" );
        code = 100;
        isValid = NO;
    } else {
        switch ([mad attributeType]) {
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType:
            case NSDoubleAttributeType:
            case NSFloatAttributeType:
            case NSBooleanAttributeType:
                isValid = [*value isKindOfClass:[NSNumber class]];
                if (NO == isValid) { // not a NSNumber
                    errorMessage = NSLocalizedStringFromTableInBundle(@"fw_val_expectedNSNumber", @"fwLocalizedStrings" , [NSBundle mainBundle], @"expected a number here" );
                    code = 101;
//                    code = NSValidation StringTooShortError
                } else { // validate NSNumber against any limit set in the model
                    for (NSPredicate* predicate in [mad validationPredicates]) {
                        NSString *predString =[predicate predicateFormat];
                        isValid = [predicate evaluateWithObject:*value];
                        NSArray *splitString = [predString componentsSeparatedByString:@" "];
                        NSString *expectedLimit = [splitString lastObject];
                        BOOL shouldBeBigger = ([predString rangeOfString:@">"].length > 0);
                        NSLog(@"Firstname: %@, predicate: %@, match :%d, shouldBeBigger: %d ",*value,[predicate predicateFormat], isValid, shouldBeBigger);
                        if (NO == isValid) {
                            if (shouldBeBigger) {
                             code = NSValidationNumberTooLargeError;
                                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"fw_val_NumberToBig", @"fwLocalizedStrings" , [NSBundle mainBundle], @"<key> must be at least <expectedLimit>" ), key, expectedLimit];
                            } else {
                                code = NSValidationNumberTooSmallError;
                                errorMessage =  [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"fw_val_NumberToSmall", @"fwLocalizedStrings" , [NSBundle mainBundle], @"<key> can't be more than <expectedLimit>" ), key, expectedLimit];
                            }
                        }
                    }
                }
                break;
                
            case NSStringAttributeType:
                isValid = [*value isKindOfClass:[NSString class]];
                if (NO == isValid) { // not a NSString
                    errorMessage = NSLocalizedStringFromTableInBundle(@"fw_val_expectedNSString", @"fwLocalizedStrings" , [NSBundle mainBundle], @"expected a string here" );
                    code = 101;
                } else { // validate NSString
                    NSArray *validationPredicatesToUse;
                    if ([[mad validationPredicates] count] == 0) { // no limits have been set in the model, lets get our own. Defined above
                        validationPredicatesToUse = [self privateValidationPredicates][key];
                    } else { // obtain the limits as set in the model
                        validationPredicatesToUse = [mad validationPredicates];
                    }
                    
                    for (NSPredicate* predicate in validationPredicatesToUse) {
                        isValid = [predicate evaluateWithObject:*value]; // do the validation
                        NSString *predString =[predicate predicateFormat];
                        BOOL shouldBeLonger = ([predString rangeOfString:@">"].length > 0); // find out if is lower or upper limit
                        NSArray *splitString = [predString componentsSeparatedByString:@" "];
                        NSString *expectedLimit = [splitString lastObject]; // get limiting value i.e. from "length >= 2" get the two.
                        NSLog(@"Firstname: %@, predicate: %@, isValid :%d, isBigger: %d, limit: %@ ",*value,[predicate predicateFormat], isValid, shouldBeLonger, expectedLimit);
                        if (NO == isValid) {
                            if (shouldBeLonger) {
                                code = NSValidationStringPatternMatchingError;
                                errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"fw_val_StringMustBeAtLeast", @"fwLocalizedStrings" , [NSBundle mainBundle], @"<key> must be at least <expectedLimit> characters" ), key, expectedLimit];
                            } else {
                                code = NSValidationStringTooShortError;
                                errorMessage = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"fw_val_StringCantBeMore", @"fwLocalizedStrings" , [NSBundle mainBundle], @"<key> can't be more than <expectedLimit> characters" ), key, expectedLimit];
                            }
                            break; // this is not a switch break. We want to break out of the For..in loop
#warning validation is not covering for NSValidationStringPatternMatchingError
                        }
                    }
                }
                
                
               break; // this is switch break
            case NSDateAttributeType:
                isValid = [*value isKindOfClass:[NSDate class]];
                break;
            case NSDecimalAttributeType:
                isValid = [*value isKindOfClass:[NSDecimalNumber class]];
                break;
                
            default:
                //NSUndefinedAttributeType, NSBinaryDataAttributeType, NSTransformableAttributeType, NSObjectIDAttributeType
                isValid = NO;
                break;
        }
    }
    if (outError && errorMessage) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
        NSError *error = [[NSError alloc] initWithDomain:@"test"
                                                    code:code
                                                userInfo:userInfo];
        *outError = error;
    }
    
    return isValid;
}

- (BOOL)validateFirstName:(id *)ioValue error:(NSError **)outError {
    NSLog(@"[<%@ %p> %@ line= %d] *ioValue= %@", [self class], self, NSStringFromSelector(_cmd), __LINE__, *ioValue);
    NSLog(@"[<%@ %p> %@ line= %d] *outError= %@", [self class], self, NSStringFromSelector(_cmd), __LINE__, *outError);
    return YES;
    // firstName's validation is not specified in the model editor, it's specified here.
    // field width: min 2, max 10
#warning validateFirstName has been commented
//    BOOL isValid = YES;
//    NSString *firstName = *ioValue;
//    NSString *errorMessage;
//    NSInteger code;
//    
//    if (firstName.length < 2) {
//        
//        errorMessage = @"First Name must be at least 2 characters.";
//        code = NSValidationStringTooShortError;
//        isValid = NO;
//        
//    } else if (firstName.length > 10) {
//        
//        errorMessage = @"First Name can't be more than 10 characters.";
//        code = NSValidationStringTooLongError;
//        isValid = NO;
//        
//    }
//    
//    if (outError && errorMessage) {
//        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorMessage };
//        NSError *error = [[NSError alloc] initWithDomain:@"test"
//                                                    code:code
//                                                userInfo:userInfo];
//        *outError = error;
//    }
//    
//    return isValid;
    
}

- (BOOL)validateLastName:(id *)ioValue error:(NSError **)outError {
    
    // lastName's validation is specified in the Core Data model.
    // This method is implemented minimally just to allow inspection of ioValue and outError.
    // It seems no error object is provided at this point, even when lastName is invalid.
    
    NSLog(@"[<%@ %p> %@ line= %d] *ioValue= %@", [self class], self, NSStringFromSelector(_cmd), __LINE__, *ioValue);
    NSLog(@"[<%@ %p> %@ line= %d] *outError= %@", [self class], self, NSStringFromSelector(_cmd), __LINE__, *outError);

    
    // Weird behaviour here not really related to the problem. If lastName is valid the value
    // returned to the view controller is whatever is returned here. If it's invalid it's always
    // NO even if YES is returned here. That seems like a missed condition in Core Data's validation.
    // Maybe there's a reason it would pass through in the case of valid but I can't think of a
    // use case for that.
    
//    return NO;
    return YES;
    
}

@end

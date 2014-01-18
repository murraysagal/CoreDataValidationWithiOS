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


- (BOOL)validateFirstName:(id *)ioValue error:(NSError **)outError {
    
    // firstName's validation is not specified in the model editor, it's specified here.
    // field width: min 2, max 10
    
    BOOL isValid = YES;
    NSString *firstName = *ioValue;
    NSString *errorMessage;
    NSInteger code;
    
    if (firstName.length < 2) {
        
        errorMessage = @"First Name must be at least 2 characters.";
        code = NSValidationStringTooShortError;
        isValid = NO;
        
    } else if (firstName.length > 10) {
        
        errorMessage = @"First Name can't be more than 10 characters.";
        code = NSValidationStringTooLongError;
        isValid = NO;
        
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

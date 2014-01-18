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


- (BOOL)validateFirstName:(id *)ioValue error:(NSError **)outError
{
    // firstName has no validation set in the model editor, it's all managed here.
    // field width: min 2, max 10
    
    BOOL isValid = YES;
    NSString *firstName = *ioValue;
    NSLog(@"firstName= %@", firstName);
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

@end

//
//  SSViewController.m
//  CoreDataValidationTest
//
//  Created by Murray Sagal on 1/18/2014.
//  Copyright (c) 2014 Murray Sagal. All rights reserved.
//

#import "SSViewController.h"
#import "Person.h"

@interface SSViewController ()

@property (strong, nonatomic) Person *person;

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
- (IBAction)validateFirstName:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
- (IBAction)validateLastName:(id)sender;

@end

@implementation SSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.moc];
    
    self.firstNameField.text = @"a";
    self.lastNameField.text = @"b";
}

- (IBAction)validateFirstName:(id)sender {
    
    // firstName's validation is not specified in the model editor, rather it's implemented in validateFirstName:error: in the Person class.
    // All the validation is managed in validateFirstName:error: and this allows a directly consumable error message to be returned.
    
    // Note: the validation process is kicked-off by calling validateValue:forKey:error:. Core Data takes care of calling the
    // validate<key>:error: method. Don't call your validate<key>:error: methods directly.
    
    NSString *firstName = self.firstNameField.text;
    NSError *error;
    BOOL isValid = [self.person validateValue:&firstName forKey:@"firstName" error:&error];
    
    if (!isValid) {
        NSString *errorMessage = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (IBAction)validateLastName:(id)sender {
    
    // lastName's validation is specified in the Core Data model.
    // validateLastName:error: is implemented but is just a stub so that outError can be inspected.
    // See the console for the log output showing the error message returned by Core Data.
    
    NSString *lastName = self.lastNameField.text;
    NSError *error;
    BOOL isValid = [self.person validateValue:&lastName forKey:@"lastName" error:&error];
    
    if (!isValid) {
        
        NSLog(@"[<%@ %p> %@ line= %d] code= %li, desc= %@", [self class], self, NSStringFromSelector(_cmd), __LINE__, (long)error.code, error.localizedDescription);
        
        NSString *errorMessage;
        
        // In this case, this switch is required to provide a consumable error message.
        // This is trivial to implement and is fine in many cases but not if you need to
        // strictly adhere to KVC.
        switch (error.code) {
            case NSValidationStringTooShortError:
                errorMessage = @"Last Name must be at least 2 characters.";
                break;
                
            case NSValidationStringTooLongError:
                errorMessage = @"Last Name can't be more than 10 characters.";
                break;
                
        }
        
        if (errorMessage) {
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
}

@end

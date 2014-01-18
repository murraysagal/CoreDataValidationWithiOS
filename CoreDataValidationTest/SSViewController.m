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
    // Do any additional setup after loading the view from its nib.
    
    self.person = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.moc];
    
}

- (IBAction)validateFirstName:(id)sender {
    
    // firstName has no validation set in the Core Data model.
    // All the validation is managed in validateFirstName:error: so meaningful error messages can be returned.
    
    NSString *firstName = self.firstNameField.text;
    NSError *error;
    BOOL isValid = [self.person validateValue:&firstName forKey:@"firstName" error:&error];
    
    if (!isValid) {
        NSString *errorMessage = [error localizedDescription];
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
    
}

- (IBAction)validateLastName:(id)sender {
    
    // lastName's validation is set in the Core Data model.
    // validateLastName:error: is not implemented. See the console for the error messages returned by Core Data.
    
    NSString *lastName = self.lastNameField.text;
    NSError *error;
    BOOL isValid = [self.person validateValue:&lastName forKey:@"lastName" error:&error];
    
    if (!isValid) {
        
        NSLog(@"error code= %i; localized description returned by Core Data: %@", error.code, error.localizedDescription);
        
        NSString *errorMessage;
        
        switch (error.code) {
            case NSValidationStringTooShortError:
                errorMessage = @"Last Name must be at least 2 characters.";
                break;
                
            case NSValidationStringTooLongError:
                errorMessage = @"Last Name can't be more than 10 characters.";
                break;
                
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }

}
@end

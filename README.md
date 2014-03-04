# Description

This project demonstrates that on iOS the default Core Data validation error messages are not suitable for display to the user and that the only way to return directly consumable error messages *and* follow the standard KVC validation approach is to remove all validation for an NSManagedObject's properties from the Core Data model editor and implement validation using Core Data's validate<key>:error: method.

## Scenario

A new Person object, an NSManagedObject subclass, is inserted into the MOC. The view controller displays a form for editing. Early (before save) validation is implemented using the standard KVC `validateValue:forKey:error:` method like this...
```
NSError *error;
BOOL isValid = [person validateValue:&firstName forKey:@"firstName" error:&error];
if (!isValid) { // handle the error here }
```
Validation constraints, like min and max width, are set in Core Data's model editor in Xcode. 

## The Problem

When firstName is validated and it's too short an error like this is returned...
```
Error Domain=NSCocoaErrorDomain Code=1670 "The operation couldn’t be completed. (Cocoa error 1670.)" UserInfo=0x8f44a90 {NSValidationErrorObject=<Event: 0xcb41a60> (entity: Event; id: 0xcb40d70 <x-coredata://ADB90708-BAD9-47D8-B722-E3B368598E94/Event/p1> ; data: {
    firstName = B;
    }), NSValidationErrorKey=firstName, NSLocalizedDescription=The operation couldn’t be completed. (Cocoa error 1670.), NSValidationErrorValue=B}
```
You can see that localizedDescription is not suitable for displaying the error to the user. But the error code is there so it is straightforward to implement something like this...
```
switch ([error code]) {

    case NSValidationStringTooShortError:
        errorMsg = @"First name must be at least two characters.";
        break;
               
    case NSValidationStringTooLongError:
        errorMsg = @"First name is too long.";
        break;

    // of course, for real, these would be localized strings, not just hardcoded like this
}
```
This is good in concept but firstName, and other Person properties, is editable on other view controllers so that switch would have to be implemented again on whatever view controller edits firstName. Or, of course, it could also be implemented as a method in the Person class, something like `localizedErrorMessageForKey:withCode:`...
```
NSError *error;
BOOL isValid = [person validateValue:&firstName forKey:@"firstName" error:&error];
if (!isValid) { 
	NSString *errorMessage = [person localizedErrorMessageForKey:@"firstName" code:[error code]];
	...
 }
```

But, however it's implemented, getting a consumable error message to the view controller requires the developer to deviate in some way from the standard KVC approach. This may be acceptable in some cases but assume for the moment that there is a use case that requires strict adherence to the standard KVC approach. 

So, is there a way to return a directly consumable error message *and* adhere to KVC? 

## Adhering to KVC

Looking at the Core Data docs for Property-Level Validation reveals this...

> If you want to implement logic in addition to the constraints you provide in the managed object model, you should not override validateValue:forKey:error:. Instead you should implement methods of the form validate<Key>:error:. 

So now `validateFirstName:error:` is partially implemented in Person.m like this allowing ioValue and outError to be inspected...
```
- (BOOL)validateFirstName:(id *)ioValue error:(NSError **)outError {
    NSLog(@"*ioValue= %@", *ioValue);
    NSLog(@"*outError= %@", *outError);
}
```
But inside `validateFirstName:error:`, outError is still nil even when firstName is invalid. When control returns to the view controller there is an error like at the top of this question indicating that the Core Data validation runs *after* any `validate<key>:error:` implementations but, again, that's too late.

## Possible Workaround

In the current implementation of Core Data I think there may be only one way to return a consumable error message *and* remain within KVC. 

Remove all the validation from the Core Data model editor in Xcode and perform all of the validation in the `validate<key>:error:` methods like `validateFirstName:error:`. Based on the results, construct a consumable error message, create a new NSError object and return that to the view controller.

## Strict KVC Use Case

Simply put, I can't deviate from KVC because I'm creating an editing framework. Within the framework, all the view controller knows about the property being edited is the key, like @"firstName" and its model object, like self.person. Thus it can't do anything other than the standard KVC approach to validation. 

The workaround works fine. But users of the framework who are already using Core Data probably have constraints specified in the model and adding my framework would mean moving all of that to the validation method. 

# Suggestions for Enhancing Core Data

I have two suggestions for enhancing Core Data on iOS that would, I think, alleviate this problem altogether. 

1. In the Xcode Core Data model editor allow the developer to specify the error message along with the constraint. Of course, these wouldn't be hardcoded strings but keys to a localized message. It should also support substitution of the constraint value so the strings wouldn't need to be changed if the value changed. "First name must be at least 2 characters." The 2 would be substituted. This way, in most cases, developers would not have to implement `validate<key>:error:` methods because Core Data would use the developer-provided error messages in the error object. 

2. Have Core Data perform the validation for the constraints specified in the model before calling validate<key>:error:. If there is an error or errors pass along a filled in error object. Then the developer can inspect outError and create a new error object that contains a directly consumable error message and return that to the view controller. 
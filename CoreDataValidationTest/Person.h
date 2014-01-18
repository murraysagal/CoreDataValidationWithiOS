//
//  Person.h
//  CoreDataValidationTest
//
//  Created by Murray Sagal on 1/18/2014.
//  Copyright (c) 2014 Murray Sagal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@end

//
//  SSMasterViewController.h
//  CoreDataValidationTest
//
//  Created by Murray Sagal on 12/13/2013.
//  Copyright (c) 2013 Murray Sagal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface SSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

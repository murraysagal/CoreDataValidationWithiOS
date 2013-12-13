//
//  SSDetailViewController.h
//  CoreDataValidationTest
//
//  Created by Murray Sagal on 12/13/2013.
//  Copyright (c) 2013 Murray Sagal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

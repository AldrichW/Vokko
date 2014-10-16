//
//  TLMasterViewController.h
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Modified by Victor Zhang


#import <UIKit/UIKit.h>

@class OrganizationsTableViewController;

@protocol OrganizationsTableViewControllerDelegate <NSObject>

-(void)presentActionSheet:(UIActionSheet *)actionSheet fromViewController:(OrganizationsTableViewController *)viewController;

@end

@interface OrganizationsTableViewController : UITableViewController

@property (nonatomic, weak) id<OrganizationsTableViewControllerDelegate> delegate;
- (IBAction)unwindToOrganizations:(UIStoryboardSegue *)segue;

@end

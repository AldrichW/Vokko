//
//  InboxfeedTableViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-04-20.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostCell.h"
#import <Parse/Parse.h>
#import "REmenu.h"

@interface InboxfeedTableViewController : UITableViewController <UITableViewDataSource,UITableViewDelegate>

- (IBAction)unwindToInboxFeed:(UIStoryboardSegue *)segue;

@property (strong, nonatomic) IBOutlet UITableView *inboxFeedTableView;
@property (strong, readonly, nonatomic) REMenu *menu;

- (void)toggleMenu;


@end

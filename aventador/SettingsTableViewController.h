//
//  SettingsTableViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-04-21.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController

- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@property NSMutableArray *settingsDataArray;

@end

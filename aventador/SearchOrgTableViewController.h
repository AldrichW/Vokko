//
//  SearchOrgTableViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-02.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchOrgTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

- (IBAction)unwindToSearchOrganizations:(UIStoryboardSegue *)segue;

@end

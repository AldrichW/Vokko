//
//  SelectOrgTableViewController.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-05.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SelectOrgDelegate <NSObject>
- (void) orgSelected:(NSString*)org_name withID:(NSNumber*)org_id;
@end

@interface SelectOrgTableViewController : UITableViewController

//Delegate to handle new post
@property id<SelectOrgDelegate>delegate;
@property NSMutableArray *organization_list;
@end

//
//  CommentsWrapperViewController.h
//  Comments
//
//  Created by Mark Ye on 2014-05-06.
//  Copyright (c) 2014 Mark Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface DetailedViewController : UIViewController <UIScrollViewDelegate,UITableViewDataSource>

@property NSNumber *user_id;
@property NSString *x_api_key;
@property Post *post;
@property UIImage *image;

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *postLabel;

@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet UIView *innerBackgroundScrollView;

@property (weak, nonatomic) IBOutlet UITableView *commentsTable;

@property (weak, nonatomic) IBOutlet UIView *responseView;
@property (weak, nonatomic) IBOutlet UITextView *responseTextInput;
@property (weak, nonatomic) IBOutlet UIButton *responseButton;

@end
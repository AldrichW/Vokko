//
//  CommentTableViewCell.h
//  Comments
//
//  Created by Mark Ye on 2014-05-06.
//  Copyright (c) 2014 Mark Ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentText;
@property (weak, nonatomic) IBOutlet UIView *commentTextWrapper;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColorView;

@end

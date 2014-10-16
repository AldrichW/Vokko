//
//  PostCell.h
//  aventador
//
//  Created by Victor Zhang on 2014-04-23.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface PostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *loveButton;
@property (weak, nonatomic) IBOutlet UIButton *notSoLoveButton;
@property (weak, nonatomic) IBOutlet UIButton *discussButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

//Will Be Hidden Later
@property (weak, nonatomic) IBOutlet UILabel *yesLabel;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

//Hidden Initially
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;
@property (weak, nonatomic) IBOutlet UILabel *lovePercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *notSoLovePercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *notSoLoveLabel;
@property (weak, nonatomic) IBOutlet UILabel *discussLabel;
@property (weak, nonatomic) IBOutlet UILabel *discussNumberLabel;


// Invisible Buttons (Hidden Permanently)
@property (weak, nonatomic) IBOutlet UIButton *yesLabelButton;
@property (weak, nonatomic) IBOutlet UIButton *noLabelButton;


@end

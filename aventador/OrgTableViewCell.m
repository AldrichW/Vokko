//
//  OrgTableViewCell.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-01.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "OrgTableViewCell.h"

@implementation OrgTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

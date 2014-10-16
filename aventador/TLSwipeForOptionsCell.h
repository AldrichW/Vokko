//
//  TLSwipeForOptionsCell.h
//  UITableViewCell-Swipe-for-Options
//
//  Created by Ash Furrow on 2013-07-29.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//  Modified by Victor Zhang
//

#import <UIKit/UIKit.h>
#import "OrgTableViewCell.h"

@class TLSwipeForOptionsCell;

@protocol TLSwipeForOptionsCellDelegate <NSObject>

-(void)cellDidSelectDelete:(TLSwipeForOptionsCell *)cell;

@end

extern NSString *const TLSwipeForOptionsCellEnclosingTableViewDidBeginScrollingNotification;

@interface TLSwipeForOptionsCell : OrgTableViewCell

@property (nonatomic, weak) id<TLSwipeForOptionsCellDelegate> delegate;

@end

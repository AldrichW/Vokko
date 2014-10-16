//
//  Post.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-05.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject
@property (nonatomic, copy) NSNumber *post_id;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *location;

@property (nonatomic, copy) NSString *image_key;

@property (nonatomic, copy) NSDate *time;

@property (nonatomic, copy) NSNumber *like_percent;
@property (nonatomic, copy) NSNumber *dislike_percent;
@property (nonatomic, copy) NSNumber *num_comments;

@property (nonatomic, copy) NSNumber *organization_id;

@property (nonatomic,copy) NSNumber* user_response;
@property (nonatomic, copy) NSMutableArray *comments;

+ (Post *)newPostFromJSON:(NSDictionary*)post_json;
@end

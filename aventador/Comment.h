//
//  Comment.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-08.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Comment : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSNumber *user_id;
@property (nonatomic, copy) NSDate *time;

+ (Comment *)newCommentFromJSON:(NSDictionary*)post_json;
@end

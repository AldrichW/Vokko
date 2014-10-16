//
//  Comment.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-08.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+ (Comment *)newCommentFromJSON:(NSDictionary*)post_json {
    
    Comment * returnComment = [[Comment alloc] init];
    returnComment.message = post_json[@"comment"];
    
    NSString *time_str = post_json[@"time"];
    NSLog(@"%@",time_str);
    //2014-04-02 05:37:45"
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* time = [formatter dateFromString:time_str];
    
    returnComment.time = time;
    returnComment.user_id = post_json[@"user_id"];
    return  returnComment;
}

@end

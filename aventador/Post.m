//
//  Post.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-05.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "Post.h"
#import "Comment.h"

@implementation Post

+ (Post *)newPostFromJSON:(NSDictionary*)post {
    
    Post *returnPost = [Post new];
    
    NSString *message = post[@"message"];
    NSNumber *post_id = [post valueForKey:@"post_id"];
    
    NSNumber *numdislike = [post valueForKey:@"numdislike"];
    NSNumber *numlike = [post valueForKey:@"numlike"];
    NSNumber *numneutral = [post valueForKey:@"numneutral"];
    NSNumber *user_response = [post valueForKey:@"user_response"];

    //Calculate the percentages
    //Calculate the percentages and save locally. Everything is hidden anyway.
    double like = (double)[numlike intValue];
    double dislike = (double)[numdislike intValue];
    double neutral = (double)[numneutral intValue];
    double totalcount = (double) (like+dislike+neutral);
    
    // Have Never Liked Yet
    double lperc = ((1+like)*100)/(totalcount+1);
    double dperc = ((1+dislike)*100)/(totalcount+1);
    int lp = round(lperc);
    int dp = round(dperc);
    // Have Liked Already
    
    NSNumber *llp;
    NSNumber *ddp;
    if ([user_response intValue] != 0) {
        double llperc = (double)like*100.0/(double)totalcount;
        double ddperc = (double) dislike*100.0 / (double) totalcount;
        llp = [NSNumber numberWithInt:round(llperc)];
        ddp = [NSNumber numberWithInt:round(ddperc)];
        returnPost.like_percent = llp;
        returnPost.dislike_percent = ddp;
    }
    else {
        returnPost.like_percent = [NSNumber numberWithInt:lp];
        returnPost.dislike_percent = [NSNumber numberWithInt:dp];
    }
    
    NSLog(@" %lf %lf %lf %lf", like, dislike, neutral, totalcount);
    NSLog(@" %d %d %d %d", lp, dp, llp.intValue, ddp.intValue);
    
    if (lperc > 100 || llp.intValue > 100 || dperc > 100 || ddp.intValue > 100) {
        NSLog(@" %lf %lf %lf %lf", like, dislike, neutral, totalcount);
        NSLog(@" %lf %lf %d %d", lperc, dperc, llp.intValue, ddp.intValue);

        abort();
    }
    
    NSString *image_key = post[@"image_key"];
    NSString *time_str = post[@"time"];
    NSString *location = post[@"location"];
    NSNumber *organization_id = [post valueForKey:@"organization_id"];
    
    //2014-04-02 05:37:45"
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* time = [formatter dateFromString:time_str];
    NSLog(@"time:%@ to time:%@", time_str, time);
    
    NSMutableArray *retrievedComments = post[@"comments"];
    NSMutableArray *comments = [[NSMutableArray alloc] init];
    for (NSDictionary *comment_dict in retrievedComments) {
        [comments addObject:[Comment newCommentFromJSON:comment_dict]];
    }
    NSNumber *num_comments = [NSNumber numberWithInt:comments.count];
    
    NSLog(@"POST's comments: %@", comments);
    
    returnPost.post_id = post_id;
    returnPost.message = message;
    returnPost.image_key = image_key;
    returnPost.num_comments = num_comments;
    returnPost.user_response = user_response;
    returnPost.time = time;
    returnPost.location = location;
    returnPost.organization_id = organization_id;
    returnPost.comments = comments;
    
    return returnPost;
}

@end

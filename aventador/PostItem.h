//
//  PostItem.h
//  
//
//  Created by Victor Zhang on 2014-05-07.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostItem : NSManagedObject

@property (nonatomic, retain) NSNumber * post_id;
@property (nonatomic, retain) NSNumber * numneutral;
@property (nonatomic, retain) NSNumber * numlike;
@property (nonatomic, retain) NSString * image_key;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * numdislike;

@end

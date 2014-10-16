//
//  OrganizationItem.h
//  
//
//  Created by Victor Zhang on 2014-05-07.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OrganizationItem : NSManagedObject

@property (nonatomic, retain) NSNumber * org_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSNumber * verified;

@end

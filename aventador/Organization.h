//
//  Organization.h
//  aventador
//
//  Created by Victor Zhang on 2014-05-03.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Organization : NSObject {
    
}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, copy) NSNumber *org_id;
@property (nonatomic, copy) NSNumber *verified;


+(id)newOrganization:(NSString*)name withImage:(NSString*)thumbnail withID:(NSNumber*)organization_id;
+(Organization*) organizationFromJSON:(NSDictionary*)org;
@end

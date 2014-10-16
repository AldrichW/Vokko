//
//  Organization.m
//  aventador
//
//  Created by Victor Zhang on 2014-05-03.
//  Copyright (c) 2014 Vokko. All rights reserved.
//

#import "Organization.h"

@implementation Organization

+(id) newOrganization:(NSString*)org_name withImage:(NSString*)org_thumbnail withID:(NSNumber*)organization_id {
        Organization *org = [Organization new];
        org.name = org_name;
        org.thumbnail = org_thumbnail;
        org.org_id = organization_id;
        return org;
}

+(Organization*) organizationFromJSON:(NSDictionary*)org {
    Organization *returnOrg = [Organization new];
    returnOrg.name = org[@"name"];
    returnOrg.org_id = org[@"organization_id"];
    returnOrg.verified =  [org valueForKey:@"verified"];
    return returnOrg;
}


@end

//
//  Parking+ParkingParser.m
//  Car Parking
//
//  Created by NIIT Technologies on 06/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "ParkingParser.h"

@implementation ParkingParser

+(NSMutableArray*)parseLocationData:(NSArray*)records {
    
    NSMutableArray* arrLocations = [[NSMutableArray alloc] init];
    for (int index = 0; index < records.count; index++) {
        NSDictionary* dic = [records objectAtIndex:index];
        Parking* pObj = [[Parking alloc] initWithData:dic];
        [arrLocations addObject:pObj];
    }
    return arrLocations;
}
@end

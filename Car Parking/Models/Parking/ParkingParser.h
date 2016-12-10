//
//  Parking+ParkingParser.h
//  Car Parking
//
//  Created by NIIT Technologies on 06/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "Parking.h"

@interface ParkingParser :NSObject
+(NSMutableArray*)parseLocationData:(NSArray*)records;
@end

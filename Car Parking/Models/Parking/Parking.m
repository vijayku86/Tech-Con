//
//  Parking.m
//  Car Parking
//
//  Created by NIIT Technologies on 06/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "Parking.h"

@implementation Parking
@synthesize occupied,cellId,loation,block;

-(id)init {
    if (self = [super init]) {
        self.occupied = NO;
        self.cellId = @"";
        self.loation = @"";
        self.block = @"";
    }
    return self;
}

-(id)initWithData:(NSDictionary*)result{
    
    if(result != nil){
        self.occupied = [[result objectForKey:@"occupied"] boolValue] ;
        self.cellId = [result objectForKey:@"_id"];
        self.loation = [result objectForKey:@"location"];
        self.block = [result objectForKey:@"block"];
    }
    return self;
}

@end

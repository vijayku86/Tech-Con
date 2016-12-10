//
//  Parking.h
//  Car Parking
//
//  Created by NIIT Technologies on 06/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Parking : NSObject
@property(nonatomic,strong)NSString* cellId;
@property(nonatomic,strong)NSString* loation;
@property(nonatomic,assign)BOOL occupied;
@property(nonatomic,strong)NSString* block;

-(id)initWithData:(NSDictionary*)result;
@end

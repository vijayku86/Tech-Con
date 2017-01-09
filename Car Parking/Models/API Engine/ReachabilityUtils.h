//
//  ReachabilityUtils.h
//  MercerTrackerIII
//
//  Created by Suni on 24/02/16.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface ReachabilityUtils : NSObject
+(NetworkStatus *)getNetworkStatus;

@end

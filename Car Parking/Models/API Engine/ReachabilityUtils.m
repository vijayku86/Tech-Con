//
//  ReachabilityUtils.m
//  MercerTrackerIII
//
//  Created by Suni on 24/02/16.
//
//

#import "ReachabilityUtils.h"
#import "Reachability.h"

@implementation ReachabilityUtils
+( NetworkStatus *)getNetworkStatus{
    
    // Get the network reachibility
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    
    // Get the network status
    if(networkReachability != nil){
      return [networkReachability currentReachabilityStatus];
    }
    
    return nil;
}

@end

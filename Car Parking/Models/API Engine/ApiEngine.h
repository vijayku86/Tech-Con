//
//  ApiEngine.h
//  MercerTrackerIII
//
//  Created by Corey on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ApiEngine : NSObject<NSURLSessionTaskDelegate>  {
    
    
}
//@property (retain, nonatomic) NSMutableArray *pairs;


+ (ApiEngine *)singleton;

- (NSDictionary *)getAllStopoffs;

- (NSDictionary *)getCheckCalls:(NSString *)orderNumber;

- (NSDictionary *)getComments:(NSString *)orderNumber;

- (NSDictionary *)getCompletionPending:(NSString *)orderNumber;

- (NSDictionary *)getDevice;

- (NSDictionary *)getLatestVersion;

- (NSDictionary *)getDirections:(NSString *)orderNumber
                               :(NSString *)customerType;

- (NSDictionary *)getDispatchedOrders;

- (NSDictionary *)getMatchedOrders;

- (NSDictionary *)postRequestToAcceptOrRejectOfferedOrder:(NSString*)type
                                                  orderNo:(NSString*)orderNum;

- (NSDictionary *)getOrder:(NSString *)orderNumber;

- (NSDictionary *)getStopOffs:(NSString *)orderNumber
                             :(NSString *)stopoffListType;

- (NSDictionary *)postCheckCall1:(NSString *)orderNum
                                :(NSString *)StopNum
                                :(NSString *)CheckCallMode
                                :(NSString *)CheckCallDate
                                :(NSString *)CheckCallTime
                                :(NSString *)CheckCallComment
                                :(NSString *)CustTrailer1
                                :(NSString *)CustTrailer2
                                :(NSString *)BOL
                                :(NSString *)Weight
                                :(NSString *)Pieces
                                :(NSString *)DeliverySig
                                :(NSString*)CustTrailer1Percent
                                :(NSString*)CustTrailer2Percent
                                :(NSString *)nextStopNumber
                                :(NSString *)etaDate
                                :(NSString*)etaTime
                                :(NSString *)etaComment;

- (NSDictionary *)postCheckCall2:(NSString *)orderNum
                                :(NSString *)DeviceLatitude
                                :(NSString *)DeviceLongitude
                                :(NSString *)CheckCallComment
                                :(NSString *)nextStopNumber
                                :(NSString *)etaDate
                                :(NSString*)etaTime
                                :(NSString *)etaComment;

- (NSDictionary *)registerDevice:(NSString *)registrationCode;

- (void)sendLocation:(CLLocation*)loc;

- (NSDictionary *)updateETA:(NSString *)orderNumber
                           :(NSString *)stopNumber
                           :(NSString *)etaDate
                           :(NSString*)etaTime
                           :(NSString *)etaComment;

- (NSDictionary *)getChatRecs:(NSString *)orderNumber;

- (NSDictionary *)getHookStatus;

- (NSDictionary *)postChatRec :(NSString *)orderNumber
                              :(NSString*)chatComment;

- (NSDictionary *)shareLocationStatus:(NSString*)locationFlag;

- (NSDictionary *)getCompletedRequirements :(NSString *)controllingCustomer
                                           :(NSString*)stopType;

- (NSDictionary *)postITVCheckCallLog:(NSString *)orderNum
                                     :(NSString *)StopNum
                                     :(NSString *)CheckCallDate
                                     :(NSString *)CheckCallTime
                                     :(NSString *)stopNumber
                                     :(NSString *)etaDate
                                     :(NSString*)etaTime
                                     :(NSString *)etaComment;

- (NSDictionary *)updateToken_IOS:(NSString *)devicetoken;

- (NSDictionary *)getUnbilledLoads;

- (BOOL)errorCheckResult:(NSDictionary*)result andShowAlert:(BOOL)showalert;

- (void)reportLocationIfNoError:(NSDictionary *)result;
- (NSDictionary *)getAdvanceType;
- (NSDictionary *)sendLocationToServer:(NSMutableArray *)locationArray
                                 index:(NSInteger)idx
                               Offline:(BOOL)offline;

-(NSDictionary *)postCrashReportToServer:(NSString *)filePath;


- (NSDictionary *)PostAdvanceType:(NSString *)orderNumber
                                 :(NSString *)deviceLatitude
                                 :(NSString *)deviceLongitude
                                 :(NSString *)Type
                                 :(NSString *)Amount;

- (NSDictionary *)hookTrailer :(NSString *)trailerCode;

- (NSDictionary *)unhookTrailer;

@end

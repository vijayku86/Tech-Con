//
//  ApiEngine.m
//  MercerTrackerIII
//
//  Created by Corey on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ApiEngine.h"



// API urls
#define MERCERAPI "MercerMobileDriverAPI3"

#define MERCERAPI "MercerMobileDriverAPITest"

//#import "NSUserDefaults+Data.h"

#import "Reachability.h"
#import "ReachabilityUtils.h"

#define GPS_LOCATION_PLIST_NAME @"GPSLocation.plist"
#define GPS_LOCATION_RESOURCE @"GPSLocation"
#define PLIST_TYPE @"plist"

#define ONLINE_GPS_LOCATION_PLIST_NAME @"OnlineGPSLocation.plist"
#define OFFLINE_GPS_LOCATION_PLIST_NAME @"OfflineGPSLocation.plist"




@implementation ApiEngine

NSString *baseURL;

/*
 The following characters cause the server to error when included in comments fields (or chat record)
 error 400: % & * : < > /
 server error DFT01: \ . /
 */

- (id) init
{
    if (self = [super init])
    {
        NSLog(@"API = %@",MERCERAPI);
        //Base URL of the API Service from Mercer Transportation;
        baseURL = [[NSString alloc] initWithFormat:@"http://ic.mercer-trans.com/%@/",MERCERAPI];
        
        
    }
    return self;
}

+ (ApiEngine *)singleton
{
    static dispatch_once_t pred;
    static ApiEngine *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[ApiEngine alloc] init];
    });
    return shared;
}

//Background Api Call
- (NSDictionary *)performApiCallInBackground:(NSMutableURLRequest *)request {
    
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    int statuscode = (int)[response statusCode];
    
    NSDate *now = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSLog(@"The Service posting Time is %@",[dateFormatter stringFromDate:now]);
    
    
    NSLog(@"/n###########status code %d",statuscode);
    
    //    printf("/n###########status code %d",statuscode);
    //    printf("\n\n\n###################Time: %s",[[DateTimeUtils  convertCurrentDateTimeToString] UTF8String]);
    //
    
    
    if (error != NULL) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:error, @"error", nil];
        /*
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
         message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
         delegate:nil
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil];
         
         [alert show];
         */
        NSLog(@"Error Occured : %@",error);
        return mutableDictionary;
    }
    
    if (statuscode == 404 ||
        statuscode == 400) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",statuscode], @"error", nil];
        return mutableDictionary;
    }
    
    NSString *returnDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    id jsonData = [NSJSONSerialization JSONObjectWithData:[returnDataString dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:nil];
    
    if ([jsonData isKindOfClass:[NSArray class]]) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:jsonData, @"array", nil];
        //NSLog(@"%@",mutableDictionary);
        return mutableDictionary;
    } else {
        //NSLog(@"%@",[[NSDictionary alloc] initWithDictionary:jsonData]);
        return [[NSDictionary alloc] initWithDictionary:jsonData];
    }
}



//Base code for interacting with the API Service;
//Pass in the last half of the URL including the method name and variables (RESTful) and it will return an NSDictionary with the response;
- (NSDictionary *)performApiCall :(NSMutableURLRequest *)request {
    
    
    NSHTTPURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSLog(@"API Response = %@",response);
    int statuscode = (int)[response statusCode];
    NSLog(@"/n###########status code %d",statuscode);
    
    
    if (error != NULL) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:error, @"error", nil];
        
        NSLog(@"Error Occured : %@",error);
        return mutableDictionary;
    }
    
    if (statuscode == 404 || statuscode == 400) {
        
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",statuscode], @"error", nil];
        
        
        return mutableDictionary;
    }
    else if (statuscode == 204){
        //Handle response when reqeust is successfull and server send no success message
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",statuscode], @"responsecode", nil];
        return mutableDictionary;
    }
    
    NSString *returnDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",returnDataString);
    id jsonData = [NSJSONSerialization JSONObjectWithData:[returnDataString dataUsingEncoding:NSUTF8StringEncoding] options:(NSJSONReadingMutableContainers) error:nil];
    NSLog(@"jsonData =%@",jsonData);
    if(statuscode == 500) {

    }
    if(jsonData){
        if ([jsonData isKindOfClass:[NSArray class]]) {
            NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:jsonData, @"array", nil];
            
            NSLog(@"MDict=%@",mutableDictionary);
            return mutableDictionary;
        } else {
            //NSLog(@"%@",[[NSDictionary alloc] initWithDictionary:jsonData])
            return [[NSDictionary alloc] initWithDictionary:jsonData];
        }
    }
    else{
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",statuscode], @"error", nil];
        return mutableDictionary;
    }
}

- (NSDictionary *)performGetApiCall :(NSString *)urlPart {
    NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, urlPart];
    
    NSLog(@"--APICALL [%@]", connectionURL);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return [self performApiCall:request];
}

- (void)setHTTPBodyWithString:(NSString *)body forRequest:(NSMutableURLRequest *)request {
    NSLog(@"BODY [%@]",body);
    
    NSData *bodyData = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:bodyData];
}

- (NSDictionary *)performPostApiCall :(NSString *)urlPart :(NSArray *)pairs
{
    
    NSLog(@"Data ready to post");
    NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, urlPart];
    
    NSLog(@"APICALL [%@]", connectionURL);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    NSString *params = @"";
    if(pairs){
        if([pairs count]>0){
            params = [pairs componentsJoinedByString:@"&"];
        }
    }
    
    [self setHTTPBodyWithString:params forRequest:request];

    NSLog(@"%@",params);
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return [self performApiCall:request];
}







//Returns a list of stop offs that haven’t had an Arrival call for all dispatched orders.
- (NSDictionary *)getAllStopoffs {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetAllStopoffs/%@", [myData getDeviceCode]]];
    return returnData;
}

//Returns a list of Check Calls associated with the order.
- (NSDictionary *)getCheckCalls:(NSString *)orderNumber {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetCheckCalls/%@/%@", [myData getDeviceCode], orderNumber]];
    return returnData;
}

//Returns a list of comments associated with the order.
- (NSDictionary *)getComments:(NSString *)orderNumber {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetComments/%@/%@", [myData getDeviceCode], orderNumber]];
    return returnData;
}

//Returns True if there is a stopoff that has an arrival date and no associated completion date else it returns false.
//In addition to the Boolean value, if True is returned, details about the first stopoff that has not been completed are also provided.
- (NSDictionary *)getCompletionPending:(NSString *)orderNumber {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetCompletionPending/%@/%@", [myData getDeviceCode], orderNumber]];
    
    NSLog(@"%@",returnData);
    return returnData;
}

//Returns device attributes.
- (NSDictionary *)getDevice {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetDevice/%@", [myData getDeviceCode]]];
    return returnData;
}

//Returns latest available app version.
- (NSDictionary *)getLatestVersion {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetLatestVersion/%@", [myData getDeviceCode]]];
    return returnData;
}

//Gets the directions to the location of the customer identified in the parameters.
- (NSDictionary *)getDirections:(NSString *)orderNumber :(NSString *)customerType {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetDirections/%@/%@/%@", [myData getDeviceCode], orderNumber, customerType]];
    return returnData;
}

//Returns all dispatched orders related to the device.
- (NSDictionary *)getDispatchedOrders {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetDispatchedOrders/%@", [myData getDeviceCode]]];
    return returnData;
}

//Returns all matched orders related to the device.
- (NSDictionary *)getMatchedOrders {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetOfferedLoads/%@", [[myData getDeviceCode] uppercaseString]]];
    return returnData;
}

- (NSDictionary *)postRequestToAcceptOrRejectOfferedOrder:(NSString*)type orderNo:(NSString*)orderNum {
    
    NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, @"PostResponseToOfferedOrder"];
    
    NSLog(@"postResponseToOfferedOrder -[%@]", connectionURL);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    NSString *params = [NSString stringWithFormat:@"{\"DeviceCode\":\"%@\",\"OrderNum\":\"%@\",\"Action\":\"%@\"}",[[myData getDeviceCode] uppercaseString],orderNum,type];
    NSLog(@"Reject Request params: %@",params);
    [self setHTTPBodyWithString:params forRequest:request];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //application/json || application/x-www-form-urlencoded
    return [self performApiCall:request];
}

- (NSDictionary *)shareLocationStatus:(NSString *)locationFlag{
    
    NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, @"LocationSharingAudit/"];
    connectionURL = [connectionURL stringByAppendingFormat:@"%@/%@",[[myData getDeviceCode] uppercaseString],locationFlag];
    
    NSLog(@"postResponseToOfferedOrder -[%@]", connectionURL);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    return [self performApiCall:request];
    
}

- (NSDictionary *)getUnbilledLoads {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetUnbilledLoads/%@", [myData getDeviceCode]]];
    return returnData;
}

//Returns the units last reported location information.
- (NSDictionary *)getLastReportedLocation {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetLastReportedLocation/%@", [myData getDeviceCode]]];
    return returnData;
}

//Returns order details.
- (NSDictionary *)getOrder:(NSString *)orderNumber {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetOrder/%@/%@", [myData getDeviceCode], orderNumber]];
    return returnData;
}

//Returns a list of stop offs according to the parameters.
- (NSDictionary *)getStopOffs:(NSString *)orderNumber :(NSString *)stopoffListType {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetStopoffs/%@/%@/%@", [myData getDeviceCode], orderNumber, stopoffListType]];
    return returnData;
}

- (NSDictionary *)getAdvanceType{
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetAdvanceTypes/%@", [myData getDeviceCode]]];
    return returnData;
}

- (NSDictionary *)getHookStatus{
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetHookStatus/%@", [myData getDeviceCode]]];
    return returnData;
}

//Post Crash Report to server.
-(NSDictionary *)postCrashReportToServer:(NSString *)filePath{
    @try {
        NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@PostCrashReport/%@", baseURL,[myData getDeviceCode]];
        
        NSLog(@"postCrashReportToServer APICALL [%@]", connectionURL);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:200.0];
        
        
        
        NSError *error;
        
        
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *postbody = [NSMutableData data];
        
        
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"fieldNameHere\"; filename=\"%@\"\r\n", filePath] dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postbody appendData:[NSData dataWithContentsOfFile:filePath]];
        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:postbody];
        NSLog(@"%@",postbody);
        
        NSHTTPURLResponse *response;
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *str = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"Data ---- %@", str);
        
        int statuscode = (int)[response statusCode];
        NSLog(@"%d",statuscode);

        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%d",statuscode], @"error", nil];
        
        return mutableDictionary;
        
    } @catch (NSException *exception) {
        NSLog(@"Exception while sending crashLog-%@\n%@",exception.reason,exception.callStackSymbols);
        return [NSDictionary new];
    }    
}
- (NSDictionary *)PostAdvanceType:(NSString *)orderNumber
                                 :(NSString *)deviceLatitude
                                 :(NSString *)deviceLongitude
                                 :(NSString *)Type
                                 :(NSString *)Amount{
    
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"Latitude" andValue:[self valueForLatLong:deviceLatitude]],
                             [self paramPairFor:@"Longitude" andValue:[self valueForLatLong:deviceLongitude]],
                             [self paramPairFor:@"Type" andValue:Type],
                             [self paramPairFor:@"Amount" andValue:Amount],nil];

                             NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"PostAdvance/%@/%@/",[myData getDeviceCode],orderNumber]
                                                                                :pairs];
    
    NSLog(@"%@",returnData);
    return returnData;
    
}
                             
-(NSString*)paramPairFor:(NSString*)key andValue:(NSString*)value {
    @try {
        return [NSString stringWithFormat:@"%@=%@",key,value];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.name);
    }
    @finally {
        return [NSString stringWithFormat:@"%@=%@",key,value];
    }
};

//Supports the Arrival and Completed check calls;
- (NSDictionary *)postCheckCall1:(NSString *)orderNum
                                :(NSString *)stopNum
                                :(NSString *)checkCallMode
                                :(NSString *)checkCallDate
                                :(NSString *)checkCallTime
                                :(NSString *)checkCallComment
                                :(NSString *)custTrailer1
                                :(NSString *)custTrailer2
                                :(NSString *)BOL
                                :(NSString *)Weight
                                :(NSString *)Pieces
                                :(NSString *)deliverySig
                                :(NSString*)CustTrailer1Percent
                                :(NSString*)CustTrailer2Percent
                                :(NSString *)nextStopNumber
                                :(NSString *)etaDate
                                :(NSString*)etaTime
                                :(NSString *)etaComment
{
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"CheckCallDate" andValue:checkCallDate],
                             [self paramPairFor:@"CheckCallTime" andValue:checkCallTime],
                             [self paramPairFor:@"BOL" andValue:BOL],
                             [self paramPairFor:@"Weight" andValue:Weight],
                             [self paramPairFor:@"Pieces" andValue:Pieces],
                             [self paramPairFor:@"DeliverySig" andValue:deliverySig],
                             [self paramPairFor:@"CustTrailer1" andValue:custTrailer1],
                             [self paramPairFor:@"CustTrailer2" andValue:custTrailer2],
                             [self paramPairFor:@"CustTrailer1Percent" andValue:CustTrailer1Percent],
                             [self paramPairFor:@"CustTrailer2Percent" andValue:CustTrailer2Percent],
                             [self paramPairFor:@"CheckCallComment" andValue:checkCallComment],
                             [self paramPairFor:@"ETADate" andValue:etaDate],
                             [self paramPairFor:@"ETATime" andValue:etaTime],
                             [self paramPairFor:@"ETAComment" andValue:etaComment],
                             nil];
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"postCheckCall1/%@/%@/%@/%@/%@", [myData getDeviceCode], orderNum, stopNum, checkCallMode, nextStopNumber]
                                                       :pairs];
    NSLog(@"%@",returnData);
    [self reportLocationIfNoError:returnData];
    return returnData;
}

-(NSString*)valueForLatLong:(NSString*)value {
    @try {
        if (value && ![value isEqualToString:@""] && ![value isEqualToString:@"null"]) {
            return value;
        }
        return @"0";
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.name);
    }
    @finally {
        if (value && ![value isEqualToString:@""] && ![value isEqualToString:@"null"]) {
            return value;
        }
        return @"0";
        
    }
}



- (NSDictionary *)postCheckCall2:(NSString *)orderNum
                                :(NSString *)deviceLatitude
                                :(NSString *)deviceLongitude
                                :(NSString *)checkCallComment
                                :(NSString *)nextStopNumber
                                :(NSString *)etaDate
                                :(NSString*)etaTime
                                :(NSString *)etaComment
{
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"Latitude" andValue:[self valueForLatLong:deviceLatitude]],
                             [self paramPairFor:@"Longitude" andValue:[self valueForLatLong:deviceLongitude]],
                             [self paramPairFor:@"CheckCallComment" andValue:checkCallComment],
                             [self paramPairFor:@"ETADate" andValue:etaDate],
                             [self paramPairFor:@"ETATime" andValue:etaTime],
                             [self paramPairFor:@"ETAComment" andValue:etaComment],
                             nil];
    
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"PostCheckCall2/%@/%@/%@", [myData getDeviceCode], orderNum, nextStopNumber]
                                                       :pairs];
    [self reportLocationIfNoError:returnData];
    return returnData;
}

//Method to Hook Trailer;
- (NSDictionary *)hookTrailer :(NSString *)trailerCode {
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"TrailerCode" andValue:trailerCode],
                             [self paramPairFor:@"DeviceCode" andValue:[myData getDeviceCode]],
                             nil];
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"PostHook/%@/%@",[myData getDeviceCode], trailerCode] :pairs];
    
//    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"PostHook/%@/%@",[myData getDeviceCode], trailerCode]];
    NSLog(@"%@",returnData);
    return returnData;
}

//Method to Unhook Trailer;
- (NSDictionary *)unhookTrailer {
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"DeviceCode" andValue:[myData getDeviceCode]],
                             nil];
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"PostUnhook/%@",[myData getDeviceCode]] :pairs];
//    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"PostUnhook/%@", [myData getDeviceCode]]];
    NSLog(@"%@",returnData);
    return returnData;
}

//Method to Register the device;
- (NSDictionary *)registerDevice :(NSString *)registrationCode {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"Register/%@", registrationCode]];
    NSLog(@"%@",returnData);
    return returnData;
}

//Updates the Unit’s location for the ITV system.

- (void)sendLocation:(CLLocation*)loc {
    
    NSLog(@"Inside API Engine sendLocation");
    // make sure there is a device code (auto location reporter gets overzealous)
    
    if ([myData getDeviceCode]) {
        
        dispatch_queue_t myQueue;
        myQueue = dispatch_queue_create("com.mercer.myqueue", 0x0);
        __block NSMutableArray *array = [NSMutableArray array];
        
        dispatch_async(myQueue, ^{
            
            if(loc)
            {
                array = [PlistManagerUtils retriveArrayFromPlist:ONLINE_GPS_LOCATION_PLIST_NAME];
                
                if([array count] >= 1)
                {
                    // Send Online data to the server
                    [self sendLocationToServer :[array objectAtIndex:0] index:0 Offline:NO];
                }else{
                    NSLog(@"No entries in Online File");
                }
            }
            else
            {
                array = [PlistManagerUtils retriveArrayFromPlist:OFFLINE_GPS_LOCATION_PLIST_NAME];
                if([array count] >= 1)
                {
                    [self sendLocationToServer :[array objectAtIndex:0] index:0 Offline:YES];
                }
                else{
                    NSLog(@"No entries in Offline File");
                    
                }
            }
        });
        
    }
}

/*
 * Send Location Data to server
 */
- (NSDictionary *)sendLocationToServer:(NSMutableArray *)locationArray index:(NSInteger)idx Offline:(BOOL)offline
{
    NSLog(@"Inside sendLocationToServer - Sending location to server :  %@", locationArray);
    
    // Send data to server
    NSDictionary *returnData = [self  performPostApiCallBack:[[NSString alloc] initWithFormat:@"UpdateLocation/%@",[myData getDeviceCode]]
                                                            :locationArray index:idx Offline:offline];
    
    return returnData;
}

//static int alertIndex = 0;

- (NSDictionary *)performPostApiCallBack :(NSString *)urlPart :(NSArray *)pairs index:(NSInteger)idx Offline:(BOOL)offline
{
    
    NSThread* thread = [NSThread currentThread];
    if([thread isMainThread]){
        NSLog(@"PPACB Main Thread");
    }else{
        NSLog(@"PPACB Secondary Thread");
    }
    
    NSString *connectionURL = [[NSString alloc] initWithFormat:@"%@%@", baseURL, urlPart];
    
    NSLog(@"APICALL UpdateLocation:[%@]", connectionURL);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:connectionURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:90.0];
    
    NSString *params = @"";
    
    @try {
        
        if(pairs){
            if([pairs count]>0){
                params = [pairs componentsJoinedByString:@"&"];
            }
            params = [params stringByAppendingString:@"&paired=false"];
            /*
            //VJ01092016
            //Appending paired flag for ELD device, if found then true otherwise false
            NSString* unitname = [[NSUserDefaults standardUserDefaults] getELDUnitName];
            
            if(unitname.length > 0){
                NSMutableArray* connectedAccessory =[accessoryEngine connectedAccessories];
                if([connectedAccessory containsObject:unitname]){
                    params = [params stringByAppendingString:@"&paired=true"];
                }else{
                    params = [params stringByAppendingString:@"&paired=false"];
                }
            }
            */
            /*
            if (alertIndex == 0 || alertIndex == 3) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Location alert" message:params delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                   alertIndex = 1;
                   [alert show];
               });
            }else{
                alertIndex++;
            }
             */
            
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        return [self performApiCallBack:request Data:params index:idx Offline:offline];
    }
}

- (NSDictionary *)performApiCallBack :(NSMutableURLRequest *)request  Data:(NSString*)data1  index:(NSInteger)idx Offline:(BOOL)offline{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    
    NSData *postData = [data1 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:postData completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
                                          {
                                              // Handle response here
                                              if (error)
                                              {
                                                  if(!offline)
                                                  {
                                                      //when online
                                                      NSMutableArray *ar = [[data1 componentsSeparatedByString:@"&"] mutableCopy];
                                                      NSString *time = [NSString stringWithFormat:@"DateTime_Utc=%@",[DateTimeUtils convertCurrentDateTimeToString]];
                                                      [ar addObject:time];
                                                      
                                                      [PlistManagerUtils AppendTOOffline:ar];
                                                      [PlistManagerUtils removeFromPlist:idx  plist:ONLINE_GPS_LOCATION_PLIST_NAME];
                                                  }
                                                  NSLog(@"dataTaskWithRequest error: %@", error);
                                                  return;
                                              }
                                              NSString *data2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                              
                                              NSLog(@"Data Received is %@", data2);
                                              
                                              NSInteger code = [((NSHTTPURLResponse*)response) statusCode];
                                              
                                              if((code == 200) | (code == 204) | (code == 500))
                                              {
                                                  NSMutableArray *ar = [[data1 componentsSeparatedByString:@"&"] mutableCopy];
                                                  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                                  
                                                  if([ar count] >= 2)
                                                  {
                                                      NSArray *lat = [[ar objectAtIndex:0] componentsSeparatedByString:@"="];
                                                      [dict setObject:[lat objectAtIndex:1] forKey:@"Latitude"];
                                                      
                                                      NSArray *lon = [[ar objectAtIndex:1] componentsSeparatedByString:@"="];
                                                      [dict setObject:[lon objectAtIndex:1] forKey:@"Longitude"];
                                                      [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"Coordinates"];
                                                      
                                                      //Vijay
                                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                                      
                                                  }
                                                  
                                                  
                                                  if(offline)
                                                  {
                                                      [PlistManagerUtils removeFromPlist:idx  plist:OFFLINE_GPS_LOCATION_PLIST_NAME];
                                                  }
                                                  else{
                                                      [PlistManagerUtils removeFromPlist:idx  plist:ONLINE_GPS_LOCATION_PLIST_NAME];
                                                  }
                                                  
                                                  NSMutableArray *array = [PlistManagerUtils retriveArrayFromPlist:ONLINE_GPS_LOCATION_PLIST_NAME];
                                                  
                                                  NSLog(@"After Response and Data Deletion: %@", array);
                                                  
                                                  if([array count] >= 1)
                                                  {
                                                      NSLog(@"Sending Online Data");
                                                      // Send Online data to the server
//                                                      [self sendLocationToServer :[array objectAtIndex:0] index:0 Offline:offline] ;
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self sendLocationToServer :[array objectAtIndex:0] index:0 Offline:offline] ;
                                                      });
                                                      
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"Sending Offline Data in response");
//                                                      [self sendLocation:nil];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self sendLocation:nil];
                                                      });
                                                  }
                                              }
                                              else{
                                                  // Nothing to be done
                                              }
                                              NSLog(@"Response code is %ld", (long)code);
                                          }
                                          
                                          ];
    
    
    [uploadTask resume];
    
    return [NSDictionary dictionary];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    NSLog(@"asdasd");
}

/* Sent as the last message related to a specific task.  Error may be
 * nil, which implies that no error occurred and this task is complete.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"Error is %@", [error description]);
}



/*
 * Send Pending Location Data to server
 */
//- (void)sendPendingLocationToServer{
//    
//    NSLog(@"Inside sendPendingLocationToServer - Send all the pending locations");
//    
//    // Pull all the location stored in the Plist
//    NSMutableArray *plistArray =[PlistManagerUtils retriveArrayFromPlist:GPS_LOCATION_PLIST_NAME];
//    NSLog(@"Pending Location List : %@a", plistArray);
//    
//    
//    if ([plistArray count]<=288) {
//     // Loop to send each location one by one
//    for (int i=0; i<plistArray.count; i++) {
//        
//        NSLog(@"Inside  sending loop : %d", i);
//        
//        // Check the network status. If no network is there then return back.
//        if ([ReachabilityUtils getNetworkStatus] == NotReachable){
//            NSLog(@"There IS NO internet connection. Sending location FAILED");
//            break;
//
//            
//        }else{
//            NSDictionary *returnData =[self sendLocationToServer:[plistArray objectAtIndex:i]];
//            NSLog(@"%@",returnData);
//            
//            // Get the error code if any
//            NSString *error = [returnData objectForKey:@"error"];
//            NSLog(@"%@",error);
//            
//            // If response code null or  error recieved exit from the loop.
//            if([returnData isKindOfClass:[NSNull class]] || error != nil){
//                break;
//            }
//        }
//    }
//    }
//    
//    NSLog(@"Location pending to send, ------------   %@a", [PlistManagerUtils retriveArrayFromPlist:GPS_LOCATION_PLIST_NAME]);
//}
//
//Registers the device with Mercer.
- (NSDictionary *)updateETA:(NSString *)orderNumber :(NSString *)stopNumber :(NSString *)etaDate :(NSString*)etaTime :(NSString *)etaComment {
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"ETADate" andValue:etaDate],
                             [self paramPairFor:@"ETATime" andValue:etaTime],
                             [self paramPairFor:@"ETAComment" andValue:etaComment],
                             nil];
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"UpdateETA/%@/%@/%@", [myData getDeviceCode], orderNumber, stopNumber]
                                                       :pairs];
    [self reportLocationIfNoError:returnData];
    return returnData;
}

- (NSDictionary *)getChatRecs:(NSString *)orderNumber {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetChatRecs/%@/%@", [myData getDeviceCode], orderNumber]];
    [self reportLocationIfNoError:returnData];
    return returnData;
}

- (NSDictionary *)postChatRec:(NSString *)orderNumber :(NSString*)chatComment {
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"ChatRecComment" andValue:chatComment],
                             nil];
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"PostChatRec/%@/%@", [myData getDeviceCode], orderNumber]:
                                pairs];
    [self reportLocationIfNoError:returnData];
    return returnData;
}

- (NSDictionary *)updateToken_IOS:(NSString *)devicetoken {
    
    NSLog(@"%@",devicetoken);
    
    NSString *appVersion= [[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppVersion"];
    
    NSString *OSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSMutableArray *pairs = [NSMutableArray arrayWithObjects:
                             [self paramPairFor:@"iOSDeviceToken" andValue:devicetoken],
                             [self paramPairFor:@"DeviceType" andValue:[UIDeviceUtils deviceHardwareModel]],
                             [self paramPairFor:@"DeviceOS" andValue:@"iOS"],
                             [self paramPairFor:@"DeviceOSVersion" andValue:OSVersion],
                             [self paramPairFor:@"AppVersion" andValue:appVersion],
                             nil];
    
    
    NSLog(@"updateToken_IOS Parms=%@",pairs);
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"UpdateToken_iOS" message:[pairs description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        
//        [alert show];
//    });
    
    NSDictionary *returnData = [self performPostApiCall:[[NSString alloc] initWithFormat:@"UpdateToken_iOS/%@", [myData getDeviceCode]]:
                                pairs];
    
    NSLog(@"updateToken_IOS Response =%@",returnData);
    return returnData;
}


- (NSDictionary *)getCompletedRequirements:(NSString *)controllingCustomer :(NSString*)stopType {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"GetCompletedRequirements/%@/%@", controllingCustomer,stopType]];
    return returnData;
}

- (NSDictionary *)postITVCheckCallLog:(NSString *)orderNum :(NSString *)stopNum :(NSString *)checkCallDate :(NSString *)checkCallTime :(NSString *)stopNumber :(NSString *)etaDate :(NSString*)etaTime :(NSString *)etaComment {
    NSDictionary *returnData = [self performGetApiCall:[[NSString alloc] initWithFormat:@"postITVCheckCallLog/%@/%@/%@/%@/%@/%@/%@/%@/%@", [myData getDeviceCode], orderNum, stopNum, checkCallDate, checkCallTime, stopNum, etaDate, etaTime, etaComment]];
    [self reportLocationIfNoError:returnData];
    return returnData;
}

- (BOOL)errorCheckResult:(NSDictionary*)result andShowAlert:(BOOL)showalert {
    
    //[result valueForKey:@"ErrorCode"] != nil //this check is not working sometimes
    if ([result valueForKey:@"ErrorCode"] != nil && ![[result valueForKey:@"ErrorCode"] isEqual:[NSNull null]]) {
        if (showalert) {
            NSString *error = [result valueForKey:@"ErrorMessage"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        return YES;
    }
    NSObject *errorresult = [result valueForKey:@"error"];
    if (errorresult != nil) {
        if (showalert) {
            NSString *errorMessage;
            if ([errorresult isKindOfClass:[NSError class]]) {
                NSError *error = [result valueForKey:@"error"];
                errorMessage=[error localizedDescription];
            } else {
                if ([errorresult isKindOfClass:[NSString class]]) {
                    errorMessage = [NSString stringWithFormat:@"Unexpected error (%@)",errorresult];
                } else {
                    errorMessage = @"Unknown network error.";
                }
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:[NSString stringWithFormat:@"%@",errorMessage]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
        }
        return YES;
    }
    return NO;
}

-(void)reportLocationIfNoError:(NSDictionary *)result {
    if (![self errorCheckResult:result andShowAlert:NO]) {
        LocationEngine *myLocation = [LocationEngine singleton];
        [myLocation sendLocation];
    }
}

@end

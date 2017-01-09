//
//  ParkingLayoutVC.h
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingLayoutVC : UIViewController

{
    NSTimer* layoutTimer,*timerRFID;
    CALayer *movingLayer;
    BOOL checkPoint1_RFID,checkPoint2_RFID,checkPoint3_RFID;;
    BOOL isTrackSuggestedPath;
    UIImageView* imageViewCar;
}

@property (nonatomic, strong)IBOutlet UIView* blockInfoView;
@property (nonatomic, strong)IBOutlet UIScrollView* scrllView;

@property (nonatomic, strong)IBOutlet UIView* parkingContainerView;
@property (nonatomic, strong)IBOutlet UIScrollView* parkingScrollview;

@property (nonatomic, strong)IBOutlet UIView* blockViewA;
@property (nonatomic, strong)IBOutlet UIView* blockViewB;
@property (nonatomic, strong)IBOutlet UIView* blockViewC;
@property (nonatomic, strong)IBOutlet UIView* blockViewD;

@property (nonatomic, strong)NSMutableArray* arrBlocksView;

- (void)someFunc:(void(^)(NSData*))someBlock;


- (void)sendRequestToServer:(NSURL*)url completionHander:(void(^)(NSData* responseData,NSError* error))completionHander;
//Data arrays
@property (nonatomic, strong)NSMutableArray* arrLocations;
@end

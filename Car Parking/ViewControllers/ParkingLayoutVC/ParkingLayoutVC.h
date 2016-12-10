//
//  ParkingLayoutVC.h
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingLayoutVC : UIViewController

@property (nonatomic, strong)IBOutlet UIView* blockInfoView;
@property (nonatomic, strong)IBOutlet UIScrollView* scrllView;

@property (nonatomic, strong)IBOutlet UIView* parkingContainerView;
@property (nonatomic, strong)IBOutlet UIScrollView* parkingScrollview;

@property (nonatomic, strong)IBOutlet UIView* blockViewA;
@property (nonatomic, strong)IBOutlet UIView* blockViewB;
@property (nonatomic, strong)IBOutlet UIView* blockViewC;
@property (nonatomic, strong)IBOutlet UIView* blockViewD;

@property (nonatomic, strong)NSMutableArray* arrBlocksView;
//Data arrays
@property (nonatomic, strong)NSMutableArray* arrLocations;
@end

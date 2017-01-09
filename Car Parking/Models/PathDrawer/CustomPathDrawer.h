//
//  CustomPathDrawer.h
//  Car Parking
//
//  Created by NIIT Technologies on 12/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
//#import <CoreFoundation/CoreFoundation.h>
//#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "ParkingItemView.h"
//#import "Car Parking-Bridging-Header.h"
//#import "Car Parking-Swift"

#define GapVerticalBtwBlocks        80
#define GapHorizonalBtwBlocks       80
#define leftMarginFromContainer     21
#define ConstanceDifference         35
#define HorizontalSpacing           45
#define VerticalSpacing             20
#define PATH_COLOR                  [UIColor cyanColor]
#define PATH_OPACITY                0.75f
#define PATH_WIDTH                  8.0f

#define SP_START_POINT          CGPointMake(40,450)

#define SP_CHECK_POINT_1        CGPointMake(40,345)
#define SP_CHECK_POINT_2        CGPointMake(40,225)
#define SP_CHECK_POINT_3        CGPointMake(40,185)
#define SP_CHECK_POINT_4        CGPointMake(40,65)

#define SP_CHECK_POINT_5        CGPointMake(420,345)
#define SP_CHECK_POINT_6        CGPointMake(420,225)
#define SP_CHECK_POINT_7        CGPointMake(420,185)
#define SP_CHECK_POINT_8        CGPointMake(420,65)


#define Starting_Point          CGPointMake(StartX,StartY)

#define Block_A_FirstHalf       CGPointMake(StartX,StartY)
#define Block_A_SecondHalf      CGPointMake(StartX,StartY)

#define Block_B_FirstHalf       CGPointMake(StartX,StartY)
#define Block_B_SecondHalf      CGPointMake(StartX,StartY)

#define Block_C_FirstHalf       CGPointMake(StartX,StartY)
#define Block_C_SecondHalf      CGPointMake(StartX,StartY)

#define Block_D_FirstHalf       CGPointMake(StartX,StartY)
#define Block_D_SecondHalf      CGPointMake(StartX,StartY)

#define DEGREES_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface CustomPathDrawer : CAShapeLayer
{
    CAShapeLayer* shapeLayer;
    UIBezierPath* bezierPath;
    BOOL isSuggestedPath;
    
}
@property(nonatomic,strong)NSMutableArray* arrSuggestedPathPoints;

-(UIBezierPath*)getPath;
-(CALayer*)getPathLayer;
-(void) drawPathOnLayer:(CALayer*)superviewLayer toItem:(ParkingItemView*)item;
-(id)drawPathForItem:(ParkingItemView*)itemView;

-(void)drawPathOnLayer:(CALayer*)superviewLayer FromView:(UIView*)containerView toItem:(ParkingItemView*)item totalSlots:(int)slots isSuggestedPath:(BOOL)suggestedPath;

-(void)removeLayer;
@end

//
//  ParkingItemView.h
//  Car Parking
//
//  Created by NIIT Technologies on 05/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingItemView : UIView
@property(nonatomic, strong)IBOutlet UILabel* lblParkingNo;
@property(nonatomic, strong)IBOutlet UIImageView* imageView;
@property(nonatomic, strong)IBOutlet UIButton* button;


@property(nonatomic, strong) NSString* cellID;
@property(nonatomic, assign) BOOL isOccupied;

-(id)initWithFrame:(CGRect)frame occupied:(BOOL)isOccupied identifier:(NSString*)parkingIdentifier;
-(id)parkingViewWithIdentifier:(NSString*)cellIdentifier;
@end

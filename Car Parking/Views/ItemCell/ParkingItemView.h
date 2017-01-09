//
//  ParkingItemView.h
//  Car Parking
//
//  Created by NIIT Technologies on 05/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ParkingItemView;
@protocol ParkingItemViewDelegate <NSObject>

@optional
-(void)containerView:(UIView*)containerView item:(ParkingItemView*)itemView itemClickedAtIndex:(NSInteger)index;

@end


@interface ParkingItemView : UIView
@property(nonatomic, strong)IBOutlet UILabel* lblParkingNo;
@property(nonatomic, strong)IBOutlet UIImageView* imageView;
@property(nonatomic, strong)IBOutlet UIButton* button;
@property(unsafe_unretained,nonatomic) id<ParkingItemViewDelegate>delegate;

@property(nonatomic, strong) NSString* cellID;
@property(nonatomic, assign) BOOL isOccupied;

-(id)initWithFrame:(CGRect)frame occupied:(BOOL)isOccupied identifier:(NSString*)parkingIdentifier delegate:(id)delegate;
-(id)parkingViewWithIdentifier:(NSString*)cellIdentifier;

@end


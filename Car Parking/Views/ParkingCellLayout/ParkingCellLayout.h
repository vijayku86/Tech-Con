//
//  ParkingCellLayout.h
//  Car Parking
//
//  Created by NIIT Technologies on 22/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingCellLayout : UICollectionViewCell
@property (nonatomic,strong) IBOutlet UILabel* lblParkingSlot;
@property (nonatomic,strong) IBOutlet UIImageView* imgCar;
@end

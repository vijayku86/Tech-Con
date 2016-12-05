//
//  ParkingCell.h
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingCell : UITableViewCell
@property( nonatomic, strong)IBOutlet UILabel* lblParkingLocation;
@property( nonatomic, strong)IBOutlet UILabel* lblParkingSlots;
@property( nonatomic, strong)IBOutlet UILabel* lblParkingPercentInformation;
@end

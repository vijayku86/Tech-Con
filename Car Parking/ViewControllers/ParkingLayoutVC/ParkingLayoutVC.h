//
//  ParkingLayoutVC.h
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParkingLayoutVC : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong)IBOutlet UICollectionView* collectionVW;
@property (nonatomic, strong)IBOutlet UIView* blockInfoView;
@property (nonatomic, strong)IBOutlet UIScrollView* scrllView;
@property (nonatomic, strong)NSMutableArray* arrBlocksView;
@end

//
//  ParkingLayoutVC.m
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "ParkingLayoutVC.h"
#import "ParkingCellLayout.h"
#import "ProgressHUD.h"

@interface ParkingLayoutVC ()

@end

@implementation ParkingLayoutVC

-(NSString*)getBlockTitle:(int)index{
    NSString* blockTitle = @"";
    switch (index) {
        case 0:
            blockTitle = @"Block A";
            break;
        case 1:
            blockTitle = @"Block B";
            break;
        case 2:
            blockTitle = @"Block C";
            break;
        case 3:
            blockTitle = @"Block D";
            break;
            
        default:
            blockTitle = [NSString stringWithFormat:@"Block %d",index];
            break;
    }
    return blockTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    UICollectionViewDelegateFlowLayout
    [self.navigationController setNavigationBarHidden:NO];
    // Do any additional setup after loading the view.
    _scrllView.backgroundColor = [UIColor clearColor];
    int xPosition = 10;
    int hGap = 10;
    for (int i=0; i<4; i++)
    {
        UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(xPosition, 5, 85, 85)];
        blockView.backgroundColor = [UIColor clearColor];
        blockView.tag = 1001;
        
        UILabel* lblheader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, blockView.bounds.size.width, 30)];
        lblheader.backgroundColor = [UIColor colorWithRed:32/255.0 green:93/255.0 blue:155/255.0 alpha:1.0];
        lblheader.textColor = [UIColor whiteColor];
        lblheader.font = [UIFont systemFontOfSize:15];
        lblheader.textAlignment = NSTextAlignmentCenter;
        lblheader.text = [self getBlockTitle:i];
        lblheader.tag = 1002;
        [blockView addSubview:lblheader];
        
        UILabel* lblTitleEmpty = [[UILabel alloc] initWithFrame:CGRectMake(0, lblheader.frame.origin.y+ lblheader.frame.size.height, blockView.bounds.size.width, 30)];
        lblTitleEmpty.backgroundColor = [UIColor whiteColor];
        lblTitleEmpty.text = @"Empty";
        lblTitleEmpty.font = [UIFont systemFontOfSize:13];
        lblTitleEmpty.textAlignment = NSTextAlignmentCenter;
        [blockView addSubview:lblTitleEmpty];
        
        UILabel* lblVacantSlots = [[UILabel alloc] initWithFrame:CGRectMake(0, lblTitleEmpty.frame.origin.y + lblTitleEmpty.frame.size.height, blockView.bounds.size.width, 21)];
        lblVacantSlots.backgroundColor = [UIColor whiteColor];
        lblVacantSlots.textAlignment = NSTextAlignmentCenter;
        lblVacantSlots.text = @"5";
        lblVacantSlots.font = [UIFont systemFontOfSize:13];
        lblVacantSlots.tag = 1003;
        [blockView addSubview:lblVacantSlots];
        
        [_scrllView addSubview:blockView];
        xPosition = xPosition + blockView.frame.size.width + hGap;
    }
    
    [_scrllView setContentSize:CGSizeMake(xPosition-10, 100)];
    
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionVW.collectionViewLayout = flowLayout;
    
    [ProgressHUD show:@"Loading please wait..."];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [ProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- Helpers
-(void)fillSubviewWithInfo:(NSDictionary*)dic {
    
    NSArray* arrSubviews = [_scrllView subviews];
    
    for (UIView* temp in arrSubviews) {
        
        UILabel* header = [temp viewWithTag:1002];
        UILabel* value = [temp viewWithTag:1003];
        
        //Set values to headerview
    }
    
}

#pragma mark- LayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(15, 15);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    switch (section) {
        case 0:
           return UIEdgeInsetsMake(50, 50, 50, 0);
        case 1:
            return UIEdgeInsetsMake(0, 0, 50, 240);
        case 2:
            return UIEdgeInsetsMake(200, 0, 50, 0);
        case 3:
            return UIEdgeInsetsMake(50, 0, 50, 0);
            
        default:
            break;
    }
    return UIEdgeInsetsMake(50, 0, 50, 0);
}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
//{
//    return 100;
//}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 01;
}

#pragma mark- UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 13
    ;
}

- ( UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifier = @"ParkingCellLayoutIdentifier";
    ParkingCellLayout * cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.lblParkingSlot.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    if (arc4random() % 2==0) {
        cell.lblParkingSlot.backgroundColor = [UIColor lightGrayColor];
    }else{
        [cell.imgCar setImage:[UIImage imageNamed:@"car_top"]];
    }
    cell.imgCar.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end

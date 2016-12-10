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
#import "ParkingItemView.h"
#import "ParkingParser.h"

#define ASCII_VALUE_A   65
#define PARKING_BASESTR_GROUNDFLOOR     "PGF"
@interface ParkingLayoutVC ()

@end

@implementation ParkingLayoutVC

UIView * prevView;

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
    
    [self.scrllView setContentSize:CGSizeMake(xPosition-10, 100)];
    [self.parkingScrollview setContentSize:CGSizeMake(850, 390)];
    [self.parkingScrollview setBackgroundColor:[UIColor lightGrayColor]];
    
//    [self performSelector:@selector(drawParkingLayout) withObject:nil afterDelay:0.5];
    
    [self drawParkingLayout];
    [ProgressHUD show:@"Loading please wait..."];
    
    prevView = _blockViewA;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self response];
    //[self makeAPIRequest];
    [ProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- BarButtonAction
-(IBAction)refreshBarButtonAction:(id)sender{
    [ProgressHUD show:@"Refreshing please wait..."];
    [self.arrLocations removeAllObjects];
    [self response];
    //[self makeAPIRequest];
}

#pragma mark-

-(NSMutableArray*) response{
    NSString* resourcePath = [[NSBundle mainBundle] pathForResource:@"Location" ofType:@"txt"];
    NSFileManager* fmanager = [NSFileManager defaultManager];
    if ([fmanager fileExistsAtPath:resourcePath]) {
        NSData *data = [fmanager contentsAtPath:resourcePath];
        NSError* error = nil;
        NSArray* arrRecords = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(!error){
            NSLog(@"Response = %@",arrRecords);
            self.arrLocations = [NSMutableArray arrayWithArray:[ParkingParser parseLocationData:arrRecords]];
            
            [self fillSubviewWithInfo:nil];
        }
        else{
            NSLog(@"Error Desc: %@",[error debugDescription]);
        }
    }
    return [NSMutableArray new];
}

-(void)drawParkingLayout{
    int blocksCount = 4;
    for (int blockIndex=0; blockIndex<blocksCount; blockIndex++) {
        NSString* baseIdentifier = [NSString stringWithFormat:@"%s%c",PARKING_BASESTR_GROUNDFLOOR,blockIndex+ASCII_VALUE_A];
        
        NSLog(@"%c %d",'A','a');
        int itemwidth = 30;
        int itemHeight = 35;
        int xPos = 0;
        int yPos = itemHeight;
        int itemsCountInAblock = blockIndex==1?10:20;
        
        for (int i=1; i<=itemsCountInAblock; i++) {
            
            ParkingItemView* piv = nil;
            
            NSString* cellId = [NSString stringWithFormat:@"%@%.02d",baseIdentifier,i];
            if(i <= itemsCountInAblock/2){
                piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId];
            }else{
                piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
            });
            
            NSLog(@"Identifer = %@",cellId);
            if(i<=itemsCountInAblock/2){
                xPos= xPos+itemwidth;
                if(i == itemsCountInAblock/2){
                    xPos = 0;
                    yPos = yPos-itemHeight;
                }
            }else{
                xPos = xPos + itemwidth;
            }
            piv.tag = i;
            
            piv.layer.borderWidth = 0.5;
            piv.layer.borderColor = [UIColor blackColor].CGColor;
//            NSLog(@"object =%@ %@ %@",piv.lblParkingNo,piv.imageView, piv.button);
            
            switch (blockIndex) {
                case 0:
                    [self.blockViewA addSubview:piv];
                    break;
                case 1:
                    [self.blockViewB addSubview:piv];
                    break;
                case 2:
                    [self.blockViewC addSubview:piv];
                    break;
                case 3:
                    [self.blockViewD addSubview:piv];
                    break;
                    
                default:
                    break;
            }
        }
        
    }
}

-(UIView*)containerBlockViewWithIdentifier:(NSString*)identifier{
     UIView* containerView = [identifier rangeOfString:@"A"].length>0?self.blockViewA:[identifier rangeOfString:@"B"].length>0?self.blockViewB:[identifier rangeOfString:@"C"].length>0?self.blockViewC:[identifier rangeOfString:@"D"].length>0?self.blockViewD:nil;
    NSLog(@"Container View Tag: %d",(int)containerView.tag);
    return containerView;
}

-(ParkingItemView*)viewWithIdentifier:(NSString*)cellId index:(int)index {
    
    UIView* containerView = [cellId rangeOfString:@"A"].length>0?self.blockViewA:[cellId rangeOfString:@"B"].length>0?self.blockViewB:[cellId rangeOfString:@"C"].length>0?self.blockViewC:[cellId rangeOfString:@"D"].length>0?self.blockViewD:nil;
    NSLog(@"Conainter tag = %d",(int)containerView.tag);
    
    if (containerView.tag == 0) {
        return nil;
    }
    
    
    NSMutableArray *arrItemViews = [[containerView subviews] mutableCopy];
//    NSMutableArray* arrItemViews = [NSMutableArray new];
//    for (id view in arrSubViews) {
//        if([view isMemberOfClass:[UILabel class]]){
//            [arrItemViews removeObject:view];
//            continue;
//        }else{
//            [arrItemViews addObject:view];
//        }
//    }
    
//    NSArray* arrCellIds = [arrItemViews valueForKey:@"cellID"];
//    int index = (int)[arrCellIds indexOfObject:cellId];
//    NSLog(@"index of %@ =%d",cellId,index);
    return ((ParkingItemView*)[arrItemViews objectAtIndex:index]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark- API Call
-(void)showAlert:(NSError*)error {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error debugDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

-(void)makeAPIRequest{
    [ProgressHUD show:@"Loading please wait..."];
    NSURL *url = [NSURL URLWithString:@"http://192.168.1.101:3000/api/sensors?"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // check for an error. If there is a network error, you should handle it here.
    if(error)
    {
        //log response
        [self showAlert:error];
    }
    else{
        NSError* serverError = nil;
        NSArray* arrRecords = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
        
        if(!serverError){
            NSLog(@"Response = %@",arrRecords);
            self.arrLocations = [NSMutableArray arrayWithArray:[ParkingParser parseLocationData:arrRecords]];
            
            [self fillSubviewWithInfo:nil];
        }
        else{
            NSLog(@"Error Desc: %@",[error debugDescription]);
            [self showAlert:error];
        }

    }
    [ProgressHUD dismiss];
}


#pragma mark- Helpers

-(int)getEmptyParkingSlots:(NSArray*)dataArray {
    
    NSPredicate *emptyPredicate = [NSPredicate predicateWithFormat:@"SELF.occupied == 0"];
    NSArray* filteredArr = [dataArray filteredArrayUsingPredicate:emptyPredicate];
    return ((int)[filteredArr count]);
    
}

-(void)disclaimerInfoForBlockContainers{
    
    NSPredicate *emptyPredicate = [NSPredicate predicateWithFormat:@"SELF.occupied contains[cd] %@",@"no"];
    
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"A"];
    NSArray* arrBlockA = [self.arrLocations filteredArrayUsingPredicate:aPredicate];
    NSArray* emptyInBlockA = [arrBlockA filteredArrayUsingPredicate:emptyPredicate];
    
    NSLog(@"HERE %ld \t emptyCountInA=%ld",arrBlockA.count,[emptyInBlockA count]);
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"B"];
    NSArray* arrBlockB = [self.arrLocations filteredArrayUsingPredicate:bPredicate];
    NSArray* emptyInBlockB = [arrBlockB filteredArrayUsingPredicate:emptyPredicate];
    
    NSLog(@"HERE %ld \t emptyCountInB=%ld",arrBlockB.count,[emptyInBlockB count]);
    
    
    NSPredicate *cPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"C"];
    NSArray* arrBlockC = [self.arrLocations filteredArrayUsingPredicate:cPredicate];
    NSArray* emptyInBlockC = [arrBlockC filteredArrayUsingPredicate:emptyPredicate];
    NSLog(@"HERE %ld \t emptyCountInC=%ld",arrBlockC.count,[emptyInBlockC count]);

    
    
    NSPredicate *dPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"D"];
    NSArray* arrBlockD = [self.arrLocations filteredArrayUsingPredicate:dPredicate];
    NSArray* emptyInBlockD = [arrBlockD filteredArrayUsingPredicate:emptyPredicate];
    NSLog(@"HERE %ld \t emptyCountInD=%ld",arrBlockD.count,[emptyInBlockD count]);

    
//    NSArray* arrBlockB = [self.arrLocations valueForKey:@"B"];
//    NSArray* arrBlockC = [self.arrLocations valueForKey:@"C"];
//    NSArray* arrBlockD = [self.arrLocations valueForKey:@"D"];
    
}

-(void)fillSubviewWithInfo:(NSDictionary*)dic {
    
    NSMutableArray* data = self.arrLocations;
    
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"A"];
    NSArray* arrBlockA = [data filteredArrayUsingPredicate:aPredicate];
    
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"B"];
    NSArray* arrBlockB = [data filteredArrayUsingPredicate:bPredicate];
    
    NSPredicate *cPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"C"];
    NSArray* arrBlockC = [data filteredArrayUsingPredicate:cPredicate];
    
    NSPredicate *dPredicate = [NSPredicate predicateWithFormat:@"SELF.block contains[cd] %@",@"D"];
    NSArray* arrBlockD = [data filteredArrayUsingPredicate:dPredicate];
    
    NSLog(@"Counts A=%ld \tB=%ld \t C=%ld \t D=%ld",[arrBlockA count],[arrBlockB count],[arrBlockC count],[arrBlockD count]);
    
    NSArray *arrBlocks = [NSArray arrayWithObjects:arrBlockA,arrBlockB,arrBlockC,arrBlockD, nil];
    
    NSArray* arrSubviews = [_scrllView subviews];
    
    int index =0;
    for (id tempview in arrSubviews) {
        
        if([tempview isMemberOfClass:[UIView class]]){
            UILabel* value = [((UIView*)tempview) viewWithTag:1003];
            
            int count = [self getEmptyParkingSlots:[arrBlocks objectAtIndex:index]];
            [value setText:[NSString stringWithFormat:@"%d",count]];
            index++;
        }else{
            continue;
        }
        //UILabel* header = [temp viewWithTag:1002];
                //Set values to headerview
    }
    
    
    for (int block=0; block<arrBlocks.count; block++) {
    
        NSArray* dataArray = [arrBlocks objectAtIndex:block];
        
        for (int index = 0; index<dataArray.count; index++) {
            Parking* p = [dataArray objectAtIndex:index];
            ParkingItemView* view = [self viewWithIdentifier:p.cellId index:index];
            if (p.occupied ) {
                NSLog(@"occupied tag =%ld",view.tag);
                if(view.tag >=1 && view.tag <= [dataArray count]/2){
                    [view.imageView setImage:[UIImage imageNamed:@"car_bottom.png"]];
                    view.backgroundColor = [UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:0.5];
                }else{
                    [view.imageView setImage:[UIImage imageNamed:@"car_top.png"]];
                }
                view.backgroundColor = [UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:0.5];
            }else{
                NSLog(@"NOt occupied tag =%ld",view.tag);
                [view.imageView setImage:nil];
                view.backgroundColor = [UIColor colorWithRed:102/255.0 green:255/255.0 blue:102/255.0 alpha:0.5];
            }
        }
    }
    
    [ProgressHUD dismiss];
    

    
}

/*
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
*/
@end

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
#import "CustomPathDrawer.h"

//#define Test

#define ASCII_VALUE_A   65
#define PARKING_BASESTR_GROUNDFLOOR     "PGF"
#define BASE_URL        "http://192.168.1.105:3000/"

#define BASE_URL_RFID_1     @"http://172.20.10.12:1234/"
#define BASE_URL_RFID_2     @"http://172.20.10.11:1234/"
#define BASE_URL_RFID_3     @"http://172.20.10.13:1234/"

#define MESSAGE_RFID_CHECKPOINT_1       @"point 1 reached"
#define MESSAGE_RFID_CHECKPOINT_2       @"point 2 reached"
#define MESSAGE_RFID_CHECKPOINT_3       @"point 3 reached"

#define RFID_CAR_ANIMATION_DURATION     0.3
#define SELECTOR_DURATION               0.2

#define COLOR_PHYSICALLY_HANDICAPPED_PARKING        [UIColor colorWithRed:0/255.0 green:0/255.0 blue:193/255.0 alpha:0.5]
#define COLOR_RESERVERD_PARKING             [UIColor colorWithRed:255/255.0 green:182/255.0 blue:193/255.0 alpha:1]
static int startPosY ;
static int startPosY1 ;
static int finalXPos;
static int startXPos;
@interface ParkingLayoutVC ()<ParkingItemViewDelegate,CAAnimationDelegate>
@property(nonatomic,strong) CustomPathDrawer* cp;
@end

@implementation ParkingLayoutVC

UIView * prevView;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cp = nil;
    
    startPosY = SP_START_POINT.y;
    startPosY1 = SP_CHECK_POINT_4.y;
    startXPos = SP_CHECK_POINT_4.x;
    finalXPos = 265;
    isTrackSuggestedPath = TRUE;
    //TEsting
#ifdef Test
    checkPoint1_RFID = true;
#endif
    
    imageViewCar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"track_top_car.png"]];
    [imageViewCar setFrame:CGRectMake(SP_START_POINT.x, SP_START_POINT.y, 11, 28)];
    [self.parkingScrollview addSubview:imageViewCar];
    [self.parkingScrollview bringSubviewToFront:imageViewCar];
    [imageViewCar setHidden:true];
    
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
    
//    [self drawParkingLayout];
    [self drawLayoutForParkingArea];
    [ProgressHUD show:@"Loading please wait..."];
    
    prevView = _blockViewA;
    
#ifndef Test
    //Code should get executed if working on live environment
    layoutTimer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if (self.cp) {
            [self.cp removeLayer];
            self.cp = nil;
        }
        if (movingLayer!= nil) {
            [movingLayer removeFromSuperlayer];
        }
        [self getParkingDataFromServer];
    }];
    
    timerRFID = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(validateIfCarIsPlacedOnRFIDSensor) userInfo:nil repeats:YES];
#endif
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
#ifdef  Test
        NSLog(@"Test Environment");
        [self dataFromLocal];
#else
        NSLog(@"Live");
//        [self getParkingDataFromServer];
    [self dataFromLocal];
#endif
    [ProgressHUD dismiss];
    
    
}

-(void)viewDidDisappear:(BOOL)animated{
    if (layoutTimer) {
        [layoutTimer invalidate];
        layoutTimer = nil;
    }
    if (timerRFID) {
        [timerRFID invalidate];
        timerRFID = nil;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- BarButtonAction
-(IBAction)refreshBarButtonAction:(id)sender{
    if(self.cp){
        [self.cp removeLayer];
    }
    [ProgressHUD show:@"Refreshing please wait..."];
    [self.arrLocations removeAllObjects];
    //[self response];
    [self getParkingDataFromServer];
}

#pragma mark-

-(NSMutableArray*) dataFromLocal{
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
            [self performSelector:@selector(drawSuggestedPathWithIdentifier:) withObject:@"PGFB07" afterDelay:1];
        }
        else{
            NSLog(@"Error Desc: %@",[error debugDescription]);
        }
    }
    return self.arrLocations;
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
                piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
            }else{
                piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
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

#pragma mark- RFID_Path

-(void)followRFID{
    
    if (isTrackSuggestedPath) {
        
        if (checkPoint1_RFID) {
            
            //move towards point 2
            if (startPosY > startPosY1) {
                imageViewCar.hidden = false;
                [UIView animateWithDuration:RFID_CAR_ANIMATION_DURATION animations:^{
                    startPosY = startPosY-5;
                    [imageViewCar setFrame:CGRectMake(SP_START_POINT.x, startPosY, 11, 28)];
#ifdef Test
                    NSLog(@"Test");
#else
                    [self checkPointServiceRFID];
#endif
                    [self performSelector:@selector(followRFID) withObject:nil afterDelay:SELECTOR_DURATION];
                }];
            }else{
#ifdef Test
                checkPoint2_RFID = true;
#else
                if(!checkPoint2_RFID){
                    [self checkPointServiceRFID];
                    [self performSelector:@selector(followRFID) withObject:nil afterDelay:SELECTOR_DURATION];
                }
#endif
            }
            
            if (checkPoint2_RFID) {
                //stop timer for 1 point;
                //directly move towards 2nd point
                startPosY = startPosY1;
                if (startXPos <= finalXPos) {
                    [imageViewCar setImage:[UIImage imageNamed:@"small_car.png"]];
                    [imageViewCar setFrame:CGRectMake(startXPos, startPosY1, 32, 13)];
                    [UIView animateWithDuration:RFID_CAR_ANIMATION_DURATION animations:^{
                        startXPos = startXPos+5;
                        [imageViewCar setFrame:CGRectMake(startXPos, startPosY1, 32, 13)];
#ifdef Test
                        NSLog(@"TEst");
#else
                        [self checkPointServiceRFID];
#endif
                        [self performSelector:@selector(followRFID) withObject:nil afterDelay:SELECTOR_DURATION];
                    }];
                }else{
#ifdef Test
                    checkPoint3_RFID = true;
#else
                    if(!checkPoint3_RFID){
                        [self checkPointServiceRFID];
                        [self performSelector:@selector(followRFID) withObject:nil afterDelay:SELECTOR_DURATION];
                    }
#endif
                }
                
                if(checkPoint3_RFID){
                    checkPoint1_RFID = FALSE;
                    checkPoint2_RFID = FALSE;
                    checkPoint3_RFID = FALSE;
                    isTrackSuggestedPath = FALSE;
                    //stop timer for 2nd point
                    //move to final destination
                    [imageViewCar setImage:[UIImage imageNamed:@"track_top_car.png"]];
                    [imageViewCar setFrame:CGRectMake(startXPos, startPosY1, 11, 28)];
                    [UIView animateWithDuration:RFID_CAR_ANIMATION_DURATION animations:^{
                        startXPos = finalXPos;
                        [imageViewCar setFrame:CGRectMake(finalXPos, startPosY1+24, 11, 28)];
#ifdef Test
                        
#else
                        [self performSelector:@selector(getParkingDataFromServer) withObject:nil afterDelay:5];
#endif
                         [self performSelector:@selector(removePathLayersFromSuperview) withObject:nil afterDelay:5];
                        
                        
                    }];
                    
                }else{
                    //call service for 3rd point
#ifdef Test
                    //checkPoint3_RFID = true;
#else
                    //                if (startXPos >= finalXPos) {
                    //                NSLog(@"calling from sensor 2");
                    //                    [self checkPointServiceRFID];
                    //                }
#endif
                }
                
            }else{
                //call checkpoint 2 service
#ifdef Test
                //checkPoint2_RFID = FALSE;
#else
                
#endif
                
            }
            
        }else{
            //call checkpoint 1 service
#ifndef Test
            [self checkPointServiceRFID];
            [self performSelector:@selector(followRFID) withObject:nil afterDelay:SELECTOR_DURATION];
#endif
        }
    }
}



#pragma mark- NEW UI


-(void)drawSuggestedPathWithIdentifier:(NSString*)identifier {
    
    

        
        
    
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Available Parking !!" message:[NSString stringWithFormat:@"Suggested parking space for you \"%@\"",identifier] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction * done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UIView* containerView = [self containerBlockViewWithIdentifier:identifier];
            //                    int index = [self indexFromIdentifer:emptySlotIdentifer];
            dispatch_async(dispatch_get_main_queue(), ^{
                int index = [self indexFromIdentiferForNewLayout:identifier];
                ParkingItemView* itemView = [self viewWithIdentifier:identifier index:index];
                
                if(self.cp){
                    [self.cp removeLayer];
                }
                
                int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
                self.cp = [[CustomPathDrawer alloc] init];
                [self.cp drawPathOnLayer:self.parkingScrollview.layer FromView:containerView toItem:itemView totalSlots:slots isSuggestedPath:YES];
                
                [self followRFID];
            });
        }];
        
        [alert addAction:done];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    
    
    /*
    UIView* containerView = [self containerBlockViewWithIdentifier:identifier];
    int index = [self indexFromIdentiferForNewLayout:identifier];
    ParkingItemView* itemView = [self viewWithIdentifier:identifier index:index];
    
    if(self.cp){
        [self.cp removeLayer];
    }
    
    int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
    self.cp = [[CustomPathDrawer alloc] init];
    [self.cp drawPathOnLayer:self.parkingScrollview.layer FromView:containerView toItem:itemView totalSlots:slots isSuggestedPath:YES];
    [self followRFID];*/
}
-(int)indexFromIdentiferForNewLayout:(NSString*)identifier{
    
    UIView* containerView = [self containerBlockViewWithIdentifier:identifier];
//    int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
    
    int index = 0;
    NSString* substring = @"";
    if (identifier.length>=6) {
        substring = [identifier substringFromIndex:4];
        index = [substring intValue];
    }
    NSLog(@"Before .. Index of path for suggested parking slot =%d",index);
    switch (containerView.tag) {
        case 1:
            //A
            index = index > 8 ? index+2: index;
            break;
        case 2:
            //A
            break;
        case 3:
            //A
            index = index > 2 ? index+2: index;
            break;
        case 4:
            //A
            break;
            
        default:
            break;
    }
    NSLog(@"After .. Index of path for suggested parking slot =%d",index-1);
    return index-1;
}


-(void)drawLayoutForParkingArea {
    int blocksCount = 4;
    for (int blockIndex=0; blockIndex<blocksCount; blockIndex++) {
        NSString* baseIdentifier = [NSString stringWithFormat:@"%s%c",PARKING_BASESTR_GROUNDFLOOR,blockIndex+ASCII_VALUE_A];
        
        NSLog(@"%c %d",'A','a');
        int itemwidth = 30;
        int itemHeight = 35;
        int xPos = 0;
        int yPos = itemHeight;
        
        int itemsCountInAblock = blockIndex==0?18:blockIndex==1?10:blockIndex==2?20:20;
        
        for (int i=1; i<=itemsCountInAblock; i++) {
            
            ParkingItemView* piv = nil;
            
            NSString* cellId = [NSString stringWithFormat:@"%@%.02d",baseIdentifier,i];
            
            if (blockIndex == 0) {
                //Block A construction
                
                if(i <= ((itemsCountInAblock/2)+1)){
                    
                    if (i<=8) {
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
                    }else if (i==9){
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:@"PGFAPH" delegate:self];
                        piv.lblParkingNo.backgroundColor = COLOR_PHYSICALLY_HANDICAPPED_PARKING;
                        piv.lblParkingNo.text = @"PH";
                        piv.button.userInteractionEnabled =FALSE;
                    }else if (i==10){
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:@"PGFARP" delegate:self];
                        piv.lblParkingNo.backgroundColor = COLOR_RESERVERD_PARKING;
                        piv.lblParkingNo.text = @"RP";
                        piv.button.userInteractionEnabled =FALSE;
                    }
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
//                    });
                    
                }else{
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i-2]];
                    });
                }
            }else if (blockIndex == 1) {
                //Block B construction
                
                if(i <= ((itemsCountInAblock/2)+1)){
                    
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
                    });
                    
                }else{
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
                    });
                }

            }else if (blockIndex == 2) {
                //Block B construction
                
                if(i <= ((itemsCountInAblock/2)+1)){
                    
                    if (i==1) {
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                        piv.lblParkingNo.backgroundColor = COLOR_RESERVERD_PARKING;
                        piv.lblParkingNo.text = @"RP";
                        piv.button.userInteractionEnabled =FALSE;
                    }else if (i==2){
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                        piv.lblParkingNo.backgroundColor = COLOR_PHYSICALLY_HANDICAPPED_PARKING;
                        piv.lblParkingNo.text = @"PH";
                        piv.button.userInteractionEnabled =FALSE;
                    }else if (i>2){
                        piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i-2]];
                    }
                }else{
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i-2]];
                    });
                }
                
            }
            
            else{
                if(i <= itemsCountInAblock/2){
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                }else{
                    piv = [[ParkingItemView alloc] initWithFrame:CGRectMake(xPos, yPos, itemwidth, itemHeight) occupied:NO identifier:cellId delegate:self];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [piv.lblParkingNo setText:[NSString stringWithFormat:@"%d",i]];
                });
            }
            
            
            
            NSLog(@"Identifer = %@",cellId);
            
            if (blockIndex == 0 || blockIndex == 1) {
                if(i<=((itemsCountInAblock/2)+1)){
                    xPos= xPos+itemwidth;
                    if(i == ((itemsCountInAblock/2)+1)){
                        xPos = itemwidth*2;
                        yPos = yPos-itemHeight;
                    }
                    if (i<=8) {
                        piv.tag = i;
                    }else{
                        piv.tag = -1;
                    }
                    
                }else{
                    xPos = xPos + itemwidth;
                    if (blockIndex == 0) {
                        piv.tag = i-2;
                    }else{
                        piv.tag = i;
                    }
                }
            }else if(blockIndex == 2){
                if(i<=itemsCountInAblock/2){
                    xPos= xPos+itemwidth;
                    if(i == itemsCountInAblock/2){
                        xPos = 0;
                        yPos = yPos-itemHeight;
                    }
                    
                }else{
                    xPos = xPos + itemwidth;
                }
                piv.tag = i-2;
            }
            
            else{
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
            }
            
            
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



#pragma mark- API Call

-(void)validateIfCarIsPlacedOnRFIDSensor{

    //An alert will be shown to user with available parking slot no., when a car is placed on RFID Sensor i.e. EntryGate
    
    NSURL *url = [NSURL URLWithString:BASE_URL_RFID_1];
    
    __block NSError* serverError = nil;
    
    [self sendRequestToServer:url completionHander:^(NSData *responseData, NSError *error) {
        if (error) {
            NSLog(@"url = %@ Error=%@",url,[error debugDescription]);
        }else{
            if (responseData != nil) {
                
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
                
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    
                    NSString* message = [dict valueForKey:@"message"];
                    
                    if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_1]) {
                        
                        [self getSuggestedParkingSlots];
                        
                        if (timerRFID.isValid) {
                            [timerRFID invalidate];
                            
                        }
                    }
                }
            }else{
                NSLog(@"Data nil");
            }
        }
    }];
    
//    if (responseData != nil) {
//        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
//        
//        if ([dict isKindOfClass:[NSDictionary class]]) {
//            
//            NSString* message = [dict valueForKey:@"message"];
//            
//            if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_1]) {
//                
//                [self getSuggestedParkingSlots];
//                
//                if (timerRFID.isValid) {
//                    [timerRFID invalidate];
//                    
//                }
//            }
//        }
//    }else{
//        NSLog(@"Data nil");
//    }
    //[self getSuggestedParkingSlots];
}


-(NSData*)sendRequestToServer:(NSURL*)url {
    
    //Method takes input as URL, and returns the response
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        return nil;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (connectionError != nil) {
            //call block
        }else{
            //passnil
        }
        
    }];
    
    return responseData;
}

-(void)sendRequestToServer:(NSURL*)url completionHander:(void(^)(NSData* responseData,NSError* error))completionHander{
 
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        if (connectionError == nil) {
            //call block
            completionHander(data,nil);
        }else{
            //passnil
            NSLog(@"Error =%@",[connectionError debugDescription]);
            completionHander(nil,connectionError);
        }
    }];
}

-(void)getSuggestedParkingSlots{
    //api/sort/ground/A1
    [ProgressHUD show:@"Loading please wait..."];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@",BASE_URL,@"api/sort/ground/B2?"] ];
    
    [self sendRequestToServer:url completionHander:^(NSData *responseData, NSError *error){
        if(error)
        {
            //log response
            [self showAlert:error];
        }
        else{
            
            if (responseData != nil) {
                NSError* serverError = nil;
                NSArray* arrRecords = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
                
                if(!serverError){
                    NSLog(@"Response = %@",arrRecords);
                    if ([arrRecords count]>0) {
                        
                        
                        NSDictionary* response = [arrRecords objectAtIndex:0];
                        NSString* emptySlotIdentifer = [response valueForKey:@"_id"];
                        
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Available Parking !!" message:[NSString stringWithFormat:@"Suggested parking space for you \"%@\"",emptySlotIdentifer] preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            
                        }];
                        
                        UIAlertAction * done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            
                            UIView* containerView = [self containerBlockViewWithIdentifier:emptySlotIdentifer];
                            //                    int index = [self indexFromIdentifer:emptySlotIdentifer];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                int index = [self indexFromIdentiferForNewLayout:emptySlotIdentifer];
                                ParkingItemView* itemView = [self viewWithIdentifier:emptySlotIdentifer index:index];
                                
                                if(self.cp){
                                    [self.cp removeLayer];
                                }
                                
                                int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
                                self.cp = [[CustomPathDrawer alloc] init];
                                [self.cp drawPathOnLayer:self.parkingScrollview.layer FromView:containerView toItem:itemView totalSlots:slots isSuggestedPath:YES];
                                
                                [self followRFID];
                            });
                        }];
                        
                        [alert addAction:done];
                        [alert addAction:cancel];
                        [self presentViewController:alert animated:YES completion:^{
                            
                        }];
                    }
                    
                    [self fillSubviewWithInfo:nil];
                }
                else{
                    NSLog(@"Error Desc: %@",[error debugDescription]);
                    [self showAlert:error];
                }
            }else{
                NSLog(@"GetParkingSlot response data nil");
            }
        }
    }];
    
    
//    if(error)
//    {
//        //log response
//        [self showAlert:error];
//    }
//    else{
//        
//        if (responseData != nil) {
//            NSError* serverError = nil;
//            NSArray* arrRecords = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
//            
//            if(!serverError){
//                NSLog(@"Response = %@",arrRecords);
//                if ([arrRecords count]>0) {
//                    
//                    
//                    NSDictionary* response = [arrRecords objectAtIndex:0];
//                    NSString* emptySlotIdentifer = [response valueForKey:@"_id"];
//                    
//                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Available Parking !!" message:[NSString stringWithFormat:@"Suggested parking space for you \"%@\"",emptySlotIdentifer] preferredStyle:UIAlertControllerStyleAlert];
//                    
//                    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                        
//                    }];
//                    
//                    UIAlertAction * done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        
//                        UIView* containerView = [self containerBlockViewWithIdentifier:emptySlotIdentifer];
//                        //                    int index = [self indexFromIdentifer:emptySlotIdentifer];
//                        int index = [self indexFromIdentiferForNewLayout:emptySlotIdentifer];
//                        ParkingItemView* itemView = [self viewWithIdentifier:emptySlotIdentifer index:index];
//                        
//                        if(self.cp){
//                            [self.cp removeLayer];
//                        }
//                        
//                        int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
//                        self.cp = [[CustomPathDrawer alloc] init];
//                        [self.cp drawPathOnLayer:self.parkingScrollview.layer FromView:containerView toItem:itemView totalSlots:slots isSuggestedPath:YES];
//                        
//                        //                  [self moveObjectOnBezierPath:containerView];
//                        [self followRFID];
//                        
//                    }];
//                    
//                    [alert addAction:done];
//                    [alert addAction:cancel];
//                    [self presentViewController:alert animated:YES completion:^{
//                        
//                    }];
//                }
//                
//                [self fillSubviewWithInfo:nil];
//            }
//            else{
//                NSLog(@"Error Desc: %@",[error debugDescription]);
//                [self showAlert:error];
//            }
//        }else{
//            NSLog(@"GetParkingSlot response data nil");
//        }
//    }
    [ProgressHUD dismiss];
    
}

-(void)getParkingDataFromServer{
    
    [ProgressHUD show:@"Loading please wait..."];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@",BASE_URL,@"api/sensors"]];
    
    [self sendRequestToServer:url completionHander:^(NSData *responseData, NSError *error) {
        
        if(error)
        {
            //log response
            [self showAlert:error];
        }
        else{
            
            if(responseData != nil){
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
            }else{
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Trouble in connecting with server." forKey:NSLocalizedDescriptionKey];
                // populate the error object with the details
                NSError *error = [NSError errorWithDomain:@"Error" code:200 userInfo:details];
                [self showAlert:error];
            }
        }
    }];
    
//    NSData *responseData = [self sendRequestToServer:url];
//    if(error)
//    {
//        //log response
//        [self showAlert:error];
//    }
//    else{
//        
//        if(responseData != nil){
//            NSError* serverError = nil;
//            NSArray* arrRecords = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
//            
//            if(!serverError){
//                NSLog(@"Response = %@",arrRecords);
//                self.arrLocations = [NSMutableArray arrayWithArray:[ParkingParser parseLocationData:arrRecords]];
//                
//                [self fillSubviewWithInfo:nil];
//                
//            }
//            else{
//                NSLog(@"Error Desc: %@",[error debugDescription]);
//                [self showAlert:error];
//            }
//        }else{
//            NSMutableDictionary* details = [NSMutableDictionary dictionary];
//            [details setValue:@"Trouble in connecting with server." forKey:NSLocalizedDescriptionKey];
//            // populate the error object with the details
//            NSError *error = [NSError errorWithDomain:@"Error" code:200 userInfo:details];
//            [self showAlert:error];
//        }
//
//    }
    [ProgressHUD dismiss];
}

#pragma mark -
-(void)checkPointServiceRFID {
    
    //Initiate a request to server asking for RFID sensor's data for different checkpoints one by one
    
    NSString * baseURL = @"";
    if (!checkPoint1_RFID) {
        baseURL = BASE_URL_RFID_1;
    }else if(!checkPoint2_RFID){
        baseURL = BASE_URL_RFID_2;
    }else if (!checkPoint3_RFID){
        baseURL = BASE_URL_RFID_3;
    }
    NSLog(@"Base URL RFID=%@",baseURL);
    NSURL *url = [NSURL URLWithString:baseURL];
//    NSData *responseData = [self sendRequestToServer:url];
//    NSError* serverError = nil;
//    if (responseData != nil) {
//        NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
//        
//        if ([dict isKindOfClass:[NSDictionary class]]) {
//            
//            NSString* message = [dict valueForKey:@"message"];
//            NSLog(@"Response message =%@",message);
//            if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_1]) {
//                checkPoint1_RFID = true;
//                [self performSelector:@selector(followRFID) withObject:nil afterDelay:0.1];
//            }
//            else if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_2]) {
//                checkPoint2_RFID = true;
//                [self performSelector:@selector(followRFID) withObject:nil afterDelay:0.1];
//            }
//            else if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_3]) {
//                checkPoint3_RFID = true;
//            }
//            
//        }
//    }else{
//        NSLog(@"Data nil");
//    }
    
    [self sendRequestToServer:url completionHander:^(NSData *responseData, NSError *error) {
        
        if (error) {
            
        }else{
            if (responseData != nil) {
                NSError* serverError = nil;
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&serverError];
                
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    
                    NSString* message = [dict valueForKey:@"message"];
                    NSLog(@"Response message =%@",message);
                    if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_1]) {
                        checkPoint1_RFID = true;
                        [self performSelector:@selector(followRFID) withObject:nil afterDelay:0.1];
                    }
                    else if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_2]) {
                        checkPoint2_RFID = true;
                        [self performSelector:@selector(followRFID) withObject:nil afterDelay:0.1];
                    }
                    else if (message != nil && [message isEqualToString:MESSAGE_RFID_CHECKPOINT_3]) {
                        checkPoint3_RFID = true;
                        NSLog(@"RFID Sensor 3 message = %@",message);
                    }
                    
                }
            }else{
                NSLog(@"RFID responseData is NIL...");
            }
        }
    }];
    
}

#pragma mark- Alert
-(void)showAlert:(NSError*)error {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:[error debugDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * done = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:done];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}


#pragma mark- Timer



#pragma mark- Helpers

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


-(void)moveObjectOnBezierPath:(UIView*)containerView{
    
    UIImage *movingImage = [UIImage imageNamed:@"small_car.png"];
    movingLayer = [CALayer layer];
    movingLayer.contents = (id)movingImage.CGImage;
    movingLayer.anchorPoint = CGPointZero;
    
    movingLayer.frame = CGRectMake(0.0f, 0.0f, movingImage.size.width, movingImage.size.height);
    [self.parkingScrollview.layer addSublayer:movingLayer];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.delegate = self;
    pathAnimation.duration = containerView.tag == 1?8.0:containerView.tag == 2?12.0:containerView.tag == 3?15.0:20.0;
    pathAnimation.path = [self.cp getPath].CGPath;
    pathAnimation.rotationMode = kCAAnimationRotateAuto;
    pathAnimation.calculationMode = kCAAnimationLinear;
    
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = false;
    
    [movingLayer addAnimation:pathAnimation forKey:@"movingAnimation"];
}

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

-(int)indexFromIdentifer:(NSString*)identifier{
    
    int index = 0;
    if (identifier.length>=6) {
        NSString* substring = [identifier substringFromIndex:4];
        index = [substring intValue];
    }
    return index-1;
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
            
            if (block == 0 && index >8) {
                view = [self viewWithIdentifier:p.cellId index:index+2];
            }
            else if (block == 2 ){
                view = [self viewWithIdentifier:p.cellId index:index+2];
            }
            
            
            if (p.occupied && view.tag >=
                1) {
                NSLog(@"occupied tag =%ld",view.tag);
                if(view.tag >=1 && view.tag <= [dataArray count]/2){
                    [view.imageView setImage:[UIImage imageNamed:@"car_bottom.png"]];
                }else{
                    [view.imageView setImage:[UIImage imageNamed:@"car_top.png"]];
                }
                view.button.userInteractionEnabled = false;
                view.backgroundColor = [UIColor colorWithRed:255/255.0 green:0 blue:0 alpha:0.5];
            }else{
                NSLog(@"NOt occupied tag =%ld",view.tag);
                view.button.userInteractionEnabled = true;
                [view.imageView setImage:nil];
                view.backgroundColor = [UIColor colorWithRed:102/255.0 green:255/255.0 blue:102/255.0 alpha:0.5];
            }
        }
    }
    
    [ProgressHUD dismiss];
}
#pragma mark-
-(void)removePathLayersFromSuperview{
    if (self.cp) {
        [self.cp removeLayer];
    }
    if (movingLayer) {
        [movingLayer removeFromSuperlayer];
    }
    if (imageViewCar && !imageViewCar.isHidden) {
        [imageViewCar setHidden:true];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self performSelector:@selector(removePathLayersFromSuperview) withObject:nil afterDelay:0.5];
    [self.view setUserInteractionEnabled:true];
}

#pragma mark- ParkingItemViewDelegate 
-(void)containerView:(UIView *)containerView item:(id)itemView itemClickedAtIndex:(NSInteger)index{
    
    if(self.cp){
        [self.cp removeLayer];
    }
    
    int slots = containerView.tag == 1?16:containerView.tag==2?10:containerView.tag==3?18:20;
    self.cp = [[CustomPathDrawer alloc] init];
    [self.cp drawPathOnLayer:self.parkingScrollview.layer FromView:containerView toItem:itemView totalSlots:slots isSuggestedPath:NO];
    [self moveObjectOnBezierPath:containerView];
    
    
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

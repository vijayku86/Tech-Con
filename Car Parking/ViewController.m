//
//  ViewController.m
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "ViewController.h"
#import "ProgressHUD.h"
#import "ParkingCell.h"
# import "PNChart.h"

#define PieChartWidth    240
#define PieChartHeight   240


@interface ViewController ()<PNChartDelegate>

@end

@implementation ViewController

-(NSDictionary*)dictWithName:(NSString*)name slots:(NSString*)slots occupied:(NSString*)percent{
    return [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",slots,@"slots",percent,@"percent", nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrParkingInfo = [NSMutableArray arrayWithObjects:
                           [self dictWithName:@"Ground Floor" slots:@"104" occupied:@"35"],
                           [self dictWithName:@"First Floor" slots:@"125" occupied:@"65"],
                           [self dictWithName:@"Second Floor" slots:@"105" occupied:@"85"],
                           nil];
    
    [ProgressHUD show:@"Loading praking info \n please wait..."];
    
    NSLog(@"Array =%@",[self.arrParkingInfo valueForKey:@"name"]);
    
    //[self makeAPIRequest];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:0.5];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark- UINavigationBarButtonAction

- (void)dismissHUD{
    [ProgressHUD dismiss];
}

-(IBAction)refreshAction:(id)sender{
    [ProgressHUD show:@"Loading praking info \n please wait..."];
    //Refresh Logic goes here
    
    [self.tblParkingsView reloadData];
    [self performSelector:@selector(dismissHUD) withObject:nil afterDelay:0.5];
}


#pragma mark- UITableViewDelegate- UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arrParkingInfo count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"ParkingCellIdentifier";
    ParkingCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    if(!cell){
        return nil;
    }
    NSDictionary* dic = [self.arrParkingInfo objectAtIndex:indexPath.row];
    cell.lblParkingLocation.text = [dic objectForKey:@"name"];
    cell.lblParkingSlots.text = [dic objectForKey:@"slots"];
    
    float percent = ([[dic objectForKey:@"percent"] floatValue]/[[dic objectForKey:@"slots"] floatValue])*100;
    
    cell.lblParkingPercentInformation.text = [NSString stringWithFormat:@"%2.0f%% Occupied",roundf(percent)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.arrParkingInfo count]>indexPath.row) {
        [self performSegueWithIdentifier:@"showParkingLayoutDetails" sender:nil];
    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGRect bounds = tableView.bounds;
    if(!tableHeaderView){
        tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), 300)];
        tableHeaderView.backgroundColor = [UIColor clearColor];
        
        pieChart = [self refreshPieChart];
        
        [tableHeaderView addSubview:pieChart];
    }
    return tableHeaderView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 300;
}

#pragma mark- PieHelpers 
-(PNPieChart*)refreshPieChart {
    if (pieChart) {
        [pieChart  removeFromSuperview];
    }
    
    NSDictionary* dictGF = [self.arrParkingInfo objectAtIndex:0];
    NSDictionary* dictB1 = [self.arrParkingInfo objectAtIndex:1];
    NSDictionary* dictB2 = [self.arrParkingInfo objectAtIndex:2];
    
    
    float occupiedPerOfA = ([[dictGF objectForKey:@"percent"] floatValue]/[[dictGF objectForKey:@"slots"] floatValue])*100;
    
    float occupiedPerOfB1 = ([[dictB1 objectForKey:@"percent"] floatValue]/[[dictB1 objectForKey:@"slots"] floatValue])*100;
    
    float occupiedPerOfB2 = ([[dictB2 objectForKey:@"percent"] floatValue]/[[dictB2 objectForKey:@"slots"] floatValue])*100;
    
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:occupiedPerOfA color:PNRed description:@"GF"],
                       [PNPieChartDataItem dataItemWithValue:occupiedPerOfB1 color:PNBlue description:@"B1"],
                       [PNPieChartDataItem dataItemWithValue:occupiedPerOfB2 color:[UIColor orangeColor] description:@"B2"],
                       ];
    
    int xPOS  = self.tblParkingsView.center.x - (PieChartWidth/2);
    
    
    PNPieChart *pChart = [[PNPieChart alloc] initWithFrame:CGRectMake(xPOS, 20, 240.0, 240.0) items:items];
    pChart.descriptionTextColor = [UIColor whiteColor];
    pChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    pChart.delegate = self;
    [pChart strokeChart];
    
    return pChart;
}

#pragma mark- PieChartDelegate
- (void)userClickedOnPieIndexItem:(NSInteger)pieIndex{
    if ([self.arrParkingInfo count]>pieIndex) {
        [self performSegueWithIdentifier:@"showParkingLayoutDetails" sender:nil];
    }
}
- (void)didUnselectPieItem{
    
}

@end

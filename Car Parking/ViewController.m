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
@interface ViewController ()

@end

@implementation ViewController

-(NSDictionary*)dictWithName:(NSString*)name slots:(NSString*)slots occupied:(NSString*)percent{
    return [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",slots,@"slots",percent,@"percent", nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.arrParkingInfo = [NSMutableArray arrayWithObjects:
                           [self dictWithName:@"Ground Floor" slots:@"155" occupied:@"35"],
                           [self dictWithName:@"First Floor" slots:@"125" occupied:@"65"],
                           [self dictWithName:@"Second Floor" slots:@"105" occupied:@"85"],
                           nil];
    
    [ProgressHUD show:@"Loading praking info \n please wait..."];
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
@end

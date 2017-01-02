//
//  ViewController.h
//  Car Parking
//
//  Created by NIIT Technologies on 21/11/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PNPieChart;
@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UIView* tableHeaderView;
    PNPieChart* pieChart;
}
@property (nonatomic,strong)IBOutlet UITableView* tblParkingsView;
@property (nonatomic,strong)         NSMutableArray* arrParkingInfo;

@end


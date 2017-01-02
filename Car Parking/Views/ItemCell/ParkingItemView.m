//
//  ParkingItemView.m
//  Car Parking
//
//  Created by NIIT Technologies on 05/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "ParkingItemView.h"

@implementation ParkingItemView
@synthesize cellID;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if ((self = [super initWithCoder:aDecoder])) {
//        [[NSBundle mainBundle] loadNibNamed:@"ParkingItemView" owner:self options:nil];
//        
//    }
//    return self;
//}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    NSLog(@"wakeFromNib");
}

-(id)initWithFrame:(CGRect)frame occupied:(BOOL)isOccupied identifier:(NSString*)parkingIdentifier delegate:(id)delegate{
    if(self = [super init]){
        
        self = [[[NSBundle mainBundle] loadNibNamed:@"ParkingItemView" owner:self options:nil] objectAtIndex:0];
        
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        self.isOccupied = isOccupied;
        self.cellID = parkingIdentifier;
        self.delegate = delegate;
//        UIImage* image = self.isOccupied?[UIImage imageNamed:@"car_top"]:nil;
//        [self.imageView setImage:image];
    }
    return self;
}

-(id)parkingViewWithIdentifier:(NSString*)cellIdentifier{
    return nil;
}

-(IBAction)parkingViewClicked:(id)sender{
    NSLog(@"self.tag =%d",(int)self.tag);
    if ([self.delegate respondsToSelector:@selector(containerView:item:itemClickedAtIndex:)]) {
        UIView* containerView = [self superview];
        if (containerView) {
            [self.delegate containerView:containerView item:self itemClickedAtIndex:self.tag];
        }
    }
}
@end

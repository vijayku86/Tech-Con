//
//  CustomPathDrawer.m
//  Car Parking
//
//  Created by NIIT Technologies on 12/12/16.
//  Copyright © 2016 NIIT Technologies. All rights reserved.
//

#import "CustomPathDrawer.h"
#import "ParkingItemView.h"
@implementation CustomPathDrawer

-(CAShapeLayer*)drawPathForItem:(ParkingItemView*)itemView{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self moveToItemAtFirstHalfOfBlockA:itemView].CGPath;
    layer.fillColor = nil;
    layer.opacity = PATH_OPACITY;
    layer.lineWidth = PATH_WIDTH;
    layer.strokeColor = PATH_COLOR.CGColor;
    shapeLayer = layer;
    return shapeLayer;
}

-(UIBezierPath*)startingPath{
    UIBezierPath* path = [self getPath];
    [path moveToPoint:SP_START_POINT];
    [path addLineToPoint:SP_CHECK_POINT_1];
    return path;
}

-(UIBezierPath*)moveToItemAtFirstHalfOfBlockA:(ParkingItemView*)itemView{
    UIBezierPath* path = [self startingPath];
    
    CGPoint point = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_1.y);
    CGPoint point1 = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_1.y-VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
    
}

-(UIBezierPath*)moveToItemAtSecondHalfOfBlockA:(ParkingItemView*)itemView{
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    CGPoint point = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_2.y);
    CGPoint point1 = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_2.y+VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
    
}

-(UIBezierPath*)moveToItemAtFirstHalfOfBlockB:(ParkingItemView*)itemView{
    int splMargin = 150;
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    [path addLineToPoint:SP_CHECK_POINT_3];
    CGPoint point = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + splMargin +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_3.y);
    CGPoint point1 = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + splMargin+  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_3.y-VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
}

-(UIBezierPath*)moveToItemAtSecondHalfOfBlockB:(ParkingItemView*)itemView{
    int splMargin = 150;
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    [path addLineToPoint:SP_CHECK_POINT_3];
    [path addLineToPoint:SP_CHECK_POINT_4];
    CGPoint point = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + splMargin +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_4.y);
    CGPoint point1 = CGPointMake(itemView.center.x+HorizontalSpacing+ leftMarginFromContainer + splMargin+  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_4.y+VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
    
}

-(UIBezierPath*)moveToItemAtFirstHalfOfBlockC:(ParkingItemView*)itemView{
    
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_5];
    CGPoint point = CGPointMake(SP_CHECK_POINT_5.x+ itemView.center.x+HorizontalSpacing +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_5.y);
    CGPoint point1 = CGPointMake(SP_CHECK_POINT_5.x+itemView.center.x+HorizontalSpacing +  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_5.y-VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
}

-(UIBezierPath*)moveToItemAtSecondHalfOfBlockC:(ParkingItemView*)itemView{
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    [path addLineToPoint:SP_CHECK_POINT_6];
    CGPoint point = CGPointMake(SP_CHECK_POINT_6.x+itemView.center.x+HorizontalSpacing +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_6.y);
    CGPoint point1 = CGPointMake(SP_CHECK_POINT_6.x+itemView.center.x+HorizontalSpacing+  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_6.y+VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
    
}

-(UIBezierPath*)moveToItemAtFirstHalfOfBlockD:(ParkingItemView*)itemView{
    
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    [path addLineToPoint:SP_CHECK_POINT_3];
    [path addLineToPoint:SP_CHECK_POINT_7];
    CGPoint point = CGPointMake(SP_CHECK_POINT_7.x+ itemView.center.x+HorizontalSpacing +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_7.y);
    CGPoint point1 = CGPointMake(SP_CHECK_POINT_7.x+itemView.center.x+HorizontalSpacing +  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_7.y-VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
}

-(UIBezierPath*)moveToItemAtSecondHalfOfBlockD:(ParkingItemView*)itemView{
    UIBezierPath* path = [self startingPath];
    [path addLineToPoint:SP_CHECK_POINT_2];
    [path addLineToPoint:SP_CHECK_POINT_3];
    [path addLineToPoint:SP_CHECK_POINT_4];
    [path addLineToPoint:SP_CHECK_POINT_8];
    CGPoint point = CGPointMake(SP_CHECK_POINT_8.x+itemView.center.x+HorizontalSpacing +(CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_8.y);
    CGPoint point1 = CGPointMake(SP_CHECK_POINT_8.x+itemView.center.x+HorizontalSpacing+  (CGRectGetWidth(itemView.frame)/2), SP_CHECK_POINT_8.y+VerticalSpacing);
    [path addLineToPoint:point];
    [path addLineToPoint:point1];
    return path;
    
}

-(id)init{
    if(self = [super init]){
        
    }
    return self;
}

-(CAShapeLayer*)createShapeLayer {
    
    if (!shapeLayer) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.fillColor = nil;
        layer.opacity = PATH_OPACITY;
        layer.lineWidth = PATH_WIDTH;
        layer.strokeColor = PATH_COLOR.CGColor;
        shapeLayer = layer;
    }
    
    return shapeLayer;
}

-(void)drawPathOnLayer:(CALayer*)superviewLayer FromView:(UIView*)containerView toItem:(ParkingItemView*)item totalSlots:(int)slots {
    int tag = (int)containerView.tag;
    switch (tag) {
        case 1:
            //blockA
            if (item.tag <= slots/2 ) {
                //FirstHalf
                UIBezierPath* path = [self moveToItemAtFirstHalfOfBlockA:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }else{
                //SecondHalf
                UIBezierPath* path = [self moveToItemAtSecondHalfOfBlockA:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }
            break;
        case 2:
            //blockB
            if (item.tag <= slots/2 ) {
                //FirstHalf
                UIBezierPath* path = [self moveToItemAtFirstHalfOfBlockB:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }else{
                //SecondHalf
                UIBezierPath* path = [self moveToItemAtSecondHalfOfBlockB:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }
            break;
        case 3:
            //blockC
            if (item.tag <= slots/2 ) {
                //FirstHalf
                UIBezierPath* path = [self moveToItemAtFirstHalfOfBlockC:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }else{
                //SecondHalf
                UIBezierPath* path = [self moveToItemAtSecondHalfOfBlockC:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }
            break;
        case 4:
            //blockD
            if (item.tag <= slots/2 ) {
                //FirstHalf
                UIBezierPath* path = [self moveToItemAtFirstHalfOfBlockD:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }else{
                //SecondHalf
                UIBezierPath* path = [self moveToItemAtSecondHalfOfBlockD:item];
                CAShapeLayer* layer = [self createShapeLayer];
                layer.path = path.CGPath;
                [superviewLayer addSublayer:layer];
            }
            break;
            
        default:
            break;
    }
}

-(UIBezierPath*)getPath{
    if(!bezierPath){
        bezierPath = [[UIBezierPath alloc] init];
    }
    return bezierPath;
}
-(CALayer*)getPathLayer{
    return shapeLayer;
}
    
-(void)removeLayer{
    [shapeLayer removeFromSuperlayer];
    shapeLayer = nil;
    [bezierPath removeAllPoints];
    bezierPath = nil;
}

//-(NSMutableArray*)getAllJunctionPoints:(UIBezierPath*)path {
//
//    CGPathRef pathref = path.CGPath;
//    
//    
//}


@end

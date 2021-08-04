//
//  CircleUtilsDebug.m
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "CircleUtilsDebug.h"

@implementation CircleUtilsDebug

- (id)initWithContextView:(UIView *)context {
    self = [super init];
    if (self) {
        viewContext = context;
    }
    return self;
}

- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self->viewContext addSubview:circleView];
    });
    
}

- (void)addCircleToPointNoNormalize : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self->viewContext addSubview:circleView];
    });
    
}


@end

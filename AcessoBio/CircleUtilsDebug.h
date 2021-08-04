//
//  CircleUtilsDebug.h
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

@import Foundation;
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface CircleUtilsDebug : NSObject {
    UIView *viewContext;
}

- (id)initWithContextView:(UIView *)context;

- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color;
- (void)addCircleToPointNoNormalize : (CGPoint) point color : (UIColor *)color;

@end

NS_ASSUME_NONNULL_END

//
//  CIFaceFeatureNormalize.h
//  AcessoBio
//
//  Created by Matheus Domingos on 27/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIFaceFeatureNormalize : NSObject {
    UIView *viewContext;
    CGSize sizeViewContext;
}

- (id)initWithContextView:(UIView *)context;

- (CGPoint)normalizedPointForImage:(UIImage*) image fromPoint:(CGPoint)originalPoint;

@end

NS_ASSUME_NONNULL_END

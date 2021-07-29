//
//  CIFaceFeatureNormalize.m
//  AcessoBio
//
//  Created by Matheus Domingos on 27/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "CIFaceFeatureNormalize.h"

@implementation CIFaceFeatureNormalize

- (id)initWithContextView:(UIView *)context {
    self = [super init];
    if (self) {
        viewContext = context;
        sizeViewContext = viewContext.bounds.size;
    }
    return self;
}

#pragma mark - normalize points

- (CGPoint)normalizedPointForImage:(UIImage*) image fromPoint:(CGPoint)originalPoint
{
    CGPoint normalizedPoint = [self pointForImage:image fromPoint:originalPoint];
    normalizedPoint.x /= image.size.width;
    normalizedPoint.y /= image.size.height;
    
    return [self normalizePoint:sizeViewContext fromNormalizedPoint:normalizedPoint];
}

- (CGPoint)normalizePoint:(CGSize)viewSize fromNormalizedPoint:(CGPoint)normalizedPoint
{
    return CGPointMake(normalizedPoint.x * viewSize.width, normalizedPoint.y * viewSize.height);
}

- (CGPoint)pointForImage:(UIImage*) image fromPoint:(CGPoint)originalPoint {
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGPoint convertedPoint;
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            break;
        case UIImageOrientationDown:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeft:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        case UIImageOrientationRight:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationUpMirrored:
            convertedPoint.x = imageWidth - originalPoint.x;
            convertedPoint.y = imageHeight - originalPoint.y;
            break;
        case UIImageOrientationDownMirrored:
            convertedPoint.x = originalPoint.x;
            convertedPoint.y = originalPoint.y;
            break;
        case UIImageOrientationLeftMirrored:
            convertedPoint.x = imageWidth - originalPoint.y;
            convertedPoint.y = originalPoint.x;
            break;
        case UIImageOrientationRightMirrored:
            convertedPoint.x = originalPoint.y;
            convertedPoint.y = imageHeight - originalPoint.x;
            break;
        default:
            break;
    }
    return convertedPoint;
}


@end

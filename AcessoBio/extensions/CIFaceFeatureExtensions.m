//
//  CIFaceFeatureExtensions.m
//  AcessoBio
//
//  Created by Matheus Domingos on 27/07/21.
//

#import "CIFaceFeatureExtensions.h"

@implementation CIFaceFeature (CIFaceFeatureExtensions)


- (CGPoint)leftEyePositionNormalized: (UIImage *)image {
    UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    topViewController.view;
    return [self pointInView:topViewController.view.bounds.size fromNormalizedPoint:[self normalizedPointForImage:image fromPoint:self.leftEyePosition]];;
}

- (CGPoint)normalizedPointForImage:(UIImage*) image fromPoint:(CGPoint)originalPoint
{
    CGPoint normalizedPoint = [self pointForImage:image fromPoint:originalPoint];
    normalizedPoint.x /= image.size.width;
    normalizedPoint.y /= image.size.height;
    return normalizedPoint;
}

- (CGPoint)pointInView:(CGSize)viewSize fromNormalizedPoint:(CGPoint)normalizedPoint
{
    return CGPointMake(normalizedPoint.x * viewSize.width, normalizedPoint.y * viewSize.height);
}

+ (CGPoint)leftEyePositionNormalized {
    return CGPointMake(0, 0);
}

+ (CGPoint)rightEyePositionNormalized {
    return CGPointMake(0, 0);
}

+ (CGPoint)mouthPositionNormalized {
    return CGPointMake(0, 0);
}

- (CGPoint)pointForImage:(UIImage*) image fromPoint:(CGPoint)originalPoint
{
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

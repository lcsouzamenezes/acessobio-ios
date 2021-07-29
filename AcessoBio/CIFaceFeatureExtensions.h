//
//  CIFaceFeatureExtensions.h
//  AcessoBio
//
//  Created by Matheus Domingos on 27/07/21.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIFaceFeature (CIFaceFeatureExtensions)

@property (readonly, assign) CGPoint leftEyePositionNormalized;
@property (readonly, assign) CGPoint rightEyePositionNormalized;
@property (readonly, assign) CGPoint mouthPositionNormalized;


@end

NS_ASSUME_NONNULL_END

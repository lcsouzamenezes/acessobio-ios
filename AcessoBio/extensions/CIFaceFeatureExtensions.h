//
//  CIFaceFeatureExtensions.h
//  AcessoBio
//
//  Created by Matheus Domingos on 27/07/21.
//

@import Foundation;
@import UIKit;
@import CoreImage;

NS_ASSUME_NONNULL_BEGIN

@interface CIFaceFeature (CIFaceFeatureExtensions)

@property (readonly, assign) CGPoint leftEyePositionNormalized;
@property (readonly, assign) CGPoint rightEyePositionNormalized;
@property (readonly, assign) CGPoint mouthPositionNormalized;


@end

NS_ASSUME_NONNULL_END

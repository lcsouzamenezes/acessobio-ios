//
//  FaceNormalize.h
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

@import Foundation;
@import CoreImage;
@import UIKit;
#import "CircleUtilsDebug.h"
#import "CIFaceFeatureNormalize.h"

typedef enum ErrorsFaceType : NSUInteger {
    EYE_ABOVE_ERROR,
    EYE_BELOW_ERROR,
    EYE_OUTSIDE_HORIZONTAL_ERROR,
    FACE_CLOSE_DISTANCE_ERROR,
    FACE_AWAY_DISTANCE_ERROR,
    FACE_INCLINED_ERROR,
    FACE_ROTATE_ERROR,
    MOUTH_ABOVE_ERROR,
    NO_ERROR
} ErrorsFaceType;

NS_ASSUME_NONNULL_BEGIN

@interface FaceAnalyze : NSObject {
    
    BOOL debug;
    
    CGRect frameSilhuette;
    UIView *viewContext;
    CGSize sizeViewContext;
    
    int countWithNoFaceAtScreen;
    
    int leftMargin;
    int rightMargin;
    int topMargin;
    int bottomMargin;
    
    float minDistance;
    float maxDistance;
    
    CircleUtilsDebug *circleUtilsDebug;
    CIFaceFeatureNormalize *ciFaceFeatureNormalize;
    
    ErrorsFaceType errorFaceType;

}


- (id)initWithFrameSilhuette:(CGRect)pFrameSilhuette viewContext:(UIView *)pViewContext;

- (BOOL)validate : (CIFaceFeature *)face yawFace: (float)yawFace uiimage: (UIImage *)uiimage;

@property (readwrite) int countError;

- (ErrorsFaceType)getErrorType;

@end

NS_ASSUME_NONNULL_END

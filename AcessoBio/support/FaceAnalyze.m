//
//  FaceNormalize.m
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "FaceAnalyze.h"
#import "DeviceUtils.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define IS_RETINA ([[UIScreen mainScreen] scale] > 2.0)

@implementation FaceAnalyze

- (id)initWithFrameSilhuette:(CGRect)pFrameSilhuette viewContext:(UIView *)pViewContext
{
    self = [super init];
    if (self) {
        [self setDebug:NO];
        frameSilhuette = pFrameSilhuette;
        [self valuesFromSilhoutte];
        viewContext = pViewContext;
        [self initCIFaceFeatureNormalize];
        [self initValuesDistance];
        sizeViewContext = viewContext.bounds.size;
        circleUtilsDebug = [[CircleUtilsDebug alloc]initWithContextView:viewContext];
    }
    return self;
}

- (void)setDebug:(BOOL)status {
    debug = status;
}

- (ErrorsFaceType)getErrorType {
    return errorFaceType;
}

- (void)initCIFaceFeatureNormalize {
    ciFaceFeatureNormalize = [[CIFaceFeatureNormalize alloc]initWithContextView:viewContext];
}

- (void)initValuesDistance {
    minDistance = 150.0f;
    if([DeviceUtils hasSmallScreen] || IS_RETINA) {
        minDistance = 160.0f;
    }
    
    maxDistance = 250.0f;
    if([DeviceUtils hasSmallScreen] || IS_RETINA) {
        maxDistance = 250.0f;
    }
}

- (void)valuesFromSilhoutte {
    leftMargin = frameSilhuette.origin.x;
    rightMargin = (frameSilhuette.origin.x + frameSilhuette.size.width);
    topMargin = frameSilhuette.origin.y;
    bottomMargin = frameSilhuette.size.height;
}

#pragma mark - validate
- (BOOL)validate : (CIFaceFeature *)face yawFace: (float)yawFace uiimage: (UIImage *)uiimage {
            
    UIImage *imageFlipped = uiimage.imageWithHorizontallyFlippedOrientation;
    
    CGPoint leftEyePositionNormalized = [ciFaceFeatureNormalize normalizedPointForImage:imageFlipped fromPoint:face.leftEyePosition];
    CGPoint rightEyePositionNormalized = [ciFaceFeatureNormalize normalizedPointForImage:imageFlipped fromPoint:face.rightEyePosition];
    CGPoint mouthPositionNormalized = [ciFaceFeatureNormalize normalizedPointForImage:imageFlipped fromPoint:face.mouthPosition];
    
    BOOL validFace = YES;
    
    // Face Angle
    CGFloat FACE_ANGLE = 180 - fabs(face.faceAngle);
        
    float distanceBeetwenEyes = ((fabs(rightEyePositionNormalized.x - leftEyePositionNormalized.x)) * 2);
    
    if(distanceBeetwenEyes < minDistance)
    {
        _countError ++;
        errorFaceType = FACE_AWAY_DISTANCE_ERROR;
        validFace = NO;
    }else if(distanceBeetwenEyes > maxDistance)
    {
        _countError ++;
        errorFaceType = FACE_CLOSE_DISTANCE_ERROR;
        validFace = NO;
    }else if((fabs(FACE_ANGLE) > 5))
    {
        _countError ++;
        errorFaceType = FACE_INCLINED_ERROR;
        validFace = NO;
    }else if(yawFace != 0)
    {
        _countError ++;
        errorFaceType = FACE_ROTATE_ERROR;
        validFace = NO;
    }else if ([self eyeAboveSilhoutte:leftEyePositionNormalized.y y_right_eye_point:rightEyePositionNormalized.y])
    {
        _countError ++;
        errorFaceType = EYE_ABOVE_ERROR;
        validFace = NO;
    }else if([self eyeBelowSilhoutte:leftEyePositionNormalized.y y_right_eye_point:rightEyePositionNormalized.y])
    {
        _countError ++;
        errorFaceType = EYE_BELOW_ERROR;
        validFace = NO;
    }else if([self mouthAboveHalfSilhoutte:mouthPositionNormalized.y])
    {
         _countError ++;
        errorFaceType = MOUTH_ABOVE_ERROR;
        validFace = NO;
     }
    else if([self eyesOutLeftOrRightOfSilhoutte:rightEyePositionNormalized.x x_left_eye_point:leftEyePositionNormalized.x])
    {
        _countError ++;
        errorFaceType = EYE_OUTSIDE_HORIZONTAL_ERROR;
        validFace = NO;
    }else {
        errorFaceType = NO_ERROR;
    }
    
    if(debug) {
        [self debugShowPlots:imageFlipped face:face];
        NSLog(@"SCALE: %.2f", [[UIScreen mainScreen] scale]);
        NSLog(@"COUNT ERROR >>>>> %.2d", _countError);
        NSLog(@"FACE_ANGLE >>> %.f", FACE_ANGLE);
        NSLog(@"distanceBeetwenEyes >>> %.f", distanceBeetwenEyes);
        NSLog(@"errorFaceType >>> %lu", errorFaceType);
    }
        
    return validFace;
    
}

//Verificação se o olho está acima da silhueta
- (BOOL)eyeAboveSilhoutte: (float)y_left_eye_point y_right_eye_point: (float)y_right_eye_point {
    if ((fabs(y_left_eye_point) < topMargin) ||
        (fabs(y_right_eye_point) < topMargin) ){
        return YES;
    }
    return NO;
}

//Verificação se o olho está na metade para baixo da silhueta e se a boca esta na posição correta
- (BOOL)eyeBelowSilhoutte: (float)y_left_eye_point y_right_eye_point: (float)y_right_eye_point {
    if((fabs(y_left_eye_point) > (topMargin + (bottomMargin / 2))) ||
       fabs(y_right_eye_point) > (topMargin + (bottomMargin/ 2))) {
        return YES;
    }
    return NO;
}

//Verificação se a boca está na metade para baixo da silhueta
- (BOOL)mouthAboveHalfSilhoutte: (float)y_mouth_point {
    if(fabs(y_mouth_point) < (topMargin + (bottomMargin/ 2))){
        return YES;
    }
    return NO;
}

- (BOOL)eyesOutLeftOrRightOfSilhoutte: (float)x_right_eye_point x_left_eye_point: (float)x_left_eye_point  {
    if(x_right_eye_point > rightMargin ||
       x_left_eye_point < leftMargin ) {
        return YES;
    }
    return NO;
}

-(void)debugShowPlots : (UIImage *)image face: (CIFaceFeature*)face {
        // left eye
        [circleUtilsDebug addCircleToPoint:[ciFaceFeatureNormalize  normalizedPointForImage:image fromPoint:face.leftEyePosition] color:[UIColor orangeColor]];
        // right eye
        [circleUtilsDebug addCircleToPoint:[ciFaceFeatureNormalize  normalizedPointForImage:image fromPoint:face.rightEyePosition] color:[UIColor redColor]];
        // mouth
        [circleUtilsDebug addCircleToPoint:[ciFaceFeatureNormalize  normalizedPointForImage:image fromPoint:face.mouthPosition] color:[UIColor redColor]];
}

@end

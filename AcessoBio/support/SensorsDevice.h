//
//  SensorsDevice.h
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

@import Foundation;
@import AVFoundation;
@import CoreMotion;

NS_ASSUME_NONNULL_BEGIN

@interface SensorsDevice : NSObject {
    float devicePitch;
    float deviceRoll;
    float deviceYaw;
    CMMotionManager *motionManager;
    
    NSMutableArray *arrPitch;
    NSMutableArray *arrRoll;
    NSMutableArray *arrYaw;
    BOOL isColect;

}

- (float)getPitch;
- (float)getRoll;
- (float)getYaw;

- (void)startColect;
- (void)stopColect;
- (NSDictionary *)getColect;

@end

NS_ASSUME_NONNULL_END

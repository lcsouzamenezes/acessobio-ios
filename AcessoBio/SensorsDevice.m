//
//  SensorsDevice.m
//  AcessoBio
//
//  Created by Matheus Domingos on 26/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "SensorsDevice.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

@implementation SensorsDevice


- (id)init {
    self = [super init];
    if (self) {
        [self gyroscope];
    }
    return self;
}

#pragma mark - Sensors
- (void)gyroscope {

    motionManager = [[CMMotionManager alloc] init];
    [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:[NSOperationQueue currentQueue]
                                                        withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            /*
             CGFloat x = motion.gravity.x;
             CGFloat y = motion.gravity.y;
             CGFloat z = motion.gravity.z;
             */

            if(self->motionManager.deviceMotion != nil) {

                CMQuaternion quat = self->motionManager.deviceMotion.attitude.quaternion;

                double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
                double pitch = RADIANS_TO_DEGREES(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
                double roll = RADIANS_TO_DEGREES(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;

                pitch = pitch - 90;

                self->devicePitch = pitch;
                self->deviceRoll = roll;
                self->deviceYaw = yaw;

            }


        }];
    }];

}

- (float)getPitch {
    return devicePitch;
}

- (float)getRoll {
    return deviceRoll;
}

- (float)getYaw {
    return deviceYaw;
}

- (void)luminosity:(CMSampleBufferRef)sampleBuffer {

        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                     sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc]
                                  initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata
                                       objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata
                                  objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];

}



/*

 BOOL isDarkImage(UIImage* inputImage){


 BOOL isDark = FALSE;

 CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(inputImage.CGImage));
 const UInt8 *pixels = CFDataGetBytePtr(imageData);

 int darkPixels = 0;

 int length = CFDataGetLength(imageData);
 int const darkPixelThreshold = (inputImage.size.width*inputImage.size.height)*.65;

 for(int i=0; i<length; i+=4)
 {
 int r = pixels[i];
 int g = pixels[i+1];
 int b = pixels[i+2];

 //luminance calculation gives more weight to r and b for human eyes
 float luminance = (0.299*r + 0.587*g + 0.114*b);
 if (luminance<150) darkPixels ++;
 }

 if (darkPixels >= darkPixelThreshold)
 isDark = YES;

 CFRelease(imageData);

 return isDark;

 }
 */


@end

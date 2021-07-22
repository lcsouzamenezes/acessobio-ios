//
//  Utils.m
//  AcessoBio
//
//  Created by Matheus Domingos on 19/07/21.
//

#import "DeviceUtils.h"

@implementation DeviceUtils

+(NSString*) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (BOOL)hasFasterModelDevice {
    
    NSString *deviceName = [self deviceName];
    
    if([deviceName containsString:@","]) {
        NSArray *arrStrParts = [deviceName componentsSeparatedByString:@","];
        NSString *firstPartDeviceName = arrStrParts[0];
        firstPartDeviceName = [firstPartDeviceName stringByReplacingOccurrencesOfString:@"iPhone" withString:@""];
        int versionDevice = [firstPartDeviceName intValue];

        if(versionDevice > 10) {
            return true;
        }else {
            return false;
        }
    }
    
    return false;
    
}

@end

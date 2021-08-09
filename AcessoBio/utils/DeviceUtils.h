//
//  Utils.h
//  AcessoBio
//
//  Created by Matheus Domingos on 19/07/21.
//

@import Foundation;
@import Darwin.POSIX.sys.utsname;

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUtils : NSObject

+(NSString*) deviceName;
+(BOOL)hasSmallScreen;
+(BOOL)hasFasterModelDevice;

@end

NS_ASSUME_NONNULL_END

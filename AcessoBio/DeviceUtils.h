//
//  Utils.h
//  AcessoBio
//
//  Created by Matheus Domingos on 19/07/21.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceUtils : NSObject

+(NSString*) deviceName;
+(BOOL)hasFasterModelDevice;

@end

NS_ASSUME_NONNULL_END

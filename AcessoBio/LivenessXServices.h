//
//  LivenessXServices.h
//  AcessoBio
//
//  Created by  Matheus Domingos on 16/10/20.
//

#import <Foundation/Foundation.h>

#import "AFHTTPSessionManager.h"
#import "AFNetworking.h"
#import "AFHTTPSessionManager.h"

@class DebugLivenessXServices;
@class LivenessXView;

NS_ASSUME_NONNULL_BEGIN

@interface LivenessXServices : NSObject{
    NSString *URL;
    NSString *APIKEY;
    NSString *TOKEN;
    NSString *urlPath;
    LivenessXView *lView;
    AFHTTPSessionManager *manager;
}

- (id)initWithAuth:(LivenessXView *)pLView pUrl:(NSString *)pUrl apikey:(NSString *)pApikey token:(NSString *)pToken;

- (void)faceDetectBehavior : (NSString *)base64AwayWithoutSmilling
                 base64Away: (NSString*)base64Away;
- (void)faceDetectInital : (NSString *)_base64Center
               base64Away: (NSString*)_base64AwayWithoutSmilling;

- (void)sendBillingV3 : (NSDictionary *)params;
- (void)createProcessV3 : (NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END

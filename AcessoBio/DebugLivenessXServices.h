//
//  DebugLivenessXServices.h
//  AcessoBio
//
//  Created by  Matheus Domingos on 19/10/20.
//

#import <Foundation/Foundation.h>
#import "LivenessXServices.h"

NS_ASSUME_NONNULL_BEGIN

@interface DebugLivenessXServices : LivenessXServices


- (id)initWithAuth:(LivenessXView *)pLView pUrl:(NSString *)pUrl apikey:(NSString *)pApikey token:(NSString *)pToken;

-(void) sendLiveness : (NSDictionary *)paramsLiveness processId: (NSString *)processId;

@end

NS_ASSUME_NONNULL_END

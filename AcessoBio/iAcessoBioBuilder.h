//
//  IAcessoBioBuilder.h
//  AcessoBio
//
//  Created by Matheus Domingos on 29/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef iAcessoBioBuilder_h
#define iAcessoBioBuilder_h
#import "AcessoBioCamera.h"
#import "iAcessoBioTheme.h"

@protocol iAcessoBioBuilder <NSObject>

- (id<iAcessoBioBuilder>) setTheme: (id<iAcessoBioTheme>)theme;
- (id<iAcessoBioBuilder>) setAutoCapture: (BOOL)isEnabled;
- (id<iAcessoBioBuilder>) setSmartFrame: (BOOL)isEnabled;
- (id<iAcessoBioBuilder>) setTimeoutSession: (double)timeoutInSeconds;
- (id<iAcessoBioBuilder>) setTimeoutToFaceInference: (double)timeoutInSeconds;
- (id<AcessoBioCamera>) build;

@end
#endif /* IAcessoBioBuilder_h */
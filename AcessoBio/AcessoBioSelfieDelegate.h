//
//  iAcessoBioSelfie.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef iAcessoBioSelfie_h
#define iAcessoBioSelfie_h
#import "SelfieResult.h"
#import "ErrorBio.h"

@protocol AcessoBioSelfieDelegate <NSObject>

- (void)onSuccessSelfie: (SelfieResult *)result;
- (void)onErrorSelfie:(ErrorBio *)errorBio;

@end
#endif /* iAcessoBioSelfie_h */
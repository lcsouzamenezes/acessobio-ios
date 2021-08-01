//
//  iAcessoBioDocumentDelegate.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef iAcessoBioDocumentDelegate_h
#define iAcessoBioDocumentDelegate_h
#import "ErrorBio.h"
#import "DocumentResult.h"

@protocol iAcessoBioDocumentDelegate <NSObject>

- (void)onSuccessDocument: (DocumentResult *)result;
- (void)onErrorDocument:(ErrorBio *)errorBio;

@end
#endif /* iAcessoBioDocumentDelegate_h */

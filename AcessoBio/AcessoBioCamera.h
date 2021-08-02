//
//  AcessoBioCamera.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef AcessoBioCamera_h
#define AcessoBioCamera_h
#import "SelfieCameraDelegate.h"
#import "SelfieCameraDelegateImpl.h"
#import "AcessoBioCameraOpener.h"

@protocol AcessoBioCamera <NSObject>

- (void)prepareSelfieCamera: (id <SelfieCameraDelegate>)delegate;
- (void) prepareDocumentCamera;

@end


#endif /* AcessoBioCamera_h */

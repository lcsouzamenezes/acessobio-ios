//
//  iAcessoBioCameraSelfie.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef iSelfieCameraDelegate_h
#define iSelfieCameraDelegate_h
#import "AcessoBioCameraOpenerDelegate.h"

@protocol iSelfieCameraDelegate <NSObject>

- (void)onCameraReady: (id <AcessoBioCameraOpenerDelegate>)cameraOpener;
- (void)onCameraFailed:(NSString*)message;

@end

#endif /* iAcessoBioCameraSelfie_h */

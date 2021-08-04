//
//  AcessoBioCamera.m
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "AcessoBioCameraImpl.h"
#import "AcessoBioCameraOpener.h"

@implementation AcessoBioCameraImpl

- (id)initWithUnicoCheck:(UnicoCheck *)unicoCheck{
    self = [super init];
    if(self) {
        core = unicoCheck;
    }
    return self;
}

- (void)prepareSelfieCamera:(id<SelfieCameraDelegate>)delegate {
    AcessoBioCameraOpener *cameraOpener = [[AcessoBioCameraOpener alloc]initWithUnicoCheck:core];
    [delegate onCameraReady:cameraOpener];
}

- (void)prepareSelfieCameraCompletion:(void (^)(SelfieCameraDelegateImpl *))completion {
    AcessoBioCameraOpener *cameraOpener = [[AcessoBioCameraOpener alloc]initWithUnicoCheck:core];
    [completion onCameraReady:cameraOpener];
}

- (void)prepareDocumentCamera:(id<DocumentCameraDelegate>)delegate {
    AcessoBioCameraOpener *cameraOpener = [[AcessoBioCameraOpener alloc]initWithUnicoCheck:core];
    [delegate onCameraReadyDocument:cameraOpener];
}

@end

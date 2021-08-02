//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
#import "AcessoBioManager.h"
#import "AcessoBioDelegate.h"
#import "iAcessoBioTheme.h"
#import "AcessoBioCamera.h"
#import "AcessoBioCameraImpl.h"

@implementation AcessoBioManager


#pragma mark - Init instance
- (id)initWithViewController:(id)view{
    self = [super init];
    if(self) {
        [self initWithViewController:view delegate:view];
    }
    return self;
}

- (void)initWithViewController :(id)view delegate:(id)delegate {
    core = [[UnicoCheck alloc]initWithViewController:view delegates:delegate];
}

#pragma mark - iAcessoBioBuilder Delegates

- (id<iAcessoBioBuilder>)setTheme:(id<iAcessoBioTheme>)theme {
    [core setColorBackground:[theme getColorBackground]];
    return self;
}

- (id<iAcessoBioBuilder>)setAutoCapture:(BOOL)isEnabled {
    [core setAutoCapture:isEnabled];
    return self;
}

- (id<iAcessoBioBuilder>)setSmartFrame:(BOOL)isEnabled {
    [core setSmartFrame:isEnabled];
    return self;
}

- (id<iAcessoBioBuilder>)setTimeoutSession:(double)timeoutInSeconds {
    [core setTimeoutSession:timeoutInSeconds];
    return self;
}

- (id<iAcessoBioBuilder>)setTimeoutToFaceInference:(double)timeoutInSeconds {
    [core setTimeoutToFaceInference:timeoutInSeconds];
    return self;
}

- (id<AcessoBioCamera>)build {
    AcessoBioCameraImpl *acessoBioCamera = [[AcessoBioCameraImpl alloc]initWithUnicoCheck:core];
    return acessoBioCamera;
}


@end

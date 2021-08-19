//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Matheus Domingos on 13/05/19.
//  Created by unico idtech. All rights reserved.
//
#import "AcessoBioManager.h"
#import "AcessoBioManagerDelegate.h"
#import "AcessoBioThemeDelegate.h"
#import "AcessoBioCameraDelegate.h"
#import "AcessoBioCameraImpl.h"

@implementation AcessoBioManager

#pragma mark - Init instance
- (id)initWithViewController:(id)view{
    self = [super init];
    if(self) {
       self = [self initWithViewController:view delegate:view];
    }
    return self;
}

- (id)initWithViewController :(id)view delegate:(id)delegate {
    core = [[UnicoCheck alloc]initWithViewController:view delegates:delegate];
    return self;
}

#pragma mark - iAcessoBioBuilder Delegates

- (id<iAcessoBioBuilder>)setTheme:(id<AcessoBioThemeDelegate>)theme {
    
    // Background
    [core setColorBackground: [theme getColorBackground]];
    
    // Silhouette
    [core setColorSilhoutteSuccess: [theme getColorSilhouetteSuccess]];
    [core setColorSilhoutteError: [theme getColorSilhouetteError]];
    
    // Document
    [core setColorBottomDocumentBackground: [theme getColorBackgroundBottomDocument]];
    [core setColorBottomDocumentText: [theme getColorTextBottomDocument]];
    
    // Message
    [core setColorBackgroundBoxStatus: [theme getColorBoxMessage]];
    [core setColorTextBoxStatus: [theme getColorTextMessage]];
    
    // Error
    [core setColorBackgroundPopupError: [theme getColorBackgroundPopupError]];
    [core setColorTextPopupError: [theme getColorTextPopupError]];
    [core setColorBackgroundButtonPopupError: [theme getColorBackgroundButtonPopupError]];
    [core setColorTextButtonPopupError: [theme getColorTextButtonPopupError]];
    
    // Shot Button
    [core setColorButtonIcon: [theme getColorIconTakePictureButton]];
    [core setColorButtonBackground: [theme getColorBackgroundTakePictureButton]];
    
    
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

- (id<AcessoBioCameraDelegate>)build {
    AcessoBioCameraImpl *acessoBioCamera = [[AcessoBioCameraImpl alloc]initWithUnicoCheck:core];
    return acessoBioCamera;
}


@end

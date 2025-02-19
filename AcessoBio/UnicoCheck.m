//
//  CameraBio.m
//  CaptureAcesso
//
//  Created by Matheus Domingos on 13/05/19.
//  Created by unico idtech. All rights reserved.
//
#import "UnicoCheck.h"
#import "CameraFaceView.h"
#import "DocumentInsertView.h"
#import "UIColorExtensions.h"
#import "AcessoBioConstants.h"
#import "AcessoBioManagerDelegate.h"

@implementation UnicoCheck

- (id)initWithViewController:(id)view delegates:(id<AcessoBioManagerDelegate>)delegate{
    
    self = [super init];
    if(self) {
        viewController = view;
        _acessoBioDelegate = delegate;
        [self setDefaults];
        [self initSentry];
    }
    
    return self;
}

- (void)initSentry {
#if defined(__has_include)
    #if __has_include(<Sentry/Sentry.h>)
    [SentrySDK startWithConfigureOptions:^(SentryOptions *options) {
        options.dsn = @"https://441ee1f9306d4117996c7dc03e01f295@o939397.ingest.sentry.io/5899055";
        options.debug = NO; // Enabled debug when first installing is always helpful
        options.enableAutoSessionTracking = YES;
    }];
    [SentrySDK captureMessage:@"Init AcessoBio"];
    #endif
#endif

}

#pragma mark - Defaults

- (void)setDefaults {
    hasImplementationError = NO;
    [self setDefaultTimeSession];
    [self setDefaultTimeoutFaceInference];
    [self setDefaultOrigin];
}

- (void)setDefaultTimeSession {
    defaultTimeoutSession = 40;
    _secondsTimeoutSession = defaultTimeoutSession;
}

- (void)setDefaultTimeoutFaceInference {
    defaultTimeoutToFaceInference = 15;
    _secondsTimeoutToFaceInference = defaultTimeoutToFaceInference;
    minimumTimeoutToFaceInference = 5;
}

#pragma mark - Origin and Version

- (void)setDefaultOrigin {
    _language = Native;
}

- (void)setDefaultVersionRelease {
    versionRelease = @"1.2.7";
}

#pragma mark - Timeout

- (void)setTimeoutToFaceInference : (double)seconds{
    if(seconds <= minimumTimeoutToFaceInference) {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setTimeoutToFaceInference" desc:@"É necessário insirir um valor maior que 5 segundos no método: setTimeoutToFaceInference."]];
        return;
    }
    _secondsTimeoutToFaceInference = seconds;
}

- (void)setTimeoutSession: (double)seconds{
    if(seconds <= defaultTimeoutSession) {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setTimeoutProcess" desc:@"É necessário insirir um valor maior que 40 segundos no método: setTimeoutProcess."]];
        return;
    }
    _secondsTimeoutSession = seconds;
}

- (void)setLanguageOrigin: (LanguageOrigin)origin release: (NSString*)release{
    _language = origin;
    versionRelease = release;
}

#pragma mark - Custom

- (void)setAutoCapture:(BOOL)isEnabled {
    _isAutoCapture = isEnabled;
}

- (void)setSmartFrame:(BOOL)isEnabled {
    _isSmartCamera = isEnabled;
}

- (void)setColorSilhoutteNeutral: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorSilhoutteNeutral = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorSilhoutteNeutral = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteNeutral" desc:@"Formato de cor não permitido."]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteNeutral" desc:@"Formato de cor não permitido."]];
    }
    
}

- (void)setColorSilhoutteSuccess: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorSilhoutteSuccess = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorSilhoutteSuccess = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteSuccess" desc:@"Formato de cor não permitido."]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteSuccess" desc:@"Formato de cor não permitido."]];
    }
    
}

- (void)setColorSilhoutteError: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorSilhoutteError = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorSilhoutteError = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteError" desc:@"Formato de cor não permitido."]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorSilhoutteError" desc:@"Formato de cor não permitido."]];
    }
    
}

- (void)setColorBackground: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBackground = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorBackground = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackground" desc:@"Formato de cor não permitido."]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackground" desc:@"Formato de cor não permitido."]];
    }
    
}

- (void)setColorBackgroundBoxStatus: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBackgroundBoxStatus = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorBackgroundBoxStatus = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundBoxStatus" desc:kColorError]];        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundBoxStatus" desc:kColorError]];
    }
    
}

- (void)setColorTextBoxStatus: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorTextBoxStatus = color;
    }else if([color isKindOfClass:[NSString class]]) {
        _colorTextBoxStatus = [UIColor colorWithHexString:color];
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorTextBoxStatus" desc:kColorError]];
    }
    
}

- (void)setColorBackgroundPopupError: (id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBackgroundPopupError = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorBackgroundPopupError = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundPopupError" desc:kColorError]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundPopupError" desc:kColorError]];
    }
    
}

- (void)setColorTextPopupError: (id)color {
    
    if(color == nil) return;
    
    _colorTextPopupError = color;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorTextPopupError = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorTextPopupError = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorTextPopupError" desc:kColorError]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorTextPopupError" desc:kColorError]];
    }
    
}

- (void)setColorBackgroundButtonPopupError:(id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBackgroundButtonPopupError = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorBackgroundButtonPopupError = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundButtonPopupError" desc:kColorError]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBackgroundButtonPopupError" desc:kColorError]];
    }
    
}

- (void)setColorTextButtonPopupError:(id)color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorTextButtonPopupError = color;
    }else if([color isKindOfClass:[NSString class]]) {
        if([self verifyColorString:color]) {
            _colorTextButtonPopupError = [UIColor colorWithHexString:color];
        }else{
            [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorTextButtonPopupError" desc:kColorError]];
        }
    }else{
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorTextButtonPopupError" desc:kColorError]];
    }
    
}

- (void) setColorBottomDocumentBackground: (id) color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBottomDocumentBackground = color;
    }
    
    else if([color isKindOfClass:[NSString class]] && [self verifyColorString:color]) {
        _colorBottomDocumentBackground = [UIColor colorWithHexString:color];
    }
    
    else {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBottomDocumentBackground" desc:kColorError]];
    }
}

- (void) setColorBottomDocumentText: (id) color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorBottomDocumentText = color;
    }
    
    else if([color isKindOfClass:[NSString class]] && [self verifyColorString:color]) {
        _colorBottomDocumentText = [UIColor colorWithHexString:color];
    }
    
    else {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorBottomDocumentText" desc:kColorError]];
    }
}

- (void) setColorButtonIcon: (id) color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorButtonIcon = color;
    }
    
    else if([color isKindOfClass:[NSString class]] && [self verifyColorString:color]) {
        _colorButtonIcon = [UIColor colorWithHexString:color];
    }
    
    else {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorButtonIcon" desc:kColorError]];
    }
}

- (void) setColorButtonBackground: (id) color {
    
    if(color == nil) return;
    
    if([color isKindOfClass:[UIColor class]]) {
        _colorButtonBackground = color;
    }
    
    else if([color isKindOfClass:[NSString class]] && [self verifyColorString:color]) {
        _colorButtonBackground = [UIColor colorWithHexString:color];
    }
    
    else {
        [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"setColorButtonBackground" desc:kColorError]];
    }
    
}

- (void)setImageIconPopupError: (id)image {
    imageIconPopupError = image;
}

#pragma mark - Cameras

- (void)openCameraSelfie:(id<AcessoBioSelfieDelegate>)delegate {

    if(delegate == nil) {
        [self classIsNotImplemented:@"AcessoBioSelfieDelegate"];
        return;
    }
    self.selfieDelegate = delegate;
    
    if ([self verifyTarget]) {
        
        cView = [CameraFaceView new];
        [cView setDelegate:self];
        
        [cView setLanguage:_language];
        [cView setVersionRelease:versionRelease];
        [cView setSecondsTimeoutSession:_secondsTimeoutSession];
        [cView setSecondsTimeoutToInferenceFace:_secondsTimeoutToFaceInference];
        [cView setIsEnableAutoCapture:_isAutoCapture];
        [cView setIsEnableSmartCapture:_isSmartCamera];
        
        [cView setColorSilhoutteNeutral:_colorSilhoutteNeutral];
        [cView setColorSilhoutteError:_colorSilhoutteError];
        [cView setColorSilhoutteSuccess:_colorSilhoutteSuccess];
        
        [cView setColorBackground:_colorBackground];
        
        [cView setColorBackgroundBoxStatus:_colorBackgroundBoxStatus];
        [cView setColorTextBoxStatus:_colorTextBoxStatus];
        [cView setColorButtonBackground:_colorButtonBackground];
        [cView setColorButtonIcon:_colorButtonIcon];
        
        [self presentView:cView];
        
    }
    
}

- (void)openCameraDocuments : (DocumentEnums) documentType delegate:(id<AcessoBioDocumentDelegate>)delegate {
    
    if(delegate == nil) {
        [self classIsNotImplemented:@"AcessoBioDocumentDelegate"];
        return;
    }
    self.documentDelegate = delegate;
    
    dView = [DocumentInsertView new];
    [dView setCore:self];
    [dView setColorBottomDocumentText:self.colorBottomDocumentText];
    [dView setColorBottomDocumentBackground:self.colorBottomDocumentBackground];
    [dView setColorButtonIcon:self.colorButtonIcon];
    [dView setColorButtonBackground:self.colorButtonBackground];
    if(documentType == DocumentCNH) {
        dView.type = 4;
    }else if(documentType == DocumentRGFrente || documentType == DocumentRG) {
        dView.type = 501;
    }else if(documentType == DocumentRGVerso){
        dView.type = 502;
    }else{
        dView.type = 999;
    }
    
    [self presentView:dView];
    
}

- (void)presentView:(UIViewController *)vc {
    if(!hasImplementationError) {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
        [nav setNavigationBarHidden:YES animated:NO];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
        [viewController presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - Instances

#pragma mark - Utils

- (BOOL)verifyTarget {
    if (@available(iOS 11.0, *)) {
        return YES;
    }
    [self onErrorAcessoBioManager:[[ErrorBio alloc]initCode:400 method:@"verifyTarget" desc:@"Este método está disponível a partir do iOS 11."]];
    return NO;
}

- (BOOL)verifyColorString : (NSString *)string{
    NSCharacterSet *chars = [[NSCharacterSet
                              characterSetWithCharactersInString:@"#0123456789ABCDEFabcdef"] invertedSet];
    
    BOOL isValid = (NSNotFound == [string rangeOfCharacterFromSet:chars].location);
    if(string.length == 0) {
        isValid = NO;
    }
    return isValid;
}

#pragma mark - Callbacks

#pragma mark AcessoBioDelegate

- (void)userClosedCameraManually {
    if (self.acessoBioDelegate && [self.acessoBioDelegate respondsToSelector:@selector(onUserClosedCameraManually)]) {
        [self.acessoBioDelegate onUserClosedCameraManually];
    }
}

- (void)systemClosedCameraTimeoutSession {
    if (self.acessoBioDelegate && [self.acessoBioDelegate respondsToSelector:@selector(onSystemClosedCameraTimeoutSession)]) {
        [self.acessoBioDelegate onSystemClosedCameraTimeoutSession];
    }
}

- (void)systemClosedCameraTimeoutFaceInference {
    if (self.acessoBioDelegate && [self.acessoBioDelegate respondsToSelector:@selector(onSystemChangedTypeCameraTimeoutFaceInference)]) {
        [self.acessoBioDelegate onSystemChangedTypeCameraTimeoutFaceInference];
    }
}

- (void)onErrorAcessoBioManager:(ErrorBio *)error {
    hasImplementationError = YES;
    if (self.acessoBioDelegate && [self.acessoBioDelegate respondsToSelector:@selector(onErrorAcessoBioManager:)]) {
        [self.acessoBioDelegate onErrorAcessoBioManager:error];
    }else{
        NSLog(@"Método onErrorAcessoBioManager não implementado. Implemente-o e tente novamente...");
    }
}

#pragma mark AcessoBioSelfieDelegate

- (void)onSuccessSelfie:(SelfieResult *)result {
    if(self.selfieDelegate && [self.selfieDelegate respondsToSelector:@selector(onSuccessSelfie:)]) {
        [self.selfieDelegate onSuccessSelfie:result];
    }else{
        NSLog(@"Método onSuccessSelfie não implementado. Implemente-o e tente novamente...");
    }
}

- (void)onErrorSelfie:(ErrorBio *)error {
    if (self.selfieDelegate && [self.selfieDelegate respondsToSelector:@selector(onErrorSelfie:)]) {
        [self.selfieDelegate onErrorSelfie:error];
    }else{
        NSLog(@"Método onErrorSelfie não implementado. Implemente-o e tente novamente...");
    }
}

#pragma mark iAcessoBioDocumentDelegate

- (void)onSuccessDocument: (DocumentResult *)result{
    if(dView.type == 501) {
        if (self.documentDelegate && [self.documentDelegate respondsToSelector:@selector(onSuccessDocument:)]) {
            [self.documentDelegate onSuccessDocument:result];
        }
        [self openCameraDocuments:DocumentRGVerso delegate:self.documentDelegate];
    }else{
        if (self.documentDelegate && [self.documentDelegate respondsToSelector:@selector(onSuccessDocument:)]) {
            [self.documentDelegate onSuccessDocument:result];
        }
    }
}

- (void)onErrorDocument:(ErrorBio *)error{
    if (self.documentDelegate && [self.documentDelegate respondsToSelector:@selector(onErrorDocument:)]) {
        [self.documentDelegate onErrorDocument:error];
    }else{
        NSLog(@"Método onErrorDocument não implementado. Implemente-o e tente novamente...");
    }
}

- (void)classIsNotImplemented:(NSString *)className {
    ErrorBio *errorBio = [[ErrorBio alloc]initCode:400 method:@"Implementação incorreta" desc:[NSString stringWithFormat:@"O método chamado depende da implementação da classe %@ em seu contexto.", className]];
    [self.acessoBioDelegate onErrorAcessoBioManager:errorBio];
}

@end

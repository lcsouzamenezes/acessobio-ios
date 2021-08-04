//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
@import Foundation;
@import UIKit;
#import "ErrorBio.h"

#import "iAcessoBioBuilder.h"
#import "AcessoBioDelegate.h"
#import "AcessoBioSelfieDelegate.h"
#import "AcessoBioDocumentDelegate.h"

@class CameraFaceView;
@class DocumentInsertView;


typedef NS_ENUM(NSInteger, LanguageOrigin) {
    Native,
    Flutter,
    ReactNative
};

@interface UnicoCheck : NSObject {
        
    UIViewController *viewController;
    
    CameraFaceView *cView;
    DocumentInsertView *dView;
    
    NSString *versionRelease;
    
    BOOL isFacematchProcess;
    
    NSString * base64Facematch;
    
    UIImage *imageIconPopupError;
    
    double defaultTimeoutSession;
    double defaultTimeoutToFaceInference;
    double minimumTimeoutToFaceInference;

    BOOL hasImplementationError;
    
}

#pragma mark - Protocos (interface in Java/Kotlin)
@property (nonatomic, weak) id <AcessoBioDelegate> acessoBioDelegate;
@property (nonatomic, weak) id <AcessoBioSelfieDelegate> selfieDelegate;
@property (nonatomic, weak) id <AcessoBioDocumentDelegate> documentDelegate;

#pragma mark - Instance
- (id)initWithViewController:(id)view delegates:(id<AcessoBioDelegate>)delegate;

#pragma mark - Language Origin

- (void)setLanguageOrigin: (LanguageOrigin)origin release: (NSString*)release;
@property (readonly) LanguageOrigin language;

#pragma mark - Custom

- (void)setAutoCapture:(BOOL)isEnabled;
- (void)setSmartFrame:(BOOL)isEnabled;

@property (readonly) BOOL isAutoCapture;
@property (readonly) BOOL isSmartCamera;

@property (nonatomic, strong) UIColor *colorSilhoutteNeutral;
@property (nonatomic, strong) UIColor *colorSilhoutteSuccess;
@property (nonatomic, strong) UIColor *colorSilhoutteError;
@property (nonatomic, strong) UIColor *colorBackground;
@property (nonatomic, strong) UIColor *colorBackgroundBoxStatus;
@property (nonatomic, strong) UIColor *colorTextBoxStatus;
@property (nonatomic, strong) UIColor *colorBackgroundPopupError;
@property (nonatomic, strong) UIColor *colorTextPopupError;
@property (nonatomic, strong) UIColor *colorBackgroundButtonPopupError;
@property (nonatomic, strong) UIColor *colorTitleButtonPopupError;

- (void)setImageIconPopupError: (id)image;

#pragma mark - CloseCamera Manually

- (void)userClosedCameraManually;

#pragma mark - Timeouts

- (void)setTimeoutToFaceInference : (double)seconds;
@property (readonly) double secondsTimeoutSession;
- (void)setTimeoutSession: (double)seconds;
@property (readonly) double secondsTimeoutToFaceInference;

- (void)systemClosedCameraTimeoutSession;
- (void)systemClosedCameraTimeoutFaceInference;

#pragma mark - Camera

#pragma mark Selfie
- (void)openCameraSelfie:(id<AcessoBioSelfieDelegate>)delegate;
#pragma mark Documents
- (void)openCameraDocuments : (DocumentEnums) documentType delegate:(id<AcessoBioDocumentDelegate>)delegate;

#pragma mark - Callbacks

#pragma mark Selfie
- (void)onSuccessSelfie:(SelfieResult *)result;
- (void)onErrorSelfie:(ErrorBio *)error;
#pragma mark Document
- (void)onSuccessDocument: (DocumentResult *)result;
- (void)onErrorDocument:(ErrorBio *)error;
@end


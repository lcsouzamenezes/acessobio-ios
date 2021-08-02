//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ErrorBio.h"

#import "iAcessoBioBuilder.h"
#import "AcessoBioDelegate.h"
#import "AcessoBioSelfieDelegate.h"
#import "AcessoBioDocumentDelegate.h"

@class CameraFaceView;
@class DocumentInsertView;

typedef NS_ENUM(NSInteger, DocumentType) {
    DocumentNone,
    DocumentCNH,
    DocumentRG,
    DocumentRGFrente,
    DocumentRGVerso
};

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
    
    DocumentType documentTypeFacematch;
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
- (void)setSmartFrame: (BOOL)isEnabled;

- (void)disableAutoCapture;
- (void)disableSmartCamera;
@property (readonly) BOOL isAutoCapture;

- (void)enableAutoCapture;
- (void)enableSmartCamera;
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

/** Deprecated
//- (void)openLivenessX;
//- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name;
//- (void)openLivenessXWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone;
*/

- (void)openCameraSelfie:(id<AcessoBioSelfieDelegate>)delegate;
- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name __deprecated_msg("Este método está depreciado e será removido em breve. Para realizar criação de processo use via server-to-server.");
- (void)openCameraFaceWithCreateProcess: (NSString *)code name:(NSString *) name gender: (NSString *)gender birthdate: (NSString *)birthdate email: (NSString *)email phone : (NSString *)phone __deprecated_msg("Este método está depreciado e será removido em breve. Para realizar criação de processo use via server-to-server.");

- (void)openCameraDocuments : (DocumentType) documentType;
- (void)openCameraDocumentOCR : (DocumentType) documentType __deprecated_msg("Este método está depreciado e será removido em breve. Para realizar o OCR use via server-to-server.");
- (void)onErrorCameraDocument: (ErrorBio *)error;
- (void)openCameraDocumentFacematch : (DocumentType) documentType;

- (void)facesCompare: (NSString *)cpf __deprecated_msg("Este método está depreciado e será removido em breve. Para realizar a comparação de face use via server-to-server.");

#pragma mark - Callbacks

- (void)onSuccessSelfie:(SelfieResult *)result;

@end


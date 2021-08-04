//
//  DocumentInsertView.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreImage;
#import "CameraMain.h"
#import "UnicoCheck.h"

typedef NS_ENUM(NSInteger, OperationType) {
    Default,
    OCR,
    Facematch
};

NS_ASSUME_NONNULL_BEGIN

@interface DocumentInsertView : CameraMain {
    UIButton *btClose;
    UIView *vFlash;
    UIActivityIndicatorView *spinFlash;
}

@property (assign, nonatomic)NSInteger type; 
@property (strong, nonatomic) UnicoCheck *core;

@property (assign, nonatomic) OperationType operationType;

@property (strong, nonatomic) UIColor *colorSilhoutte;
@property (strong, nonatomic) UIColor *colorBackground;
@property (strong, nonatomic) UIColor *colorBackgroundBoxStatus;
@property (strong, nonatomic) UIColor *colorTextBoxStatus;

@end

NS_ASSUME_NONNULL_END

//
//  DocumentInsertView.m
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 20/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//

#import "DocumentInsertView.h"
#import "AcessoBioManager.h"
#import "UIImageUtils.h"
#import "FacematchResult.h"

@interface DocumentInsertView ()

@end

@implementation DocumentInsertView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupCamera:NO];
    [self startCamera];
    
    [self addMask];
    
}

- (void)addMask {
    
    float heightViewBottom = 0;
    float valueLessMask = 0;
    
    if(IS_IPHONE_5 || IS_IPHONE_6) {
        heightViewBottom = 110.0f;
        valueLessMask = 40.0f;
    }else{
        heightViewBottom = 150.0f;
        valueLessMask = 0.0f;
    }
    
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (heightViewBottom - valueLessMask) )];
    [iv setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:iv];
    
    UIView *viewBottom = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - heightViewBottom, SCREEN_WIDTH, heightViewBottom)];
    [viewBottom setBackgroundColor:[self getColorPrimary]];
    [self.view addSubview:viewBottom];
    
    
    UILabel *lbStatus = [[UILabel alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - (heightViewBottom/2)) - 10, SCREEN_WIDTH, 40)];
    [lbStatus setTextColor:[UIColor whiteColor]];
    [lbStatus setTextAlignment:NSTextAlignmentCenter];
    [lbStatus setFont:[UIFont fontWithName:@"Avenir-Book" size:18.0]];
    
    
    [self.view addSubview:lbStatus];
    
    
    if(self.type == 4) {
        
        [iv setImage:[UIImage imageNamed:@"frame_cnh" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
        [lbStatus setText:@"Enquadre a CNH aberta"];
    }else if (self.type == 501) {
        [iv setImage:[UIImage imageNamed:@"frame_rg_frente" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
        [lbStatus setText:@"Enquadre o RG frente aberto"];
    }else if (self.type == 502){
        [iv setImage:[UIImage imageNamed:@"frame_rg_verso" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil]];
        [lbStatus setText:@"Enquadre o RG verso aberto"];
    }else{
        [iv setHidden:YES];
        [lbStatus setText:@"Enquadre o documento"];
    }
    
    
    [self.btTakePic setEnabled:YES];
    [self.btTakePic setAlpha:1.0];
    [self.btTakePic setFrame:CGRectMake((SCREEN_WIDTH/2) - 35, SCREEN_HEIGHT - heightViewBottom - 35, 70, 70)];
    [self.btTakePic.layer setMasksToBounds:YES];
    [self.btTakePic.layer setCornerRadius:self.btTakePic.frame.size.height/2];
    [self.btTakePic addTarget:self action:@selector(invokeTakePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btTakePic];
    
    [self addCloseButton];
    
}


#pragma mark - Close
- (void)addCloseButton {
    
    btClose = [[UIButton alloc]initWithFrame:CGRectMake(7, 20, 70, 70)];
    [btClose setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [btClose addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btClose];
    
}

- (void)close {
    [self.acessoBioManager userClosedCameraManually];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) invokeTakePicture {
    
    AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self.renderLock lock];
            [self.renderLock unlock];
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *capturedImage = [[UIImage alloc] initWithData:imageData];
            
            if (self.defaultCamera == AVCaptureDevicePositionFront) {
                capturedImage = [UIImageUtils flipImage:[UIImageUtils imageRotatedByDegrees:capturedImage deg:-90]];
            } else {
                capturedImage = [UIImageUtils imageRotatedByDegrees:capturedImage deg:90];
            }
            
            NSString* base64;
            base64 = [UIImageUtils getBase64Image: capturedImage]; // Utilizar esse base64 para a validação no WebService
            
            [self actionAfterTakePicture:base64];
            
            [self stopCamera];
            
        }
    }];
    
}

- (void)actionAfterTakePicture : (NSString *)base64 {
    
        [self dismissViewControllerAnimated:YES completion:nil];
        CameraDocumentResult *cameraResult = [CameraDocumentResult new];
        cameraResult.base64 = base64;
        [self.acessoBioManager onSuccesCameraDocument:cameraResult];
    
}

- (void)showHUB {
    
    if(vFlash == nil) {
        
        vFlash= [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [vFlash setBackgroundColor:[UIColor whiteColor]];
        [vFlash setAlpha:0.9];
        
        UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
        
        if(self.colorBackground != nil) {
            colorBackground = self.colorBackground;
        }
        [vFlash setBackgroundColor:colorBackground];
        [self.view addSubview:vFlash];
        
        spinFlash = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        if (@available(iOS 13.0, *)) {
            [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            // Fallback on earlier versions
            [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        
        UIColor *colorSpin  = [UIColor whiteColor];
        if(self.colorSilhoutte != nil) {
            colorSpin = self.colorSilhoutte;
        }
        [spinFlash setColor:colorSpin];
        spinFlash.center = self.view.center;
        [spinFlash startAnimating];
        [self.view addSubview:spinFlash];
        
    }
}

- (void)dismissHUB {
    [spinFlash stopAnimating];
    [spinFlash removeFromSuperview];
    [vFlash removeFromSuperview];
    vFlash = nil;
    spinFlash = nil;
}





- (void)exitError {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}


- (NSString *)strErrorFormatted: (NSString *)method description: (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", method, description];
}



@end

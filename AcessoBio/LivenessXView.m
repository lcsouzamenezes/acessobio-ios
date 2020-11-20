//
//  LivenessXView.m
//  CaptureAcesso
//
//  Created by Matheus Domingos on 10/05/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import "LivenessXView.h"

#import <sys/utsname.h> // import it in your header or implementation file.
#import "ValidateLiveness.h"

#import <AudioToolbox/AudioServices.h>

float topOffsetPercentLivenessX = 30.0f;
float sizeBetweenTopAndBottomPercentLivenessX = 50.0f;
float marginOfSidesLivenessX = 80.0f;

const int WAITING_SESSION_INACTIVE = 40;
const int WAITING_ENABLE_BUTTON_INTRO = 4;

@interface LivenessXView ()

@end

@implementation LivenessXView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isSmillingUpponEnter = YES;
    
    arrLeftEyeOpenProbability = [NSMutableArray new];
    
    [self registerNotifications];
    
    countDown = 1;
    
    [self setOffsetTopPercent:30.0f];
    [self setSizePercentBetweenTopAndBottom:20.0f];
    
    isSelfie = YES;
    [self setupCamera:isSelfie];
    [self startCamera];
    
    // High-accuracy landmark detection and face classification
    FIRVisionFaceDetectorOptions *options = [[FIRVisionFaceDetectorOptions alloc] init];
    options.performanceMode = FIRVisionFaceDetectorPerformanceModeAccurate;
    options.landmarkMode = FIRVisionFaceDetectorLandmarkModeAll;
    options.trackingEnabled = YES;
    options.minFaceSize = 0.1;
    options.classificationMode = FIRVisionFaceDetectorClassificationModeAll;
    // Initialize the face detector.
    FIRVision *vision = [FIRVision vision];
    self.faceDetector = [vision faceDetectorWithOptions:options];
    
    lServices = [[LivenessXServices alloc]initWithAuth:self pUrl:self.URL apikey:self.APIKEY token:self.TOKEN];
    
    [self setNewValuesToParamsLiveness];
    
    [self initLiveness];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    
    [self.motionManager stopDeviceMotionUpdates];
    
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resultadoIAClose" object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"resultadoIAAway" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)enableDebug : (NSString*)url apikey: (NSString *)apikey token: (NSString *)token {
    isDebug = YES;
    urlDebug = url;
    apiKeyDebug = apikey;
    tokenDebug = token;
}


#pragma mark - Exit

- (void)close{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Close Button

- (void)addCloseButton {
    
    float y = 20.0f;
    if(IS_IPHONE_XR || IS_IPHONE_X_OR_MORE) {
        y = 40.0f;
    }
    
    btClose = [[UIButton alloc]initWithFrame:CGRectMake(7, y, 70, 70)];
    [btClose setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [btClose addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btClose];
    
}

#pragma mark - Init Liveness

- (void)initLiveness {
    
    lStateType = LivenessStateIntro;
    
    [self initHoleView];
    [self popupIntroShow];
    [self addCloseButton];
    [self createTimerProcess];
    
    [self addFullBrightnessToScreen];
    [self gyroscope];
    [self initVariables];
    
}

#pragma mark - Init variables

-(void)initVariables {
    
    resultFaceDetectBehavior = 0; // 1 = Face Match / 2 = Both substandard / 3 = Not match
    resultFaceDetect = 0; // 1 = Face Match / 2 = Both substandard / 3 = Not match
    
    base64ToUsage = @"";
    
    facesNoMatchInFaceDetect = NO;
    
    SESSION = 0;
    
    TimeSessionFirst = 0;
    TimeSessionSecond = 0;
    TimeSessionThird = 0;
    
    isRequestWebService = NO;
    
    isDoneProcess = NO;
    
}

#pragma mark - Flash

- (void)fireFlash {
    
    if(vFlash == nil) {
        
        vFlash= [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [vFlash setBackgroundColor:[UIColor whiteColor]];
        [vFlash setAlpha:0.9];
        
        if(lStateType != LivenessStateCenter) {
            
            spinFlash = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            if (@available(iOS 13.0, *)) {
                [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
            } else {
                // Fallback on earlier versions
                [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
                
            }
            [spinFlash setColor:[UIColor darkGrayColor]];
            spinFlash.center = self.view.center;
            [spinFlash startAnimating];
            
            HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init]; //Or JGProgressHUDRingIndicatorView
            HUD.progress = 0.3f;
            HUD.textLabel.text = @"Aguarde...";
            [HUD showInView:vFlash];
            
        }
        
        [self.view addSubview:vFlash];
        
    }
    
}

- (void)removeFlash {
    
    if(HUD != nil) {
        [HUD dismiss];
        HUD = nil;
    }
    
    // [spinFlash stopAnimating];
    //   [spinFlash removeFromSuperview];
    [vFlash removeFromSuperview];
    vFlash = nil;
    spinFlash = nil;
}

#pragma mark - Adjust Brightness Of Screen

- (void)addFullBrightnessToScreen {
    [UIScreen mainScreen].brightness = 1.0;
}

- (void)setNewValuesToParamsLiveness {
    marginOfSidesLivenessX = 60.0f;
}


- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            /* start special animation */
            [self showRed];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self showRed];
            break;
            
        default:
            break;
    };
}


- (void)registerNotifications {
    
    // Registrando alteracao de orientacao
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
}

#pragma mark - Resultado IA

- (FIRVisionDetectorImageOrientation)
imageOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
cameraPosition:(AVCaptureDevicePosition)cameraPosition {
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationLeftTop;
            } else {
                return FIRVisionDetectorImageOrientationRightTop;
            }
        case UIDeviceOrientationLandscapeLeft:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationBottomLeft;
            } else {
                return FIRVisionDetectorImageOrientationTopLeft;
            }
        case UIDeviceOrientationPortraitUpsideDown:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationRightBottom;
            } else {
                return FIRVisionDetectorImageOrientationLeftBottom;
            }
        case UIDeviceOrientationLandscapeRight:
            if (cameraPosition == AVCaptureDevicePositionFront) {
                return FIRVisionDetectorImageOrientationTopRight;
            } else {
                return FIRVisionDetectorImageOrientationBottomRight;
            }
        default:
            return FIRVisionDetectorImageOrientationTopLeft;
    }
}


- (void)getResultadoIACenterObjc:(NSDictionary *)dictIA {
    
    dictLivenessResultCenter = dictIA;
    [self validateLiveness];
    
}

- (void)getResultadoIAFaceOkIntro:(NSDictionary *)dictIA {
    
    dictLivenessResultFaceOkIntro = dictIA;
    
    BOOL fotoboaFaceOk = [[dictLivenessResultFaceOkIntro valueForKey:@"fotoboa"] boolValue];
    confidenceFaceOK = [[dictLivenessResultFaceOkIntro valueForKey:@"confidence"] floatValue];
    
    if(!fotoboaFaceOk) {
        if(confidenceFaceOK > 0.8) {
            confidenceFaceOK = 1 - confidenceFaceOK;
        }else{
            fotoboaFaceOk = YES;
        }
    }
    
    if(!fotoboaFaceOk) {
        [self vibrate];
    }
    
}

#pragma mark - Read Model IA

- (void)readModelOBJC: (UIImage *) image isFaceOkIntro: (BOOL)isFaceOkIntro {
    
    if (@available(iOS 11.0, *)) {
        
        MLModel *model;
        VNCoreMLModel *m;
        VNCoreMLRequest *request;
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSURL *centerModelURL = [bundle URLForResource: @"CenterModelCrop" withExtension: @"mlmodel"];
        NSURL *mobAwayModelURL = [bundle URLForResource: @"CenterModelCrop" withExtension: @"mlmodel"];
        
        NSError *err;
        if ([centerModelURL checkResourceIsReachableAndReturnError:&err] == NO)
            NSLog(@"%@", err);
        
        if ([mobAwayModelURL checkResourceIsReachableAndReturnError:&err] == NO)
            NSLog(@"%@", err);
        
        // Compile is Magic. This is trick to library.
        NSURL *urlCenterModel = [MLModel compileModelAtURL:centerModelURL error:&err];
        NSURL *urlAwayModel = [MLModel compileModelAtURL:mobAwayModelURL error:&err];
        
        model = [[[MobAwayLiveness alloc] initWithContentsOfURL:urlAwayModel error:&err] model];
        
        m = [VNCoreMLModel modelForMLModel: model error:nil];
        request = [[VNCoreMLRequest alloc] initWithModel: m completionHandler: (VNRequestCompletionHandler) ^(VNRequest *request, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSInteger numberOfResults = request.results.count;
                NSArray *results = [request.results copy];
                VNClassificationObservation *topResult = ((VNClassificationObservation *)(results[0]));
                NSString *messageLabel = [NSString stringWithFormat: @"%f: %@", topResult.confidence, topResult.identifier];
                
                int intIdentifier = 1;
                if([topResult.identifier isEqualToString:@"fotodefoto"]) {
                    intIdentifier = 0;
                }
                
                NSDictionary *resultDict = @{@"confidence" : [NSNumber numberWithFloat:topResult.confidence], @"fotoboa": [NSNumber numberWithInt:intIdentifier]};
                
                if(isFaceOkIntro) {
                    [self getResultadoIAFaceOkIntro:resultDict];
                }else{
                    [self getResultadoIACenterObjc:resultDict];
                }
                
            });
        }];
        
        request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
        
        CIImage *coreGraphicsImage = [[CIImage alloc] initWithImage:image];
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:coreGraphicsImage  options:@{}];
            [handler performRequests:@[request] error:nil];
        });
        
    }
    
    
}

#pragma mark - Setup Hole Transparent

- (void)initHoleView {
    
    [self setParamsRectFaces];
    
    if(vHole != nil) {
        [vHole removeFromSuperview];
    }
    
    [self removeFlash];
    
    self->frameCurrent = frameFaceAway;
    
    UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
    
    if(self.colorBackground != nil) {
        colorBackground = self.colorBackground;
    }
    
    vHole = [[UIViewWithHole alloc] initWithFrame:self.view.frame backgroundColor:colorBackground andTransparentRect:frameCurrent cornerRadius:0];
    [self.view addSubview:vHole];
    [self addImageAcessoBio];
    
}

- (void)addVHole: (CGRect) rect  {
    
    [self->vHole removeFromSuperview];
    
    UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
    
    if(self.colorBackground != nil) {
        colorBackground = self.colorBackground;
    }
    
    self->vHole = [[UIViewWithHole alloc] initWithFrame:self.view.frame backgroundColor:colorBackground andTransparentRect:rect cornerRadius:0];
    [self.view addSubview:self->vHole];
    
}

- (void)removeVHole {
    [self->vHole removeFromSuperview];
    [self->vAlert removeFromSuperview];
    [self.view bringSubviewToFront:self->btClose];
}

- (void)changeHoleView: (CGRect) newRect delayInSeconds: (double)delayInSeconds {
    
    if(!CGRectEqualToRect(newRect, CGRectZero)) {
        self->frameCurrent = newRect;
    }
    
    isSuccessAnimated = NO;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addVHole:newRect];
            [self.view bringSubviewToFront:self->vAlert];
            [self.view bringSubviewToFront:self->btClose];
            [self.view bringSubviewToFront:self->ivAcessoBio];
            
            self->isProccessIA = NO;
            
        });
        
    });
    
}




- (void)setParamsRectFaces {
    
    frameFaceCenter = CGRectMake((SCREEN_WIDTH/2) - 125 ,(SCREEN_HEIGHT/2) - 180, 250, 400);
    frameFaceAway = CGRectMake((SCREEN_WIDTH/2) - 90 ,(SCREEN_HEIGHT/2) - 140, 180, 280);
    frameFaceCloser = CGRectMake((SCREEN_WIDTH/2) - 150 ,(SCREEN_HEIGHT/2) - 250, 300, 500);
    
}

#pragma mark - Setup Camera

- (void) setupCamera:(BOOL) isSelfie {
    [super setupCamera:isSelfie];
    
}

- (void) startCamera {
    [self.session startRunning];
}

- (void) stopCamera {
    [self.session stopRunning];
}

- (void)setIsDebug : (BOOL)debug {
    self.debug = debug;
    
    if(self.debug) {
        
        UIButton *btClear = [[UIButton alloc]initWithFrame:CGRectMake(20, SCREEN_HEIGHT - 100 , 80, 50)];
        [btClear setTitle:@"RESET" forState:UIControlStateNormal];
        [btClear.titleLabel setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0]];
        [btClear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btClear setBackgroundColor:[UIColor blackColor]];
        [btClear addTarget:self action:@selector(clearDots) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btClear];
        
        viewLog = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 160)];
        [viewLog setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:viewLog];
        
        lbLeftEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 150, 20)];
        [lbLeftEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEye setTextColor: [UIColor blackColor]];
        [lbLeftEye setTag:-1];
        [viewLog addSubview:lbLeftEye];
        
        lbRightEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, 150, 20)];
        [lbRightEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEye setTextColor: [UIColor blackColor]];
        [lbRightEye setTag:-1];
        [viewLog addSubview:lbRightEye];
        
        lbNosePosition = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 150, 20)];
        [lbNosePosition setFont:[UIFont systemFontOfSize:10.0]];
        [lbNosePosition setTextColor: [UIColor blackColor]];
        [lbNosePosition setTag:-1];
        [viewLog addSubview:lbNosePosition];
        
        lbLeftEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 150, 20)];
        [lbLeftEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbLeftEar setTextColor: [UIColor blackColor]];
        [lbLeftEar setTag:-1];
        [viewLog addSubview:lbLeftEar];
        
        lbRightEar = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 150, 20)];
        [lbRightEar setFont:[UIFont systemFontOfSize:10.0]];
        [lbRightEar setTextColor: [UIColor blackColor]];
        [lbRightEar setTag:-1];
        [viewLog addSubview:lbRightEar];
        
        lbEulerX = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 150, 20)];
        [lbEulerX setFont:[UIFont systemFontOfSize:10.0]];
        [lbEulerX setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbEulerX];
        
        lbSpaceEye = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 150, 20)];
        [lbSpaceEye setFont:[UIFont systemFontOfSize:10.0]];
        [lbSpaceEye setTextColor: [UIColor blackColor]];
        [lbEulerX setTag:-1];
        [viewLog addSubview:lbSpaceEye];
        
        UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, topOffsetPercentLivenessX, SCREEN_WIDTH, 2)];
        [v1 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v1];
        
        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBetweenTopAndBottomPercentLivenessX, SCREEN_WIDTH, 2)];
        [v2 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v2];
        
        UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(marginOfSidesLivenessX, 0, 2, SCREEN_HEIGHT)];
        [v3 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v3];
        
        UIView *v4 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - marginOfSidesLivenessX, 0, 2, SCREEN_HEIGHT)];
        [v4 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v4];
        
    }
    
}

- (void)setOffsetTopPercent : (float)percent {
    topOffsetPercentLivenessX = percent/100 *  SCREEN_HEIGHT;
}

- (void)setSizePercentBetweenTopAndBottom  : (float)percent {
    float pixels = percent/100 *  SCREEN_HEIGHT;
    sizeBetweenTopAndBottomPercentLivenessX = topOffsetPercentLivenessX + pixels;
}

- (void)setMarginOfSides: (float)margin {
    marginOfSidesLivenessX = margin;
}

- (void)clearDots {
    for (UIView *view in [self.view subviews]) {
        if(view.tag == - 1) {
            [view removeFromSuperview];
        }
    }
}

- (void)addCircleToPoint : (CGPoint) point color : (UIColor *)color{
    
    CGFloat widht = 10;
    
    CGFloat POINT_X = point.x;
    CGFloat POINT_Y = point.y;
    
    CGRect circleRect = CGRectMake(POINT_X - (widht / 2), POINT_Y - (widht / 2), widht, widht);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *circleView = [[UIView alloc] initWithFrame:circleRect];
        circleView.layer.cornerRadius = widht/2;
        circleView.alpha = 0.7;
        circleView.backgroundColor = color;
        circleView.tag = -1;
        [self.view addSubview:circleView];
        
    });
    
}

- (void)addLabelToLog : (CGPoint) point type : (NSString * )type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if([type isEqualToString:@"left_eye"]) {
            [self->lbLeftEye setText:[NSString stringWithFormat:@"Leyft eye - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_eye"]) {
            [self->lbRightEye setText:[NSString stringWithFormat:@"Right eye - X: %.0f Y: %.0f", point.x, point.y]];
        }if([type isEqualToString:@"left_ear"]) {
            [self->lbLeftEar setText:[NSString stringWithFormat:@"Leyft ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"right_ear"]) {
            [self->lbRightEar setText:[NSString stringWithFormat:@"Right ear - X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"euler"]) {
            [self->lbEulerX setText:[NSString stringWithFormat:@"Euler X: %.0f Y: %.0f", point.x, point.y]];
        }else if([type isEqualToString:@"space-eye"]) {
            [self->lbSpaceEye setText:[NSString stringWithFormat:@"Space eye: %.0f", point.x]];
        }else{
            [self->lbNosePosition setText:[NSString stringWithFormat:@"Base nose - X: %.0f Y: %.0f", point.x, point.y]];
        }
        
    });
    
}

- (void) capture {
    
    if(!isDoneProcess) {
        
        if(!self->isProccessIA) {
            
            if(!isTakingPhoto) {
                
                isTakingPhoto = YES;
                
                // [self fireFlash];
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self take];
                });
                
                
            }
            
        }
    }
    
}


- (void)take {
    
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
            
            // [self stopCamera];
            //[self generateHashFromImage:capturedImage];
            
            NSString* base64;
            base64 = [UIImageUtils getBase64Image: capturedImage]; // Utilizar esse base64 para a validação no WebService
            
            if(self->lStateType == LivenessStateIntro) {
                
                [self actionAfterTakePicture:base64 image:capturedImage];
                
            }else {
                
                if(self->isPhotoAwayToCapture) {
                    self->isPhotoAwayToCapture = NO;
                    self->isTakingPhoto  = NO;
                    self->_base64AwayWithoutSmilling = base64;
                    self.imgAwayWithoutSmile = capturedImage;
                }else{
                    
                    //Como é assincrono, eu defino como processando a IA e disparo uma action dps de 3 segundos verificando se a thread UI foi liberada. Caso nao, eu libero.
                    
                    self->isTakingPhoto  = NO;
                    self->isProccessIA = YES;
                    [self performSelector:@selector(resetVariableProcessIA) withObject:nil afterDelay:3.0];;
                    [self actionAfterTakePicture:base64 image:capturedImage];
                }
                
            }
            
        }
    }];
    
}

#pragma mark - Processamento de imagem

- (void)changeState: (LivenessStateType )lType {
    
    isShowAlertToLiveness = NO;
    
    if(!isStartProcessIA) {
        
        isStartProcessIA = YES;
        lStateType = LivenessStateDone;
        // [self createCustomAlert:@"Validando" message:@""];
        [self readModelOBJC:self.imgCenter isFaceOkIntro:NO];
        
    }
    
}

- (void)validateLiveness {
    
    //    if(isDarkImage([self croppIngimage:self.imgAway toRect:CGRectMake(0, 0, 720, 300)])) {
    //       // [self popupShow];
    //        return;
    //    }
    
    isValidating = YES;
    
    [self removeVHole];
    [self validateBlinking];
    
    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    float confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] floatValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    int timeLastSession = 0;
    if(SESSION == 0) {
        timeLastSession = TimeSessionFirst;
    }else if(SESSION == 1) {
        timeLastSession = TimeSessionSecond;
    }else if(SESSION == 2) {
        timeLastSession = TimeSessionThird;
    }
    
    int sessionWhichEnded = 0;
    sessionWhichEnded = SESSION + 1;
    
    NSDictionary *dictValidate = @{
        @"photoCloseLive": [NSNumber numberWithBool:fotoboaCenter],
        @"photoCloseConfidence": [NSNumber numberWithFloat:confidenceCenter],
        @"photoAwayLive": [NSNumber numberWithBool:fotoboaCenter],
        @"photoAwayConfidence" : [NSNumber numberWithFloat:confidenceCenter],
        @"isSmilling" : [NSNumber numberWithBool:self.isLivenessSmilling],
        @"isBlinking" : [NSNumber numberWithBool:self.isLivenessBlinking],
        @"userBlinks" : [NSNumber numberWithInt:userBlinks],
        @"isFastProcess" : [NSNumber numberWithBool:isFastProcess],
        @"isFinishiWithoutTheSmile" : [NSNumber numberWithBool:self.isFinishiWithoutTheSmile],
        @"timeLastSession" : [NSNumber numberWithInt:timeLastSession],
        @"sessionWhichEnded" : [NSNumber numberWithInt:sessionWhichEnded],
        @"timeToSmilling" : [NSNumber numberWithInt:timeToSmiling],
        @"timeTotalProcess": [NSNumber numberWithInt:durationProcess]
    };
    
    
    NSDictionary *result = [ValidateLiveness validateLivenessV2:dictValidate];
    fTotal = [[result valueForKey:@"total"] floatValue];
    _isFaceLiveness = [[result valueForKey:@"isLive"] boolValue];
    
    
    if(_isFaceLiveness){
        
        [self fireFlash];
        [self stopCamera];
        
        [self performSelector:@selector(forceDoneProcess) withObject:nil afterDelay:20];;
        [self faceDetect];
        [self faceDetectBehavior];
        
    }else{
        
        if([self verifySession]) {
            
            isValidating = NO;
            
            isRequestWebService = NO;
            [self removeFlash];
            [self startCamera];
            isStartProcessIA = NO;
            self->isShowAlertLiveness = NO;
            [self resetSessionSpoofing];
            
        }else{
            
            [self performSelector:@selector(forceDoneProcess) withObject:nil afterDelay:20];;
            [self stopCamera];
            self.isFaceLiveness = NO;
            [self sendBillingV3];
            
        }
        
        [self.view bringSubviewToFront:btClose];
        
    }
    
    isDoneValidate = YES;
    
}

- (void)managerTimersInTheProcess {
    
    if(!isRequestWebService) {
        
        durationProcess ++;
        
        if(lStateType == LivenessStateIntro) {
            
            if(durationProcess == WAITING_ENABLE_BUTTON_INTRO) {
                [popupIntro enableButton];
            }
            
            if (durationProcess == WAITING_SESSION_INACTIVE) {
                [self exitError:@"Tempo de sessão expirada por inatividade."];
            }
            
        }else{
            
            if(SESSION == 0) {
                TimeSessionFirst++;
            }else if(SESSION == 1) {
                TimeSessionSecond++;
            }else if(SESSION == 2){
                TimeSessionThird++;
            }
            
            if(durationProcess > 10) {
                isFastProcess = NO;
            }else{
                isFastProcess = YES;
            }
            
        }
        
    }
    
}

- (void) addImageAcessoBio {
    
    if(IS_IPHONE_X || IS_IPHONE_6P){
        ivAcessoBio = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, SCREEN_HEIGHT - 70, 100, 40)];
        
    }else{
        ivAcessoBio = [[UIImageView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH/2) - 50, SCREEN_HEIGHT - 50, 100, 40)];
    }
    
    [ivAcessoBio setImage:[UIImage imageNamed:@"ic_bio"]];
    [ivAcessoBio setContentMode:UIViewContentModeScaleAspectFit];
    [ivAcessoBio setTag:-99];
    [self.view addSubview:ivAcessoBio];
    
}

-(void)validateBlinking {
    
    NSArray *floatBlink = [arrLeftEyeOpenProbability copy];
    
    int blinks = 0;
    int blinkPosition = 0;
    for (int x = 0; x < ([arrLeftEyeOpenProbability count]-1); x++) {
        // verifico se há ao menos uma correspondência anterior.
        
        if(x > 1) {
            
            float sProbability =  [[floatBlink objectAtIndex:x] floatValue];
            
            if(sProbability < 0.8f){
                float sProbabilityBefore = [[floatBlink objectAtIndex:x-1] floatValue];
                if(sProbabilityBefore > 0.9f) {
                    blinkPosition = x;
                }
            }
            
            if(x == (blinkPosition + 1) || x == (blinkPosition + 2)) {
                if(sProbability > 0.9f) {
                    blinks++;
                }
            }
            
        }
        
    }
    
    if(blinks >  0) {
        userBlinks = blinks;
        self.isLivenessBlinking = YES;
        
    }else{
        self.isLivenessBlinking = NO;
    }
    
    
}



-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if(!isDoneProcess) {
        
        FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
        AVCaptureDevicePosition cameraPosition =
        AVCaptureDevicePositionBack;  // Set to the capture device you used.
        metadata.orientation =
        [self imageOrientationFromDeviceOrientation:UIDevice.currentDevice.orientation
                                     cameraPosition:cameraPosition];
        
        FIRVisionImage *image = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
        image.metadata = metadata;
        
        [self.faceDetector
         processImage:image
         completion:^(NSArray<FIRVisionFace *> *_Nullable faces, NSError *_Nullable error) {
            
            if (self->isPopUpShow) {
                return;
            }
            
            if([faces count] > 0) {
                
                if([faces count] == 1) {
                    
                    self->countNoFace = 0;
                    
                    FIRVisionFace *faceFeature = faces[0];
                    
                    FIRVisionFaceLandmark *noseBaseLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeNoseBase];
                    
                    if(noseBaseLandmark != nil) {
                        
                        if(faceFeature.hasLeftEyeOpenProbability || faceFeature.hasRightEyeOpenProbability) {
                            [self->arrLeftEyeOpenProbability addObject:[NSNumber numberWithFloat:faceFeature.leftEyeOpenProbability]];
                        }
                        
                        if(self->isShowAlertLiveness) {
                            return;
                        }
                        
                        if(!self->isShowAlertToLiveness){
                            self->isShowAlertToLiveness = YES;
                        }
                        
                        if(self->lStateType == LivenessStateIntro) {
                            [self analyzeFaceCenter:faceFeature];
                        }else {
                            [self analyzeFaceAway:faceFeature];
                        }
                        
                        
                    }else{
                        //  countNoNose++;
                        //if(countNoNose >= 10)
                        [self showGray];
                    }
                }
            }else{
                self->countNoFace++;
                if(self->countNoFace >= 20)
                    [self showGray];
                
            }}];
    }
    
    if ([self.renderLock tryLock]) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
        self.latestFrame = image;
        [self.renderLock unlock];
    }
    
}

- (void)analyzeFaceCenter  : (FIRVisionFace *)faceFeature{
    
    FIRVisionFaceLandmark *leftEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEye];
    
    CGPoint leftEyePosition = [self pointFromVisionPoint:leftEyeLandmark.position];
    
    FIRVisionFaceLandmark *rightEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEye];
    
    CGPoint rightEyePosition = [self pointFromVisionPoint:rightEyeLandmark.position];
    
    FIRVisionFaceLandmark *leftEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEar];
    
    CGPoint leftEarPosition = [self pointFromVisionPoint:leftEarLandmark.position];
    
    FIRVisionFaceLandmark *rightEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEar];
    
    CGPoint rightEarPosition = [self pointFromVisionPoint:rightEarLandmark.position];
    
    FIRVisionFaceLandmark *noseBaseLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeNoseBase];
    
    CGPoint noseBasePosition = [self pointFromVisionPoint:noseBaseLandmark.position];
    
    
    countNoNose = 0;
    
    /*
     - Get poits position at screen.
     */
    
    CGFloat scale = 2;// [UIScreen mainScreen].scale;
    
    // Olhos
    CGFloat X_LEFT_EYE_POINT = SCREEN_WIDTH - (leftEyePosition.x/scale);
    CGFloat Y_LEFT_EYE_POINT = leftEyePosition.y/scale;
    
    CGFloat X_RIGHT_EYE_POINT = SCREEN_WIDTH - (rightEyePosition.x/scale);
    CGFloat Y_RIGHT_EYE_POINT = rightEyePosition.y/scale;
    
    // Orelhas
    CGFloat X_LEFT_EAR_POINT = SCREEN_WIDTH - (leftEarPosition.x/scale);
    CGFloat Y_LEFT_EAR_POINT = leftEarPosition.y/scale;
    
    CGFloat X_RIGHT_EAR_POINT = SCREEN_WIDTH - (rightEarPosition.x/scale);
    CGFloat Y_RIGHT_EAR_POINT = rightEarPosition.y/scale;
    
    // Nariz
    CGFloat X_NOSEBASEPOSITION_POINT = SCREEN_WIDTH - (noseBasePosition.x/scale);
    CGFloat Y_NOSEBASEPOSITION_POINT = noseBasePosition.y/scale;
    
    //Angulo
    CGFloat ANGLE_HORIZONTAL = faceFeature.headEulerAngleY;
    CGFloat ANGLE_VERTICAL = faceFeature.headEulerAngleZ;
    
    /*
     ------
     */
    
    /*
     - Plot points to visually with color on the screen.
     */
    
    
    if(self.debug){
        
        [self addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
        
        [self addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
        [self addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
        
        [self addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
        
        [self addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
        
        
        
        [self addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
        [self addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
        
        [self addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
        [self addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
        
        [self addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
        
        [self addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
        
    }
    
    
    /*
     ------
     */
    
    if(self.debug){
        NSLog(@"X_NOSEBASEPOSITION_POINT %.2f - Y_NOSEBASEPOSITION_POINT %.2f", noseBasePosition.x, noseBasePosition.y);
    }
    
    BOOL hasError = NO;
    NSMutableString *strError = [NSMutableString new];
    
    /*
     - Verify wether face is centralized.
     */
    //if((Y_NOSEBASEPOSITION_POINT > 250  && Y_NOSEBASEPOSITION_POINT < 400) &&
    
    
    if(leftEyeLandmark != nil && rightEyeLandmark != nil)  {
        
        if(self.debug) {
            NSLog(@"ORELHA ESQUERDA: %.2f", X_LEFT_EAR_POINT);
            NSLog(@"FRAME FACE X: %.2f", frameFaceCenter.origin.x);
            NSLog(@"ORELHA DIREITA: %.2f", X_RIGHT_EAR_POINT);
            NSLog(@"FRAME FACE X + W: %.2f", frameFaceCenter.origin.x + frameFaceCenter.size.width);
            NSLog(@"DISTANCIA OLHOS: %.2f", fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT) * 2);
        }
        
        int leftMargin = frameFaceCenter.origin.x;
        int rightMargin = (frameFaceCenter.origin.x + frameFaceCenter.size.width);
        
        
        float minimumDistance = 150;
        
        
        if(X_RIGHT_EAR_POINT < leftMargin || X_LEFT_EAR_POINT > rightMargin) {
            countTimeAlert ++;
            // [self showRed];
            if(hasError){
                [strError appendString:@" / Put your face away"];
            }else{
                [strError appendString:@"Put your face away"];
            }
            hasError = YES;
            
        }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < minimumDistance) {
            countTimeAlert ++;
            // [self showRed];
            if(hasError){
                [strError appendString:@" / Bring the face closer"];
            }else{
                [strError appendString:@"Bring the face closer"];
            }
            
            hasError = YES;
            
        }else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
            countTimeAlert ++;
            if(hasError){
                [strError appendString:@" / Inclined face"];
            }else{
                [strError appendString:@"Inclined face"];
            }
            hasError = YES;
            
        }
        
    }
    
    
    //[self addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
    
    if(ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
        countTimeAlert ++;
        //[self showRed];
        if(hasError){
            if(ANGLE_HORIZONTAL > 20) {
                [strError appendString:@" / Turn slightly left"];
            }else if(ANGLE_HORIZONTAL < -20){
                [strError appendString:@" / Turn slightly right"];
            }
        }else{
            if(ANGLE_HORIZONTAL > 20) {
                [strError appendString:@"Turn slightly left"];
            }else if(ANGLE_HORIZONTAL < -20){
                [strError appendString:@"Turn slightly right"];
            }
        }
        hasError = YES;
        
    }
    
    if(hasError) {
        [self showAlert:strError];
        hasError = NO;
    }else{
        [self faceOK]; // Face is centralized.
    }
    
}


- (void)analyzeFaceAway  :  (FIRVisionFace *)faceFeature{
    
    
    FIRVisionFaceLandmark *leftEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEye];
    
    CGPoint leftEyePosition = [self pointFromVisionPoint:leftEyeLandmark.position];
    
    FIRVisionFaceLandmark *rightEyeLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEye];
    
    CGPoint rightEyePosition = [self pointFromVisionPoint:rightEyeLandmark.position];
    
    FIRVisionFaceLandmark *leftEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeLeftEar];
    
    CGPoint leftEarPosition = [self pointFromVisionPoint:leftEarLandmark.position];
    
    FIRVisionFaceLandmark *rightEarLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeRightEar];
    
    CGPoint rightEarPosition = [self pointFromVisionPoint:rightEarLandmark.position];
    
    FIRVisionFaceLandmark *noseBaseLandmark = [faceFeature landmarkOfType:FIRFaceLandmarkTypeNoseBase];
    
    CGPoint noseBasePosition = [self pointFromVisionPoint:noseBaseLandmark.position];
    
    
    countNoNose = 0;
    
    /*
     - Get poits position at screen.
     */
    
    CGFloat scale = 2;// [UIScreen mainScreen].scale;
    
    // Olhos
    CGFloat X_LEFT_EYE_POINT = SCREEN_WIDTH - (leftEyePosition.x/scale);
    CGFloat Y_LEFT_EYE_POINT = leftEyePosition.y/scale;
    
    CGFloat X_RIGHT_EYE_POINT = SCREEN_WIDTH - (rightEyePosition.x/scale);
    CGFloat Y_RIGHT_EYE_POINT = rightEyePosition.y/scale;
    
    // Orelhas
    CGFloat X_LEFT_EAR_POINT = SCREEN_WIDTH - (leftEarPosition.x/scale);
    CGFloat Y_LEFT_EAR_POINT = leftEarPosition.y/scale;
    
    CGFloat X_RIGHT_EAR_POINT = SCREEN_WIDTH - (rightEarPosition.x/scale);
    CGFloat Y_RIGHT_EAR_POINT = rightEarPosition.y/scale;
    
    // Nariz
    CGFloat X_NOSEBASEPOSITION_POINT = SCREEN_WIDTH - (noseBasePosition.x/scale);
    CGFloat Y_NOSEBASEPOSITION_POINT = noseBasePosition.y/scale;
    
    //Angulo
    CGFloat ANGLE_HORIZONTAL = faceFeature.headEulerAngleY;
    CGFloat ANGLE_VERTICAL = faceFeature.headEulerAngleZ;
    
    /*
     ------
     */
    
    /*
     - Plot points to visually with color on the screen.
     */
    
    
    if(self.debug){
        
        [self addCircleToPoint:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) color:[UIColor redColor]];
        
        [self addCircleToPoint:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) color:[UIColor yellowColor]];
        [self addCircleToPoint:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) color:[UIColor yellowColor]];
        
        [self addCircleToPoint:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) color:[UIColor blueColor]];
        
        [self addCircleToPoint:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) color:[UIColor greenColor]];
        
        
        
        [self addLabelToLog:CGPointMake(X_LEFT_EYE_POINT, Y_LEFT_EYE_POINT) type:@"left_eye"];
        [self addLabelToLog:CGPointMake(X_RIGHT_EYE_POINT, Y_RIGHT_EYE_POINT) type:@"right_eye"];
        
        [self addLabelToLog:CGPointMake(X_LEFT_EAR_POINT, Y_LEFT_EAR_POINT) type:@"left_ear"];
        [self addLabelToLog:CGPointMake(X_RIGHT_EAR_POINT, Y_RIGHT_EAR_POINT) type:@"right_ear"];
        
        [self addLabelToLog:CGPointMake(X_NOSEBASEPOSITION_POINT, Y_NOSEBASEPOSITION_POINT) type:@"nose_base"];
        
        [self addLabelToLog:CGPointMake((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2, 0) type:@"space-eye"];
        
    }
    
    
    /*
     ------
     */
    
    if(self.debug) {
        NSLog(@"X_NOSEBASEPOSITION_POINT %.2f - Y_NOSEBASEPOSITION_POINT %.2f", noseBasePosition.x, noseBasePosition.y);
    }
    
    BOOL hasError = NO;
    NSMutableString *strError = [NSMutableString new];
    
    /*
     - Verify wether face is centralized.
     */
    //if((Y_NOSEBASEPOSITION_POINT > 250  && Y_NOSEBASEPOSITION_POINT < 400) &&
    
    
    
    
    if(leftEyeLandmark != nil && rightEyeLandmark != nil)  {
        
        if(self.debug) {
            NSLog(@"Y_LEFT_EYE_POINT: %.2f - Y_RIGHT_EYE_POINT %.2f", Y_LEFT_EYE_POINT, Y_RIGHT_EYE_POINT);
            NSLog(@"DIFERENCA ENTRE OLHOS Y: %.2f",fabs(Y_LEFT_EYE_POINT -  rightEyePosition.y));
            NSLog(@"DIFERENCA ENTRE OLHOS X: %.2f",fabs(leftEyePosition.x -  Y_RIGHT_EYE_POINT));
        }
        
        
        int leftMargin = frameFaceCenter.origin.x;
        int rightMargin = (frameFaceCenter.origin.x + frameFaceCenter.size.width);
        
        
        if(X_RIGHT_EAR_POINT < leftMargin || X_LEFT_EAR_POINT > rightMargin) {
            countTimeAlert ++;
            // [self showRed];
            if(hasError){
                [strError appendString:@" / Center face"];
            }else{
                [strError appendString:@"Center face"];
            }
            hasError = YES;
            
        }else   if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) > 160) {
            countTimeAlert ++;
            // [self showRed];
            if(hasError){
                [strError appendString:@" / Put your face away"];
            }else{
                [strError appendString:@"Put your face away"];
            }
            hasError = YES;
            
        }else if(((fabs(X_LEFT_EYE_POINT - X_RIGHT_EYE_POINT)) * 2) < 110) {
            countTimeAlert ++;
            // [self showRed];
            if(hasError){
                [strError appendString:@" / Bring the face closer"];
            }else{
                [strError appendString:@"Bring the face closer"];
            }
            
            hasError = YES;
            
        } else if((fabs(Y_LEFT_EYE_POINT - Y_RIGHT_EYE_POINT) > 20) || (fabs(Y_RIGHT_EYE_POINT - Y_LEFT_EYE_POINT) > 20)){
            countTimeAlert ++;
            if(hasError){
                [strError appendString:@" / Inclined face"];
            }else{
                [strError appendString:@"Inclined face"];
            }
            hasError = YES;
            
        }
        
    }
    
    
    [self addLabelToLog:CGPointMake(ANGLE_HORIZONTAL , ANGLE_VERTICAL) type:@"euler"];
    
    if(ANGLE_HORIZONTAL > 20 || ANGLE_HORIZONTAL < -20) {
        countTimeAlert ++;
        //[self showRed];
        if(hasError){
            if(ANGLE_HORIZONTAL > 20) {
                [strError appendString:@" / Turn slightly left"];
            }else if(ANGLE_HORIZONTAL < -20){
                [strError appendString:@" / Turn slightly right"];
            }
        }else{
            if(ANGLE_HORIZONTAL > 20) {
                [strError appendString:@"Turn slightly left"];
            }else if(ANGLE_HORIZONTAL < -20){
                [strError appendString:@"Turn slightly right"];
            }
        }
        hasError = YES;
        
    }
    
    delayToVerifySmilling ++;
    if(delayToVerifySmilling == 20) {
        if(self.base64AwayWithoutSmilling.length == 0) {
            isPhotoAwayToCapture = YES;
            [self capture];
        }
    }
    
    if(delayToVerifySmilling > 30) {
        
        if(faceFeature.hasSmilingProbability) {
            
            if(!isVerifiedSmillingUpponEnter) {
                if(faceFeature.smilingProbability < 0.8) {
                    isSmillingUpponEnter = NO;
                }
                
                isVerifiedSmillingUpponEnter = YES;
            }
            
            if(isSmillingUpponEnter) {
                
                if(faceFeature.smilingProbability > 0.8) {
                    
                    if(!hasError){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if(self->timerToSmiling == nil) {
                                self->timerToSmiling = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToSmiling) userInfo:nil repeats:YES];
                            }
                            
                            [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                            
                        });
                    }
                    
                }else{
                    self.isLivenessSmilling = YES;
                }
                
            }else{
                
                
                if(faceFeature.smilingProbability < 0.8) {
                    //hasError = YES;
                    
                    if(!hasError){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if(self->timerToSmiling == nil) {
                                self->timerToSmiling = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToSmiling) userInfo:nil repeats:YES];
                            }
                            
                            [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                            
                        });
                    }
                    
                    
                }else{
                    self.isLivenessSmilling = YES;
                }
                
                
            }
            
        }
        
    }
    
    
    if(hasError) {
        [self showAlert:strError];
        hasError = NO;
    }else{
        [self faceOK];
    }
    
}


- (CGPoint)pointFromVisionPoint:(FIRVisionPoint *)visionPoint {
    return CGPointMake(visionPoint.x.floatValue, visionPoint.y.floatValue);
}


- (void)showAlert : (NSString *)alert {
    
    if(countTimeAlert >= 10) {
        
        countTimeAlert = 0;
        isShowAlert = NO;
        
        [self showRed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.75;
            [self->lbMessage.layer addAnimation:animation forKey:@"kCATransitionFade"];
            
            
            UIColor *colorLbMessage = [UIColor whiteColor];
            
            if(self.colorTextBoxStatus != nil) {
                colorLbMessage = self.colorTextBoxStatus;
            }
            [self->lbMessage setTextColor:colorLbMessage];
            
            
            if(self->lStateType == LivenessStateCenter){
                
                if([alert containsString:@"Center face"]){
                    [self setMessageStatus:@"Enquadre o seu rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else if([alert containsString:@"Put your face away"]){
                    [self setMessageStatus:@"Afaste o rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else if ([alert containsString:@"Bring the face closer"]){
                    [self setMessageStatus:@"Aproxime o rosto"];
                    [self->lbMessage setTextColor:colorLbMessage];
                }else{
                    [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                }
                
            }else{
                
                if([alert containsString:@"Bring the face closer"]){
                    [self setMessageStatus:@"Aproxime o rosto"];
                }else{
                    [self setMessageStatus:@"Dê um sorriso  \U0001F604"];
                }
            }
            
            
            
        });
        
    }
    
}

- (void)showRed{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self resetSmilling];
        
        UIColor *colorBorder  = [UIColor whiteColor];
        if(self.colorSilhoutteError != nil) {
            colorBorder = self.colorSilhoutteError;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorBorder CGColor];
        
    });
    
}

- (void)showGray{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self resetSmilling];
        [self setMessageStatus:@"Enquadre seu rosto"];
        
        UIColor *colorTextMessage  = [UIColor whiteColor];
        if(self.colorTextBoxStatus != nil) {
            colorTextMessage = self.colorTextBoxStatus;
        }
        
        [self->lbMessage setTextColor:colorTextMessage];
        
        
        UIColor *colorBorder  = [UIColor whiteColor];
        if(self.colorSilhoutteNeutral != nil) {
            colorBorder = self.colorSilhoutteNeutral;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorBorder CGColor];
        
    });
    
}

- (void)faceOK{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        if(self->lStateType == LivenessStateIntro) {
            
            if(!self->hasFaceOK) {
                self->hasFaceOK = YES;
                [self capture];
            }
            
            return;
        }
        
        if(self->lStateType == LivenessStateCenter) {
            
            if(self.isLivenessSmilling || self.isFinishiWithoutTheSmile) {
                [self capture];
            }else{
                if(!self->isResetRunning) {
                    self->isResetRunning = YES;
                    
                    self->timerToTakeCenterPhoto = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToTakeCenterPhoto) userInfo:nil repeats:YES];
                    
                    [self performSelector:@selector(resetSession) withObject:nil afterDelay:10];;
                }
            }
            
        }else{
            
            if(!self->isCountDown) {
                [self createTimer];
                self->isCountDown = YES;
            }
            
            
        }
        
        if(!self->isProccessIA) {
            
            if(self->lStateType != LivenessStateCenter) {
                [self->vAlert setHidden:YES];
                [self setMessageStatus:@"Não se mexa..."];
            }
            
        }
        
        UIColor *colorSuccess = [self getColorGreen];
        if(self.colorSilhoutteSuccess != nil) {
            colorSuccess = self.colorSilhoutteSuccess;
        }
        self->vHole.shapeLayer.strokeColor = [colorSuccess CGColor];
        
    });
    
}

#pragma mark - liveness_Session

// Initialize or restart params and variables to the session.
- (void)initSession {
    
    lbMessage.text = @"";
    isResetRunning = NO;
    
    [self resetBase64s];
    [self resetSmilling];
    [self resetBlinking];
    
    [self invalidateTimerToTakeCenterPhoto];
    
    resultFaceDetect = 0;
    resultFaceDetectBehavior = 0;
    
    lStateType = LivenessStateCenter;
    
}

- (void)resetBase64s{
    self.base64Closer = @"";
    self.base64Center = @"";
    self.base64Away = @"";
    self.base64AwayWithoutSmilling = @"";
}

- (void)resetBlinking {
    arrLeftEyeOpenProbability = [NSMutableArray new];
}

- (void)resetSession {
    
    if(!isValidating) {
        if(!isDoneValidate) {
            
            if(!self.isLivenessBlinking) {
                
                if([self verifySession]){
                    
                    [self initSession];
                    
                    SESSION++;
                    attemptsValidate ++;
                    isResetSessionValidate = YES;
                    
                    [self initialActionOfChangeState:YES];
                    
                }else{
                    
                    self.isFinishiWithoutTheSmile = YES;
                    
                }
            }
            
        }
    }
    
}

- (void)resetSessionSpoofing {
    
    if([self verifySession]){
        
        [self initSession];
        
        if(isResetSessionNoComputated) {
            isResetSessionNoComputated = NO;
        }else{
            isResetSessionSpoofing = YES;
            SESSION++;
            attemptsSpoofing ++;
        }
        
        [self initialActionOfChangeState:YES];
        
    }
    
}

- (bool)verifySession {
    
    if(SESSION < 3) {
        return YES;
    }else{
        return NO;
    }
    
}

- (void)resetSmilling{
    
    timeToSmiling = 0;
    delayToVerifySmilling = 0;
    isVerifiedSmillingUpponEnter = NO;
    isSmillingUpponEnter = YES;
    self.isLivenessSmilling = NO;
    [self invalidateTimerToSmiling];
    
}

- (void)resetTimer {
    [self->timerCountDown invalidate];
    self->countDown = 1.3;
    self->isCountDown = NO;
    self->timerCountDown = nil;
}


- (void)createTimerProcess {
    if(timerProcesss == nil) {
        timerProcesss = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(managerTimersInTheProcess)
                                                       userInfo:nil
                                                        repeats:YES];
    }
}

- (void)createTimer {
    
    if(lStateType != LivenessStateCenter) {
        countDown = 0;
    }
    
    self->timerCountDown = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                            target:self
                                                          selector:@selector(countDown)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)countDown {
    
    if(!isShowAlertLiveness) {
        
        
        if(countDown == 1) {
            //                if(!self->isSuccessAnimated) {
            //                    self->isSuccessAnimated = YES;
            //                    [self->vHole startAnimationSuccess];
            //                }
        }
        
        if(countDown == 0) {
            if(!self->isSuccessAnimated) {
                self->isSuccessAnimated = YES;
                // [self->vHole startAnimationSuccess];
            }
            [self resetTimer];
            [self capture];
        }
        
        countDown --;
        
    }
    
    
    
}


- (void)switchCam {
    
    
    if(self.session)
    {
        //Indicate that some changes will be made to the session
        [self.session beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [self.session.inputs objectAtIndex:0];
        [self.session removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
            NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
            [self.session addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [self.session commitConfiguration];
    }
    
    
}

- (void)actionAfterTakePicture : (NSString *)base64 image:(UIImage *)image {
    
    isTakingPhoto = NO;
    [self removeFlash];
    
    if(lStateType == LivenessStateIntro) {
        
        [popupIntro enableButton];
        _base64FaceOkIntro = base64;
        _imgFaceOkIntro = image;
        [self readModelOBJC:_imgFaceOkIntro isFaceOkIntro:YES];
        
    } else {
        
        _base64Center = base64;
        _imgCenter = image;
        pitchClose = pPitch;
        rollClose = pRoll;
        yawClose = pYaw;
        luminosityClose = luminosity;
        
        [self changeState:lStateType];
        
    }
    
}

- (void)doneFaceInsert {
    
    //    if(self.cam != nil){
    //        [self.cam onSuccesCapture:self.base64Center];
    //    }
    
}


- (void)showAlertLivenessStep: (NSString *)message {
    
    isShowAlertLiveness = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                                     message:nil
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            //We add buttons to the alert controller by creating UIAlertActions:
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Entendi"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action){
                self->isShowAlertLiveness = NO;
                
            }];
            [alertController addAction:actionOk];
            [self presentViewController:alertController animated:YES completion:nil];
            
            
        });
        
    });
    
}


- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

- (void)report {
    
}

- (void)invalidateAllTimers {
    [self invalidateTimerProcess];
    [self invalidateTimerToTakeCenterPhoto];
    [self invalidateTimerToSmiling];
}

- (void)invalidateTimerProcess {
    if(timerProcesss != nil) {
        [timerProcesss invalidate];
        timerProcesss = nil;
    }
}

- (void)invalidateTimerToTakeCenterPhoto {
    if(timerToTakeCenterPhoto != nil) {
        [timerToTakeCenterPhoto invalidate];
        timerToTakeCenterPhoto = nil;
    }
}

- (void)invalidateTimerToSmiling {
    if(timerToSmiling != nil) {
        [timerToSmiling invalidate];
        timerToSmiling = nil;
    }
}

- (void)initialActionOfChangeState : (BOOL)fromReset {
    
    if(!isDoneProcess) {
        
        if(self->lStateType == LivenessStateDone){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            
            [self createTimerToTakeCenterPhoto];
            [self createViewAlert];
            
            if(fromReset) {
                [self popupShow];
            }
            
        }
        
    }
    
}

- (void)createTimerToTakeCenterPhoto {
    timerToTakeCenterPhoto = nil;
    timerToTakeCenterPhoto = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(incrementTimeToTakeCenterPhoto) userInfo:nil repeats:YES];
    
}

- (void)resetVariableProcessIA {
    if(isProccessIA){
        isProccessIA = NO;
    }
}

- (void)incrementTimeToTakeCenterPhoto {
    if(!isRequestWebService)
        timeToTakeCenterPhoto ++;
}


- (void)incrementTimeToSmiling {
    if(!isRequestWebService)
        timeToSmiling ++;
}

- (void)createViewAlert {
    
    
    if(popup == nil) {
        
        vAlert = [[UIView alloc]initWithFrame:CGRectMake(50, (frameFaceCenter.origin.y - 25) , SCREEN_WIDTH - 100, 50)];
        
        UIColor *colorBackgroundBox = [UIColor colorWithRed:24.0f/255.0f green:30.0f/255.0f blue:45.0f/255.0f alpha:1.0];
        if(self.colorBackgroundBoxStatus != nil) {
            colorBackgroundBox = self.colorBackgroundBoxStatus;
        }
        [vAlert setBackgroundColor:colorBackgroundBox];
        [vAlert setAlpha:1.0f];
        [vAlert.layer setMasksToBounds:YES];
        [vAlert.layer setCornerRadius:10.0];
        [self.view addSubview:vAlert];
        
        //    vAlert.layer.shadowRadius  = 1.5f;
        //    vAlert.layer.shadowColor   = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:1.f].CGColor;
        //    vAlert.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
        //    vAlert.layer.shadowOpacity = 0.5f;
        //    vAlert.layer.masksToBounds = NO;
        //
        //    UIEdgeInsets shadowInsets     = UIEdgeInsetsMake(0, 0, -1.5f, 0);
        //    UIBezierPath *shadowPath      = [UIBezierPath bezierPathWithRect:UIEdgeInsetsInsetRect(vAlert.bounds, shadowInsets)];
        //    vAlert.layer.shadowPath    = shadowPath.CGPath;
        
        lbMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vAlert.frame.size.width, 50)];
        [lbMessage setText:@"Enquadre seu rosto"];
        [lbMessage setMinimumScaleFactor:0.5];
        
        
        UIColor *colorLbMessage = [UIColor whiteColor];
        
        if(self.colorTextBoxStatus != nil) {
            colorLbMessage = self.colorTextBoxStatus;
        }
        [lbMessage setTextColor:colorLbMessage];
        
        [lbMessage setBackgroundColor:colorBackgroundBox];
        
        [lbMessage setTextAlignment:NSTextAlignmentCenter];
        [lbMessage setFont:[UIFont boldSystemFontOfSize:17.5]];
        [vAlert addSubview:lbMessage];
        
        //   [self startBlinkingLabel:lbMessage];
    }
    
    
    
}

- (void)fireAlert : (NSString *)message {
    
    
}

- (void)setMessageStatus: (NSString *)str {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->popup == nil) {
            [self->vAlert setHidden:NO];
            [self->lbMessage setText:str];
        }else{
            [self->vAlert setHidden:YES];
            [self->lbMessage setText:@""];
        }
    });
    
}

-(void) startBlinkingLabel:(UILabel *)label
{
    label.alpha =1.0f;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionAutoreverse |UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction |UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        label.alpha = 0.0f;
    }
                     completion:^(BOOL finished){
        if (finished) {
            
        }
    }];
}

-(void) stopBlinkingLabel:(UILabel *)label
{
    // REMOVE ANIMATION
    [label.layer removeAnimationForKey:@"opacity"];
    label.alpha = 1.0f;
}


- (void)forceDoneProcess {
    
    if(!validateFaceDetectOK) {
        [self doneProcess];
    }
    
}

- (void)doneProcess {
    
    if(HUD != nil) {
        HUD.progress = 1.0f;
    }
    
    if(!isDoneProcess){
        [self invalidateAllTimers];
        
        isDoneProcess = YES;
        [self stopCamera];
        
        if(livenessXResult != nil) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.acessiBioManager onSuccesLivenessX:self->livenessXResult];
            }];
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
    }
    
}

- (void)exitError {
    [self invalidateAllTimers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)exitError: (NSString *)error{
    [self.acessiBioManager onErrorLivenessX:error];
    [self invalidateAllTimers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Services

#pragma mark  Send Billing v3

- (void)sendBillingV3 {
    
    isRequestWebService = YES;
    
    NSUUID *uuid = [NSUUID UUID];
    strUuid = [uuid UUIDString];
    
    NSString *status = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isFaceLiveness]];
    
    if([status isEqualToString:@"0"]){
        status = @"2";
    }
    
    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    double confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] doubleValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    
    if(self.base64AwayWithoutSmilling.length == 0) {
        self.base64AwayWithoutSmilling = self.base64Away;
    }
    
    NSMutableArray *fields = [NSMutableArray new];
    [fields addObject:[self getDictField:@"isLive" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isFaceLiveness]]]];
    [fields addObject:[self getDictField:@"Score" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:fTotal]]]];
    [fields addObject:[self getDictField:@"isLiveClose" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:fotoboaCenter]]]];
    [fields addObject:[self getDictField:@"ScoreClose" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:confidenceCenter]]]];
    [fields addObject:[self getDictField:@"isLiveAway" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:fotoboaCenter]]]];
    [fields addObject:[self getDictField:@"ScoreAway" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:confidenceCenter]]]];
    [fields addObject:[self getDictField:@"IsBlinking" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isLivenessBlinking]]]];
    [fields addObject:[self getDictField:@"IsSmilling" value:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:self.isLivenessSmilling]]]];
    [fields addObject:[self getDictField:@"DeviceModel" value:[self deviceName]]];
    [fields addObject:[self getDictField:@"IsResetSession" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:isResetSessionValidate]]]];
    [fields addObject:[self getDictField:@"AttemptsValidate" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:attemptsValidate]]]];
    [fields addObject:[self getDictField:@"IsResetSessionSpoofing" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:isResetSessionSpoofing]]]];
    [fields addObject:[self getDictField:@"AttemptsSpoofing" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:attemptsSpoofing]]]];
    [fields addObject:[self getDictField:@"TimeTotal" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:durationProcess]]]];
    [fields addObject:[self getDictField:@"Blinks" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:userBlinks]]]];
    [fields addObject:[self getDictField:@"TimeSmilling" value: [NSString stringWithFormat:@"%@",  [NSNumber numberWithInt:timeToSmiling]]]];
    [fields addObject:[self getDictField:@"TimeSessionFirst" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithFloat:TimeSessionFirst]]]];
    [fields addObject:[self getDictField:@"TimeSessionSecond" value:  [NSString stringWithFormat:@"%@", [NSNumber numberWithInt:TimeSessionSecond]]]];
    [fields addObject:[self getDictField:@"TimeSessionThird" value: [NSString stringWithFormat:@"%@",  [NSNumber numberWithInt:TimeSessionThird]]]];
    [fields addObject:[self getDictField:@"ScoreFaceDetect" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:scoreFacedetect]]]];
    [fields addObject:[self getDictField:@"DevicePitch" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchAway]]]];
    [fields addObject:[self getDictField:@"DeviceRoll" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollAway]]]];
    [fields addObject:[self getDictField:@"DeviceYaw" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:yawAway]]]];
    [fields addObject:[self getDictField:@"DevicePitchClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchClose]]]];
    [fields addObject:[self getDictField:@"DeviceRollClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollClose]]]];
    [fields addObject:[self getDictField:@"DeviceYawClose" value:[NSString stringWithFormat:@"%@",  [NSNumber numberWithDouble:yawClose]]]];
    [fields addObject:[self getDictField:@"DevicePitchInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:pitchInitial]]]];
    [fields addObject:[self getDictField:@"DeviceRollInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:rollInitial]]]];
    [fields addObject:[self getDictField:@"DeviceYawInitial" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:yawInitial]]]];
    [fields addObject:[self getDictField:@"DeviceLuminosity" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:luminosityAway]]]];
    [fields addObject:[self getDictField:@"DeviceLuminosityClose" value: [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:luminosityClose]]]];
    
    NSDictionary *params = @{
        @"id" : strUuid,
        @"status" : status,
        @"fields": fields
    };
    
    //    Para logar o json
    //     NSString *jsonRequest = [self bv_jsonStringWithPrettyPrint:params];
    
    [lServices sendBillingV3:params];
    
    if(isDebug) {
        [self sendLiveness];
    }
    
}

- (void)onSuccessSendBilling {
    
    self->billingId = strUuid;
    
    if(self.acessiBioManager.createProcess == nil || !self->_isFaceLiveness) {
        
        NSString *baseWithBilling = [NSString stringWithFormat:@"data:%@/image/jpeg;base64,%@", self->billingId, self->base64ToUsage];
        
        LivenessXResult *livenessXResult = [LivenessXResult new];
        [livenessXResult setBase64:self->base64ToUsage];
        [livenessXResult setIsLiveness:self->_isFaceLiveness];
        [self.acessiBioManager onSuccesLivenessX:livenessXResult];
        [self doneProcess];
        
    }else{
        [self createProcessV3];
    }
    
}

- (void)onErrorSendBilling: (NSString *)error {
    
    if(self.debug) {
        NSLog(@"Error: %@", error);
    }
    
    self->isRequestWebService = NO;
    [self.acessiBioManager onErrorLivenessX:error];
    [self exitError];
    
}

#pragma mark Face Detect

- (void)faceDetect{
    
    validateFaceDetectOK = NO;
    isRequestWebService = YES;
    [lServices faceDetectInital:_base64Center base64Away:_base64FaceOkIntro];
    
}

- (void)onSuccessFaceDetectInitial : (FaceDetectResult *) faceDetectResult {
    
    if(faceDetectResult.FaceResult == 0){
        self->resultFaceDetect = 2;
    }else if (!faceDetectResult.Similars) {
        self->resultFaceDetect = 3;
    }else{
        self->scoreFacedetect = faceDetectResult.SimilarScore;
        self->resultFaceDetect = 1;
    }
    
    
    if(faceDetectResult.FaceResult != 0) {
        if(faceDetectResult.FaceResult == 1){
            self->base64ToUsage = self->_base64Center;
        }else if(faceDetectResult.FaceResult == 2){
            self->base64ToUsage = self->_base64AwayWithoutSmilling;
        }
    }
    
    [self validateFaceDetect];
    
}

- (void)onErrorFaceDetectInitial: (NSString *)error {
    
    if(self.debug) {
        NSLog(@"Error: %@", error);
    }
    
    self->isRequestWebService = NO;
    [self.acessiBioManager onErrorLivenessX:error];
    [self exitError];
    
}


#pragma mark faceDetectBehavior

- (void)faceDetectBehavior {
    
    isRequestWebService = YES;
    [lServices faceDetectBehavior:_base64AwayWithoutSmilling base64Away:_base64Center];
    
}

- (void)onSuccessFaceDetectBehavior : (FaceDetectResult *) faceDetectResult {
    
    if(faceDetectResult.FaceResult == 0){
        self->resultFaceDetectBehavior = 2;
    }else if (!faceDetectResult.Similars) {
        self->resultFaceDetectBehavior = 3;
    }else{
        self->resultFaceDetectBehavior = 1;
    }
    
    [self validateFaceDetect];
    
}

- (void)onErrorFaceDetectBehavior: (NSString *)error {
    
    if(self.debug) {
        NSLog(@"Error: %@", error);
    }
    
    self->isRequestWebService = NO;
    [self.acessiBioManager onErrorLivenessX:error];
    [self exitError];
    
}

-(void) validateFaceDetect{
    
    // Verify if both request have a return response
    if(resultFaceDetectBehavior == 0 || resultFaceDetect == 0) {
        
        if(HUD != nil) {
            HUD.progress = 0.6f;
        }
        
        return;
    }else{
        validateFaceDetectOK = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel perform selectors with the target like a self
    }
    
    // Both substandard
    if(resultFaceDetect == 2){
        
        [self removeFlash];
        [self startCamera];
        
        isRequestWebService = NO;
        isValidating = NO;
        
        isResetSessionNoComputated = YES;  // para resetar sem contar como uma sessão a mais.
        [self resetSessionSpoofing];
        
    }else if(resultFaceDetect == 3 || resultFaceDetectBehavior == 3) { // Not match
        
        if([self verifySession]) {
            
            isRequestWebService = NO;
            isValidating = NO;
            
            [self removeFlash];
            [self startCamera];
            isStartProcessIA = NO;
            self->isShowAlertLiveness = NO;
            [self resetSessionSpoofing];
            
        }else{
            
            self.isFaceLiveness = NO;
            [self sendBillingV3];
            
        }
        
    }else if(resultFaceDetectBehavior == 1 && resultFaceDetect == 1) { // Match faces
        
        if(HUD != nil) {
            HUD.progress = 0.8f;
        }
        
        [self sendBillingV3];
        
    }
    
}

#pragma mark - Liveness Request

-(void) sendLiveness  {
    
    isRequestWebService = YES;
    
    DebugLivenessXServices *debugLivenessService = [[DebugLivenessXServices alloc] initWithAuth:self pUrl:urlDebug apikey:apiKeyDebug token:tokenDebug];
    [debugLivenessService sendLiveness:[self getDictLiveness] processId:_proccessId];
    
}

- (NSDictionary *)getDictLiveness{
    
    BOOL fotoboaCenter = [[dictLivenessResultCenter valueForKey:@"fotoboa"] boolValue];
    double confidenceCenter = [[dictLivenessResultCenter valueForKey:@"confidence"] doubleValue];
    
    if(!fotoboaCenter) {
        if(confidenceCenter > 0.8) {
            confidenceCenter = 1 - confidenceCenter;
        }else{
            fotoboaCenter = YES;
        }
    }
    
    if(self.base64AwayWithoutSmilling.length == 0) {
        self.base64AwayWithoutSmilling = self.base64Away;
    }
    
    NSDictionary *params = @{@"isLive": [NSNumber numberWithBool:self.isFaceLiveness],
                             @"Score": [NSNumber numberWithFloat:fTotal],
                             @"isLiveClose" : [NSNumber numberWithBool:fotoboaCenter],
                             @"ScoreClose" : [NSNumber numberWithDouble:confidenceCenter],
                             @"isLiveAway" : [NSNumber numberWithBool:fotoboaCenter],
                             @"ScoreAway":[NSNumber numberWithDouble:confidenceCenter],
                             @"IsBlinking" :  [NSNumber numberWithBool:self.isLivenessBlinking],
                             @"IsSmilling":  [NSNumber numberWithBool:self.isLivenessSmilling],
                             @"UserName": self.acessiBioManager.createProcess.name,
                             @"UserCPF": self.acessiBioManager.createProcess.code,
                             @"DeviceModel": [self deviceName],
                             @"Base64Center" : self.base64Center,
                             @"Base64Away" : self.base64AwayWithoutSmilling,
                             @"IsResetSession" :  [NSNumber numberWithBool:isResetSessionValidate],
                             @"AttemptsValidate" :  [NSNumber numberWithInt:attemptsValidate],
                             @"IsResetSessionSpoofing" :  [NSNumber numberWithBool:isResetSessionSpoofing],
                             @"AttemptsSpoofing" :  [NSNumber numberWithInt:attemptsSpoofing],
                             @"TimeTotal" : [NSNumber numberWithFloat:durationProcess],
                             @"Blinks" : [NSNumber numberWithInt:userBlinks],
                             @"TimeSmilling" : [NSNumber numberWithInt:timeToSmiling],
                             @"TimeSessionFirst" : [NSNumber numberWithFloat:TimeSessionFirst],
                             @"TimeSessionSecond" : [NSNumber numberWithInt:TimeSessionSecond],
                             @"TimeSessionThird" : [NSNumber numberWithInt:TimeSessionThird],
                             @"ScoreFaceDetect" : [NSNumber numberWithDouble:scoreFacedetect],
                             @"BiometryStatus" : [NSNumber numberWithInt:0],
                             @"BiometryMessage" : @"",
                             @"BiometryStatusAway" : [NSNumber numberWithInt:0],
                             @"BiometryMessageAway" : @"",
                             @"DevicePitch": [NSNumber numberWithDouble:pitchAway],
                             @"DeviceRoll" : [NSNumber numberWithDouble:rollAway],
                             @"DeviceYaw": [NSNumber numberWithDouble:yawAway],
                             @"DevicePitchClose": [NSNumber numberWithDouble:pitchClose],
                             @"DeviceRollClose": [NSNumber numberWithDouble:rollClose],
                             @"DeviceYawClose": [NSNumber numberWithDouble:yawClose],
                             @"DevicePitchInitial": [NSNumber numberWithDouble:pitchInitial],
                             @"DeviceRollInitial": [NSNumber numberWithDouble:rollInitial],
                             @"DeviceYawInitial": [NSNumber numberWithDouble:yawInitial],
                             @"DeviceLuminosity" :[NSNumber numberWithDouble:luminosityAway],
                             @"DeviceLuminosityClose": [NSNumber numberWithDouble:luminosityClose],
                             @"Log" : @"",
                             @"Origin" : @"Liveness X1",
                             @"ScoreFaceOK": [NSNumber numberWithFloat:confidenceFaceOK],
                             @"Base64FaceOK" : _base64FaceOkIntro
                             
    };
    
    return params;
    
}


-(NSString*) bv_jsonStringWithPrettyPrint: (NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }
    return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
}

- (NSDictionary *)getDictField: (NSString *)key value: (id)value {
    return @{@"key": key, @"value": value};
}

#pragma mark - Create Process v3

- (void)createProcessV3 {
    
    isRequestWebService = YES;
    
    NSString *baseWithBilling = [NSString stringWithFormat:@"data:%@/image/jpeg;base64,%@", billingId, base64ToUsage];
    NSDictionary *dict = @{
        @"subject" : @{
                @"Code": self.acessiBioManager.createProcess.code,
                @"Name":self.acessiBioManager.createProcess.name
        },
        @"onlySelfie" : [NSNumber numberWithBool:YES],
        @"imagebase64": baseWithBilling
    };
    
    [lServices createProcessV3:dict];
    
    
}

- (void)onSucessCreateProcessV3 : (NSString *)pProcessId {
    
    self->livenessXResult = [LivenessXResult new];
    [self->livenessXResult setBase64:self->base64ToUsage];
    [self->livenessXResult setIsLiveness:self->_isFaceLiveness];
    [self->livenessXResult setProcessId:pProcessId];
    
    self->processId = livenessXResult.processId;
    
    [self doneProcess];
    
}

#pragma mark - Sensors

- (void)vibrate {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)sensors {
    [self gyroscope];
}

- (void)gyroscope {
    
    if(isValidating) {
        return;
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
                                                            toQueue:[NSOperationQueue currentQueue]
                                                        withHandler:^(CMDeviceMotion *motion, NSError *error)
     {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            if(self.motionManager.deviceMotion != nil) {
                
                CMQuaternion quat = self.motionManager.deviceMotion.attitude.quaternion;
                
                double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));
                double pitch = RADIANS_TO_DEGREES(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
                double roll = RADIANS_TO_DEGREES(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
                
                pitch = pitch - 90;
                
                self->pPitch = pitch;
                self->pRoll = roll;
                self->pYaw = yaw;
                                
                if(self->pitchInitial == 0) {
                    self->pitchInitial = pitch;
                    self->rollInitial = roll;
                    self->yawInitial = yaw;
                }
                
            }
            
            
        }];
    }];
    
}

- (void)luminosity:(CMSampleBufferRef)sampleBuffer {
    
    if(isValidating) {
        return;
    }
    
    if(!isStartLuminositySensor) {
        isStartLuminositySensor = YES;
        
        CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,
                                                                     sampleBuffer, kCMAttachmentMode_ShouldPropagate);
        NSDictionary *metadata = [[NSMutableDictionary alloc]
                                  initWithDictionary:(__bridge NSDictionary*)metadataDict];
        CFRelease(metadataDict);
        NSDictionary *exifMetadata = [[metadata
                                       objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
        float brightnessValue = [[exifMetadata
                                  objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
        
        luminosity = brightnessValue;
        
    }
    
}

#pragma mark - Popup's

- (void)popupShow {
    
    [self vibrate];
    
    isPopUpShow = YES;
    
    [vAlert setHidden:YES];
    [self removeFlash];
    
    [self addVHole:CGRectZero];
    
    popup = [[PopUpValidationLiveness alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH/2) - 165), ((SCREEN_HEIGHT/2) - 265) , 330, 530)];
    [popup setType:PopupTypeGeneric lView:self];
    
    UIColor *colorBackgroundPopup = [UIColor whiteColor];
    if(self.colorBackgroundPopupError != nil) {
        colorBackgroundPopup = self.colorBackgroundPopupError;
    }
    [popup setBackgroundColor:colorBackgroundPopup];
    
    UIColor *colorBackgroundButtonPopupError = [UIColor colorWithRed:41.0f/255.0f green:128.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    if(self.colorBackgroundButtonPopupError != nil) {
        colorBackgroundButtonPopupError = self.colorBackgroundButtonPopupError;
    }
    [popup setBackgroundColorButton:colorBackgroundButtonPopupError];
    
    UIColor *colorTitleButtonPopupError = [UIColor whiteColor];
    if(self.colorTitleButtonPopupError != nil) {
        colorTitleButtonPopupError = self.colorTitleButtonPopupError;
    }
    [popup setTitleColorButton:colorTitleButtonPopupError];
    
    if(self.imageIconPopupError != nil) {
        [popup setImageIconPopupError:self.imageIconPopupError];
    }
    
    [self.view addSubview:popup];
    
}

- (void)popupHidden {
    
    isPopUpShow = NO;
    
    [self changeHoleView:frameCurrent delayInSeconds:0];
    
    [popup removeFromSuperview];
    popup = nil;
    
}

- (void)popupIntroShow {
    
    [vAlert setHidden:YES];
    [self removeFlash];
    
    [self addVHole:CGRectZero];
    
    popupIntro = [[PopUpIntro alloc]initWithFrame:CGRectMake(((SCREEN_WIDTH/2) - 165), ((SCREEN_HEIGHT/2) - 265) , 330, 530)];
    [popupIntro initLayout:self];
    
    UIColor *colorBackgroundPopup = [UIColor whiteColor];
    if(self.colorBackgroundPopupError != nil) {
        colorBackgroundPopup = self.colorBackgroundPopupError;
    }
    [popupIntro setBackgroundColor:colorBackgroundPopup];
    
    UIColor *colorBackgroundButtonPopupError = [UIColor colorWithRed:41.0f/255.0f green:128.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    if(self.colorBackgroundButtonPopupError != nil) {
        colorBackgroundButtonPopupError = self.colorBackgroundButtonPopupError;
    }
    [popupIntro setBackgroundColorButton:colorBackgroundButtonPopupError];
    
    UIColor *colorTitleButtonPopupError = [UIColor whiteColor];
    if(self.colorTitleButtonPopupError != nil) {
        colorTitleButtonPopupError = self.colorTitleButtonPopupError;
    }
    [popupIntro setTitleColorButton:colorTitleButtonPopupError];
    
    if(self.imageIconPopupError != nil) {
        [popupIntro setImageIconPopupError:self.imageIconPopupError];
    }
    
    [self.view addSubview:popupIntro];
    
}

- (void)popupIntroHidden {
    
    [popupIntro removeFromSuperview];
    popupIntro = nil;
    
    lStateType = LivenessStateCenter;
    [self changeHoleView:frameCurrent delayInSeconds:0];
    [self initialActionOfChangeState:NO];

    
}


#pragma mark - General

-(NSString*) deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

- (UIColor *)getColorPrimary {
    return [UIColor colorWithRed:41.0/255.0 green:128.0/255.0 blue:255.0/255.0 alpha:1.0];
}


- (UIColor *)getColorGreen {
    return [UIColor colorWithRed:59.0f/255.0f green:200.0f/255.0f blue:47.0f/255.0f alpha:1.0];
}


- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    
    return retVal;
}

- (NSString *)strErrorFormatted: (NSString *)method description: (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", method, description];
}

@end

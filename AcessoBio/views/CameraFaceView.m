//
//  CameraFaceView.m
//  CaptureAcesso
//
//  Created by Matheus Domingos on 10/05/20.
//  Copyright © 2020 Matheus  domingos. All rights reserved.
//

#import "CameraFaceView.h"

@import Darwin.POSIX.sys.utsname; // import it in your header or implementation file.
#import "DeviceUtils.h"
#import "UnicoCheck.h"
#import "Base64Utils.h"

float topOffsetPercent_CameraFace = 30.0f;
float sizeBetweenTopAndBottomPercent_CameraFace = 50.0f;
float marginOfSides_CameraFace = 80.0f;


@interface CameraFaceView ()

@end

@implementation CameraFaceView


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
    
    
    if(self.isEnableAutoCapture) {
        [self.btTakePic setHidden:YES];
    }else{
        [self.btTakePic setHidden:NO];
    }
    
    [self initVariables];
    
    [self initialActionOfChangeState:NO];
    [self addFullBrightnessToScreen];
    [self triggerTimeoutProcess];
    if(self.isEnableSmartCapture) {
        [self triggerTimeoutToFaceInference];
    }
    
    //sensorDevice = [[SensorsDevice alloc]init];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self invalidateAllTimers];
}

-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)triggerTimeoutProcess {
    timerToTimoutSession = [NSTimer scheduledTimerWithTimeInterval: self.secondsTimeoutSession
                                                            target: self
                                                          selector:@selector(closeTriggerTimeoutProcess)
                                                          userInfo: nil repeats:NO];
}

- (void)triggerTimeoutToFaceInference {
    timerToTimoutFaceInference = [NSTimer scheduledTimerWithTimeInterval: self.secondsTimeoutToInferenceFace
                                                                  target: self
                                                                selector:@selector(closeTriggerTimeoutToFaceInference)
                                                                userInfo: nil repeats:NO];
}

- (void)closeTriggerTimeoutProcess {
    [self.delegate systemClosedCameraTimeoutSession];
    [self exit];
}

- (void)closeTriggerTimeoutToFaceInference {
    [self.delegate systemClosedCameraTimeoutFaceInference];
    [self disableSmartCamera];
}

- (void)disableSmartCamera {
    _isEnableAutoCapture = NO;
    _isEnableSmartCapture = NO;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.btTakePic setHidden:NO];
        [self.btTakePic setAlpha:1];
        [self.btTakePic setEnabled:YES];
    });
}

#pragma mark - Close
- (void)addCloseButton {
    
    float yPosition = 0;
    if([DeviceUtils hasSmallScreen]) {
        yPosition = 20;
    }else{
        yPosition = 40;
    }
    
    btClose = [[UIButton alloc]initWithFrame:CGRectMake(7, yPosition, 70, 70)];
    [btClose setImage:[UIImage imageNamed:@"ic_close" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [btClose addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btClose];
    
}

- (void)close{
    [self.delegate userClosedCameraManually];
    [self exit];
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
        
        UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
        
        if(self.colorBackground != nil) {
            colorBackground = self.colorBackground;
        }
        //        [vFlash setBackgroundColor:colorBackground];
        [self.view addSubview:vFlash];
        
        spinFlash = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        if (@available(iOS 13.0, *)) {
            [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            // Fallback on earlier versions
            [spinFlash setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        
        //        UIColor *colorSpin  = [UIColor whiteColor];
        //        if(self.colorSilhoutteNeutral != nil) {
        //            colorSpin = self.colorSilhoutteNeutral;
        //        }
        [spinFlash setColor:colorBackground];
        spinFlash.center = self.view.center;
        [spinFlash startAnimating];
        [self.view addSubview:spinFlash];
        
    }
    
}

- (void)removeFlash {
    
    [spinFlash stopAnimating];
    [spinFlash removeFromSuperview];
    [vFlash removeFromSuperview];
    vFlash = nil;
    spinFlash = nil;
}

#pragma mark - Adjust Brightness Of Screen

- (void)addFullBrightnessToScreen {
    [UIScreen mainScreen].brightness = 1.0;
}

- (void)setNewValuesToParamsLiveness {
    marginOfSides_CameraFace = 60.0f;
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


#pragma mark - Setup Hole Transparent

- (void)initHoleView {
    
    [self setParamsRectFaces];
    
    if(vHole != nil) {
        [vHole removeFromSuperview];
    }
    
    [self removeFlash];
    
    self->frameCurrent = frameFaceCenter;
    
    
    UIColor *colorBackground = [UIColor colorWithRed:57.0f/255.0f green:74.0f/255.0f blue:98.0f/255.0f  alpha:0.9f];
    
    if(self.colorBackground != nil) {
        colorBackground = self.colorBackground;
    }
    
    vHole = [[UIViewWithHole alloc] initWithFrame:self.view.frame backgroundColor:colorBackground andTransparentRect:frameFaceCenter cornerRadius:0];
    
    [self.view addSubview:vHole];
    [self addButtonTakePicture:vHole];
        
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
            [self.view bringSubviewToFront:self.btTakePic];
            
            self->isProccessIA = NO;
            
        });
        
    });
    
}

- (void)setParamsRectFaces {
    
    if([DeviceUtils hasSmallScreen]) {
        frameFaceCenter = CGRectMake((SCREEN_WIDTH/2) - 100 ,(SCREEN_HEIGHT/2) - 170, 200, 340);
    }else{
        frameFaceCenter = CGRectMake((SCREEN_WIDTH/2) - 125 ,(SCREEN_HEIGHT/2) - 180, 250, 400);
    }
    
    frameFaceAway = CGRectMake((SCREEN_WIDTH/2) - 90 ,(SCREEN_HEIGHT/2) - 140, 180, 280);
    frameFaceCloser = CGRectMake((SCREEN_WIDTH/2) - 150 ,(SCREEN_HEIGHT/2) - 250, 300, 500);
    
}

#pragma mark - FaceAnalyze
- (void)initFaceAnalyze {
    faceAnalyze = [[FaceAnalyze alloc] initWithFrameSilhuette:frameCurrent
                                                  viewContext:self.view];
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
        
        UIView *v1 = [[UIView alloc]initWithFrame:CGRectMake(0, topOffsetPercent_CameraFace, SCREEN_WIDTH, 2)];
        [v1 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v1];
        
        UIView *v2 = [[UIView alloc]initWithFrame:CGRectMake(0, sizeBetweenTopAndBottomPercent_CameraFace, SCREEN_WIDTH, 2)];
        [v2 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v2];
        
        UIView *v3 = [[UIView alloc]initWithFrame:CGRectMake(marginOfSides_CameraFace, 0, 2, SCREEN_HEIGHT)];
        [v3 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v3];
        
        UIView *v4 = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - marginOfSides_CameraFace, 0, 2, SCREEN_HEIGHT)];
        [v4 setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:v4];
        
    }
    
}

- (void)setOffsetTopPercent : (float)percent {
    topOffsetPercent_CameraFace = percent/100 *  SCREEN_HEIGHT;
}

- (void)setSizePercentBetweenTopAndBottom  : (float)percent {
    float pixels = percent/100 *  SCREEN_HEIGHT;
    sizeBetweenTopAndBottomPercent_CameraFace = topOffsetPercent_CameraFace + pixels;
}

- (void)setMarginOfSides: (float)margin {
    marginOfSides_CameraFace = margin;
}

- (void)clearDots {
    for (UIView *view in [self.view subviews]) {
        if(view.tag == - 1) {
            [view removeFromSuperview];
        }
    }
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
                
                if(self->isPhotoAwayToCapture) {
                    [self take];
                    
                }else{
                    
                    [self fireFlash];
                    
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self take];
                    });
                    
                }
                
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
            
            [self stopCamera];
        
        }
    }];
    
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if ([self.renderLock tryLock]) {
        
        if(!isDoneProcess) {
            
            CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            UIImage* image = [self converCIImageToUIImage:ciImage];
            
            if(_isEnableSmartCapture) {
                
                if (self->isPopUpShow) {
                    return;
                }
                
                CIImage *personciImage = [CIImage imageWithCGImage:image.CGImage];

                [self detectFace:personciImage uiimage:image];
                // [self detectFaceNew:personciImage];
                
            }
            
            [self.renderLock unlock];
            
        }
        
    }
    
}

- (void)detectFace:(CIImage*)image uiimage: (UIImage *)uiimage{
        
    NSDictionary *options = @{
        CIDetectorSmile : [NSNumber numberWithBool:YES],
        CIDetectorEyeBlink: [NSNumber numberWithBool:YES],
        CIDetectorImageOrientation: [NSNumber numberWithInt:4]
    };
    
    NSDictionary *accuracy = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:accuracy];
    NSArray *faceFeatures = [faceDetector featuresInImage:image options:options];
    
    if([faceFeatures count] > 0) {
        
        if([faceFeatures count] == 1) {
            
            if(timerToTimoutFaceInference != nil) {
                [timerToTimoutFaceInference invalidate];
                timerToTimoutFaceInference = nil;
            }
            
            self->countWithNoFaceAtScreen = 0;
            
            faceObj = [faceFeatures firstObject];
            lastImageObj = uiimage;

            if(faceObj.hasMouthPosition) {
                [self verifyFaceCenter:faceObj uiimage:uiimage];
            }else {
                [self showGray];
            }
            
        }
        
    }else{
        
        self->countWithNoFaceAtScreen++;
        int minCountWithNoFaceAtScreen = 10;
        if([DeviceUtils hasFasterModelDevice]) {
            minCountWithNoFaceAtScreen = 20;
        }
        
        if(self->countWithNoFaceAtScreen >= minCountWithNoFaceAtScreen) {
            [self showGray];
        }
        
    }
}

- (void)detectFaceNew:(CIImage*)image{
    //create req
    VNDetectFaceRectanglesRequest *faceDetectionReq = [VNDetectFaceRectanglesRequest new];
    NSDictionary *d = [[NSDictionary alloc] init];
    //req handler
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:image options:d];
    //send req to handler
    [handler performRequests:@[faceDetectionReq] error:nil];
    
    //is there a face?
    for(VNFaceObservation *observation in faceDetectionReq.results){
        if(observation){
            [self drawFaceRect:image];
        }
    }
}

- (void)drawFaceRect:(CIImage*)image{
    
    //face landmark
    VNDetectFaceLandmarksRequest *faceLandmarks = [VNDetectFaceLandmarksRequest new];
    VNSequenceRequestHandler *faceLandmarksDetectionRequest = [VNSequenceRequestHandler new];
    [faceLandmarksDetectionRequest performRequests:@[faceLandmarks] onCIImage:image error:nil];
    
    NSArray *results = faceLandmarks.results;
    
    for(VNFaceObservation *observation in results){
        
        
        if (@available(iOS 13.0, *)) {
            float quality = [observation.faceCaptureQuality floatValue];
            NSLog(@"%f", quality);
        } else {
            // Fallback on earlier versions
        }
        
        if (@available(iOS 12.0, *)) {
            //  NSLog(@"yaw: %@", observation.yaw);
        } else {
            // Fallback on earlier versions
        }
        
        //draw rect on face
        CGRect boundingBox = observation.boundingBox;
        CGSize size = CGSizeMake(boundingBox.size.width * SCREEN_HEIGHT, boundingBox.size.height * SCREEN_HEIGHT);
        CGPoint origin = CGPointMake(boundingBox.origin.x * SCREEN_WIDTH, (1-boundingBox.origin.y)* SCREEN_HEIGHT - size.height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for(UIView *view in [self.view subviews]) {
                if(view.tag == -1) {
                    [view removeFromSuperview];
                }
            }
            
            UIView *layer = [UIView new];
            layer.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
            layer.layer.borderColor = [UIColor redColor].CGColor;
            layer.layer.borderWidth = 2;
            layer.tag = -1;
            [self.view addSubview:layer];
        });
        
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [super captureOutput:captureOutput didOutputMetadataObjects:metadataObjects fromConnection:connection];
    
    for (AVMetadataFaceObject *metadataObject in metadataObjects) {
        if(metadataObject.hasYawAngle) {
            yawFace = metadataObject.yawAngle;
        }
    }
}

- (void)verifyFaceCenter : (CIFaceFeature *)face uiimage: (UIImage *)uiimage{
    if(![faceAnalyze validate:face yawFace:yawFace uiimage:uiimage]) {
        [self faceIsNotOK:[faceAnalyze getErrorType]];
    }else{
        [self faceIsOK];
    }
}

- (void)showError : (ErrorsFaceType)errorFaceType {
    
    float minimumCountError = 5;
    if ([DeviceUtils hasFasterModelDevice]){
        minimumCountError = 20;
    }
    
    if(faceAnalyze.countError >= minimumCountError) {
        
        faceAnalyze.countError = 0;
        isShowAlert = NO;
        
        [self showRed];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.75;
            [self->lbMessage.layer addAnimation:animation forKey:@"kCATransitionFade"];
            
            if(errorFaceType == FACE_AWAY_DISTANCE_ERROR) {
                [self setMessageStatus:@"Aproxime o rosto"];
            }else if (errorFaceType == FACE_CLOSE_DISTANCE_ERROR){
                [self setMessageStatus:@"Afaste o rosto"];
            }else if (errorFaceType == FACE_INCLINED_ERROR){
                [self setMessageStatus:@"Deixe seu rosto reto na tela"];
            }else if(errorFaceType == FACE_ROTATE_ERROR){
                [self setMessageStatus:@"Deixe seu rosto reto na tela"];
            }else{
                [self setMessageStatus:@"Enquadre o seu rosto"];
            }
            
            UIColor *colorLbMessage = [UIColor whiteColor];
            
            if(self.colorTextBoxStatus != nil) {
                colorLbMessage = self.colorTextBoxStatus;
            }
            [self->lbMessage setTextColor:colorLbMessage];
            
        });
        
    }
    
}

- (void)showRed{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self->timerCountDown != nil) {
            [self resetTimer];
        }
        
        [self.btTakePic setAlpha:0.5];
        [self.btTakePic setEnabled:NO];
        
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
        
        [self setMessageStatus:@"Enquadre seu rosto"];
        
        UIColor *colorBorder  = [UIColor whiteColor];
        if(self.colorSilhoutteNeutral != nil) {
            colorBorder = self.colorSilhoutteNeutral;
        }
        
        self->vHole.shapeLayer.strokeColor = [colorBorder CGColor];
        
        [self.btTakePic setAlpha:0.5];
        [self.btTakePic setEnabled:NO];
    });
    
}

- (void)faceIsNotOK: (ErrorsFaceType)errorFaceType {
    [self showError:errorFaceType];
}

- (void)faceIsOK{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.isEnableAutoCapture) {
            if(!self->isCountDown) {
                [self createTimer];
                self->isCountDown = YES;
            }
        }
        
        if(!self->isProccessIA) {
            [self->vAlert setHidden:YES];
            [self setMessageStatus:@"Não se mexa..."];
        }
        
        [self.btTakePic setAlpha:1];
        [self.btTakePic setEnabled:YES];
        
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
    
    self.base64Center = @"";
    
}

- (void)resetBlinking {
    arrLeftEyeOpenProbability = [NSMutableArray new];
}

- (void)resetSession {
    
    if(!isValidating) {
        
        [self initSession];
        [self initialActionOfChangeState:YES];
        
    }
    
}

- (void)resetTimer {
    [self->timerCountDown invalidate];
    self->countDown = 1;
    self->isCountDown = NO;
    self->timerCountDown = nil;
}

- (void)createTimer {
    
    self->timerCountDown = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                            target:self
                                                          selector:@selector(countDown)
                                                          userInfo:nil
                                                           repeats:YES];
    
}

- (void)countDown {
    
    if(!isShowAlertLiveness) {
        
        if(countDown == 0) {
            // The last validation
            if(countWithNoFaceAtScreen > 0 || ![faceAnalyze validate:faceObj yawFace:yawFace uiimage:lastImageObj]) {
                
                [self showRed];
            }else{
                if (leftEyeClosed == NO && rightEyeClosed == NO){
                    if(!self->isSuccessAnimated) {
                        self->isSuccessAnimated = YES;
                        // [self->vHole startAnimationSuccess];
                    }
                    [self resetTimer];
                    [self capture];
                }
            }
        }
        
        countDown --;
        
    }
    
}

- (void)actionAfterTakePicture : (NSString *)base64 image:(UIImage *)image {
    
    isValidating = YES;
    
    _base64Center = base64;
    _imgCenter = image;
    
    SelfieResult *selfieResult = [SelfieResult new];
    [selfieResult setBase64:[Base64Utils base64WithUnicoData:[self getOrigin] version:self.versionRelease base64:_base64Center]];
    [self.delegate onSuccessSelfie:selfieResult];
    [self doneProcess];
    
}

- (void)invalidateAllTimers {
    
    if(timerProcesss != nil) {
        [timerProcesss invalidate];
        timerProcesss = nil;
    }
    
    if(timerToTakeCenterPhoto != nil) {
        [timerToTakeCenterPhoto invalidate];
        timerToTakeCenterPhoto = nil;
    }
    
    if(timerToTakeAwayPhoto != nil) {
        [timerToTakeAwayPhoto invalidate];
        timerToTakeAwayPhoto = nil;
    }
    
    if(timerToTimoutFaceInference != nil) {
        [timerToTimoutFaceInference invalidate];
        timerToTimoutFaceInference = nil;
    }
    
    if(timerToTimoutSession != nil) {
        [timerToTimoutSession invalidate];
        timerToTimoutSession = nil;
    }
    
    [self invalidateTimerToSmiling];
    
}

- (void)invalidateTimerToSmiling {
    if(timerToSmiling != nil) {
        [timerToSmiling invalidate];
        timerToSmiling = nil;
    }
}

- (void)initialActionOfChangeState : (BOOL)fromReset {
    
    if(!isDoneProcess) {
        
        [self initHoleView];
        [self initFaceAnalyze];
        [self createViewAlert];
        [self addCloseButton];
        
        if(fromReset) {
            
        }
        
    }
}

- (void)resetVariableProcessIA {
    if(isProccessIA){
        isProccessIA = NO;
    }
}

- (void)createViewAlert {
    
    
        vAlert = [[UIView alloc]initWithFrame:CGRectMake(20, (frameFaceCenter.origin.y - 25) , SCREEN_WIDTH - 40, 50)];
        [vAlert setBackgroundColor:[UIColor colorWithRed:24.0f/255.0f green:30.0f/255.0f blue:45.0f/255.0f alpha:1.0]];
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
        
        UIColor *colorBackgroundBox = [UIColor colorWithRed:24.0f/255.0f green:30.0f/255.0f blue:45.0f/255.0f alpha:1.0];
        if(self.colorBackgroundBoxStatus != nil) {
            colorBackgroundBox = self.colorBackgroundBoxStatus;
        }
        
        [lbMessage setBackgroundColor:colorBackgroundBox];
        [lbMessage setTextAlignment:NSTextAlignmentCenter];
        [lbMessage setFont:[UIFont boldSystemFontOfSize:17.5]];
        [vAlert addSubview:lbMessage];
        
}

- (void)fireAlert : (NSString *)message {
    
    
}

- (void)setMessageStatus: (NSString *)str {
    
    dispatch_async(dispatch_get_main_queue(), ^{
            [self->vAlert setHidden:NO];
            [self->lbMessage setText:str];
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
    if(!isDoneProcess){
        isDoneProcess = YES;
        [self stopCamera];
        [self invalidateAllTimers];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Create Process v3

- (UIImage *)croppIngimage:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

#pragma mark - Button Take Picture

- (void)addButtonTakePicture : (UIView *)view {
    
    float heightViewBottom = 0;
    float valueLessMask = 0;
    
    if([DeviceUtils hasSmallScreen]) {
        heightViewBottom = 60.0f;
        valueLessMask = 40.0f;
    }else{
        heightViewBottom = 100.0f;
        valueLessMask = 0.0f;
    }
    
    [self.btTakePic setEnabled:YES];
    [self.btTakePic setAlpha:1.0];
    [self.btTakePic setFrame:CGRectMake((SCREEN_WIDTH/2) - 35, SCREEN_HEIGHT - heightViewBottom - 35, 70, 70)];
    [self.btTakePic.layer setMasksToBounds:YES];
    [self.btTakePic.layer setCornerRadius:self.btTakePic.frame.size.height/2];
    [self.btTakePic addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    if(_isEnableSmartCapture) {
        [self.btTakePic setAlpha:0.5];
        [self.btTakePic setEnabled:NO];
    }else{
        [self.btTakePic setAlpha:1.0];
        [self.btTakePic setEnabled:YES];
    }
    [self.view addSubview:self.btTakePic];
}


#pragma mark - General

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

- (void)exit {
    [self invalidateAllTimers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

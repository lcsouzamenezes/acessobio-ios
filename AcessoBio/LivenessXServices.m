//
//  LivenessXServices.m
//  AcessoBio
//
//  Created by  Matheus Domingos on 16/10/20.
//

#import "LivenessXServices.h"
#import "LivenessXView.h"
#import "FaceDetectResult.h"

@implementation LivenessXServices


- (id)initWithAuth:(LivenessXView *)pLView pUrl:(NSString *)pUrl apikey:(NSString *)pApikey token:(NSString *)pToken {

    self = [super init];
    if(self) {
        lView = pLView;
        APIKEY = pApikey;
        TOKEN = pToken;
        URL = pUrl;
        urlPath = @"/services/v3/AcessoService.svc/";
        manager = [AFHTTPSessionManager manager];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        
        manager.requestSerializer = serializer;
        [manager.requestSerializer setValue:APIKEY forHTTPHeaderField:@"APIKEY"];
        [manager.requestSerializer setValue:TOKEN forHTTPHeaderField:@"Authorization"];
    }
    
    return self;
    
}


#pragma mark FaceDetects

- (void)faceDetectInital : (NSString *)_base64Center
               base64Away: (NSString*)_base64AwayWithoutSmilling{
    
    
//    if(self.base64AwayWithoutSmilling.length == 0) {
//        self.base64AwayWithoutSmilling = self.base64Away;
//    }
//
    NSDictionary *dict = @{
        @"imageBase641" : _base64Center,
        @"imageBase642" : _base64AwayWithoutSmilling
    };
    
    
    [manager POST:[NSString stringWithFormat:@"%@%@faces/detect", URL, urlPath] parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            
        FaceDetectResult *result = [FaceDetectResult new];
        result.FaceResult = [[responseObject valueForKey:@"FaceResult"] intValue];
        result.Similars = [[responseObject valueForKey:@"Similars"] boolValue];
        result.SimilarScore = [[responseObject valueForKey:@"SimilarScore"] boolValue];
        
        [self->lView onSuccessFaceDetectInitial:result];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        if(self->lView.debug) {
            NSLog(@"%@",errResponse);
        }
        
        NSData *data = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *strError;
                
        if([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *error = [json valueForKey:@"Error"];
            NSString *description = [error valueForKey:@"Description"];
            strError = [self strErrorFormatted:@"FaceDetect" description:description];
        }else{
            strError = [self strErrorFormatted:@"FaceDetect" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."];
        }
        
        [self->lView onErrorFaceDetectInitial:strError];

    }];
    
}

- (void)faceDetectBehavior : (NSString *)base64AwayWithoutSmilling
                 base64Away: (NSString*)base64Away  {
    
    NSDictionary *dict = @{
        @"imageBase641" : base64AwayWithoutSmilling,
        @"imageBase642" : base64Away
    };
    
    [manager POST:[NSString stringWithFormat:@"%@%@faces/detect", URL, urlPath] parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        FaceDetectResult *result = [FaceDetectResult new];
        result.FaceResult = [[responseObject valueForKey:@"FaceResult"] intValue];
        result.Similars = [[responseObject valueForKey:@"Similars"] boolValue];
        result.SimilarScore = [[responseObject valueForKey:@"SimilarScore"] boolValue];

        [self->lView onSuccessFaceDetectBehavior:result];

    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        if(self->lView.debug) {
            NSLog(@"%@",errResponse);
        }
        
        NSData *data = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *strError;
                
        if([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *error = [json valueForKey:@"Error"];
            NSString *description = [error valueForKey:@"Description"];
            strError = [self strErrorFormatted:@"faceDetectBehavior" description:description];
        }else{
            strError = [self strErrorFormatted:@"faceDetectBehavior" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."];
        }
        
        [self->lView onErrorFaceDetectBehavior:strError];
        
    }];
    
}

#pragma mark SendBillingV3

- (void)sendBillingV3 : (NSDictionary *)params{
    
    //    Para logar o json
    //     NSString *jsonRequest = [self bv_jsonStringWithPrettyPrint:params];
  
    
    [manager POST:[NSString stringWithFormat:@"%@%@liveness/billing", URL, urlPath] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        [self->lView onSuccessSendBilling];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        if(self->lView.debug) {
            NSLog(@"%@",errResponse);
        }
        
        NSData *data = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *strError;
                
        if([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *error = [json valueForKey:@"Error"];
            NSString *description = [error valueForKey:@"Description"];
            strError = [self strErrorFormatted:@"SendBillingV3" description:description];
        }else{
            strError = [self strErrorFormatted:@"SendBillingV3" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."];
        }
        
        [self->lView onErrorSendBilling:strError];
        
    }];
    
}


#pragma mark CreateProcessV3

- (void)createProcessV3 : (NSDictionary *)params {
    
    [manager POST:[NSString stringWithFormat:@"%@%@processes", URL, urlPath] parameters:params progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        
        NSDictionary *result = responseObject;
        [self->lView onSucessCreateProcessV3:[result valueForKey:@"Id"]];
        
            
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        
        if(self->lView.debug) {
            NSLog(@"%@",errResponse);
        }
        
        NSData *data = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSString *strError;
                
        if([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *error = [json valueForKey:@"Error"];
            NSString *description = [error valueForKey:@"Description"];
            strError = [self strErrorFormatted:@"CreateProcessV3" description:description];
        }else{
            strError = [self strErrorFormatted:@"CreateProcessV3" description:@"Verifique sua url de conexão, apikey e token. Se persistir, entre em contato com a equipe da Acesso."];
        }
        
        [self->lView onErrorCreateProcessV3:strError];
        
        
    }];
    
}




#pragma mark - Commons

- (NSString *)strErrorFormatted: (NSString *)method description: (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", method, description];
}

@end

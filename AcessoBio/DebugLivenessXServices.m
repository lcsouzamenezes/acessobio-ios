//
//  DebugLivenessXServices.m
//  AcessoBio
//
//  Created by  Matheus Domingos on 19/10/20.
//

#import "DebugLivenessXServices.h"

@implementation DebugLivenessXServices


- (id)initWithAuth:(LivenessXView *)pLView pUrl:(NSString *)pUrl apikey:(NSString *)pApikey token:(NSString *)pToken {

    self = [super init];
    if(self) {
        lView = pLView;
        APIKEY = pApikey;
        TOKEN = pToken;
        URL = pUrl;
        urlPath = @"/services/v2/credService.svc/";
        
        manager = [AFHTTPSessionManager manager];
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        manager.requestSerializer = serializer;
        [manager.requestSerializer setValue:APIKEY forHTTPHeaderField:@"X-AcessoBio-APIKEY"];
        [manager.requestSerializer setValue:TOKEN forHTTPHeaderField:@"Authentication"];
    }
    
    return self;
    
}

#pragma mark Send Liveness
-(void) sendLiveness : (NSDictionary *)paramsLiveness processId: (NSString *)processId  {
    
    NSDictionary *dict = @{@"liveness" : paramsLiveness};
    
    NSString *strURL = [NSString stringWithFormat:@"%@%@", URL, urlPath];
    
    [manager POST:[NSString stringWithFormat:@"%@app/liveness/%@", strURL, processId] parameters:dict progress:nil success:^(NSURLSessionTask *task, id responseObject) {

        NSLog(@"enviado para instância de debug");
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {

        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];

        NSData *data = [errResponse dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if([json isKindOfClass:[NSDictionary class]]) {
          
            NSDictionary *error = [json valueForKey:@"Error"];
            NSString *description = [error valueForKey:@"Description"];
            NSLog(@"%@ - %@", error, description);
            
        }
        
    }];
    
}


@end

//
//  ErrorBio.m
//  AcessoBio
//
//  Created by Matheus Domingos on 14/05/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "ErrorBio.h"

@implementation ErrorBio


- (id)initCode:(NSInteger)code method:(NSString *)method desc:(NSString *)desc
{
    
    self = [super init];
    if(self) {
        self.code = code;
        self.method = method;
        self.desc = desc;
    }
    
    return self;
    
}

@end

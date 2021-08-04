//
//  Base64Utils.m
//  AcessoBio
//
//  Created by Matheus Domingos on 04/08/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "Base64Utils.h"

@implementation Base64Utils

+ (NSString *)base64WithUnicoData: (NSString *) origin version : (NSString *)version base64: (NSString *)base64{
    return [NSString stringWithFormat:@"data:%@|%@/image/jpeg;base64,%@", origin, version, base64];
}

@end

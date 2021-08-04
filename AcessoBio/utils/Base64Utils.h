//
//  Base64Utils.h
//  AcessoBio
//
//  Created by Matheus Domingos on 04/08/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Base64Utils : NSObject {
}

+ (NSString *)base64WithUnicoData: (NSString *) origin version : (NSString *)version base64: (NSString *)base64;
@end

NS_ASSUME_NONNULL_END

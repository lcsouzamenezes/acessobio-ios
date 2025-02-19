//
//  ErrorBio.h
//  AcessoBio
//
//  Created by Matheus Domingos on 14/05/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface ErrorBio : NSObject

@property (assign, nonatomic) NSInteger code;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *desc;

- (id)initCode:(NSInteger)code method:(NSString *)method desc:(NSString *)desc;
@end

NS_ASSUME_NONNULL_END

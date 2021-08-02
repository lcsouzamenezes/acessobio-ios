//
//  AcessoBioCameraOpener.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef AcessoBioCameraOpenerDelegate_h
#define AcessoBioCameraOpenerDelegate_h
#import "AcessoBioSelfieDelegate.h"
#import "AcessoBioDocumentDelegate.h"

@protocol AcessoBioCameraOpenerDelegate <NSObject>

- (void)open:(id <AcessoBioSelfieDelegate>)delegate;
- (void)openDocument:(id <AcessoBioDocumentDelegate>)delegate;

@end

#endif /* AcessoBioCameraOpener_h */

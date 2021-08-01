//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UnicoCheck.h"
#import "iAcessoBioTheme.h"

@interface AcessoBioManager : NSObject <iAcessoBioBuilder> {
    UnicoCheck *core;
}

- (id)initWithViewController:(id)view;
- (void)initWithViewController :(id)view delegate:(id<AcessoBioDelegate>)delegate;


@end


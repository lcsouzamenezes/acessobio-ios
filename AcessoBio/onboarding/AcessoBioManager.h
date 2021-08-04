//
//  CameraBio.h
//  CaptureAcesso
//
//  Created by Daniel Zanelatto on 13/05/19.
//  Copyright © 2019 Matheus  domingos. All rights reserved.
//
@import Foundation;
@import UIKit;
#import "UnicoCheck.h"
#import "AcessoBioThemeDelegate.h"

@interface AcessoBioManager : NSObject <iAcessoBioBuilder> {
    UnicoCheck *core;
}

- (id)initWithViewController:(id)view;
- (id)initWithViewController :(id)view delegate:(id)delegate ;


@end


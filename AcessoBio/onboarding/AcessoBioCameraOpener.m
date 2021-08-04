//
//  AcessoBioSelfie.m
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#import "AcessoBioCameraOpener.h"
#import "UnicoCheck.h"

@implementation AcessoBioCameraOpener

- (id)initWithUnicoCheck:(UnicoCheck *)unicoCheck {
    self = [super init];
    if(self) {
        core = unicoCheck;
    }
    return self;
}

- (void)open:(id<AcessoBioSelfieDelegate>)delegate {
    [core openCameraSelfie:delegate];
}

- (void)openDocument:(DocumentEnums)documentType delegate:(id <AcessoBioDocumentDelegate>)delegate {
    [core openCameraDocuments:documentType delegate:delegate];
}

@end

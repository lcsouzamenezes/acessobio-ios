//
//  iAcessoBioTheme.h
//  AcessoBio
//
//  Created by Matheus Domingos on 30/07/21.
//  Copyright © 2021 Matheus Domingos Acesso. All rights reserved.
//

#ifndef iAcessoBioTheme_h
#define iAcessoBioTheme_h

@protocol iAcessoBioTheme <NSObject>

- (id) getColorBackground;
- (id) getColorBoxMessage;
- (id) getColorTextMessage;
- (id) getColorBackgroundPopupError;
- (id) getColorTextPopupError;
- (id) getColorBackgroundButtonPopupError;
- (id) getColorTextButtonPopupError;
- (id) getColorBackgroundTakePictureButton;
- (id) getColorIconTakePictureButton;
- (id) getColorBackgroundBottomDocument;
- (id) getColorTextBottomDocument;
- (id) getColorSilhouetteSuccess;
- (id) getColorSilhouetteError;

@end

#endif /* iAcessoBioTheme_h */

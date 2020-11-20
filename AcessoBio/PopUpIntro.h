//
//  PopUpIntro.h
//  AcessoBio
//
//  Created by  Matheus Domingos on 18/10/20.
//

#import <Foundation/Foundation.h>
@class LivenessXView;

NS_ASSUME_NONNULL_BEGIN

@interface PopUpIntro : UIView {
    LivenessXView *lView;
    UIButton *btOK;
    UIColor *colorButtonPopupError;
    UIImageView *iconPopupError;
    UIActivityIndicatorView *spin;
    float baseValue;
}

- (void)initLayout: (LivenessXView *)pLView;

- (void)setBackgroundColorButton : (UIColor *)color;
- (void)setTitleColorButton : (UIColor *)color;
- (void)setImageIconPopupError : (UIImage *)image;

- (void)enableButton;

@end

NS_ASSUME_NONNULL_END

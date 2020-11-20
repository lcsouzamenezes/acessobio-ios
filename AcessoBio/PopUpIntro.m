//
//  PopUpIntro.m
//  AcessoBio
//
//  Created by  Matheus Domingos on 18/10/20.
//

#import "PopUpIntro.h"
#import "LivenessXView.h"

@implementation PopUpIntro


- (void)initLayout: (LivenessXView *)pLView {
    
    lView = pLView;
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:20.0];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    iconPopupError = [[UIImageView alloc]initWithFrame:CGRectMake(((self.frame.size.width / 2) - 50), 30, 100, 120)];
    [iconPopupError setImage:[UIImage imageNamed:@"intro_center_image"]];
    [iconPopupError setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:iconPopupError];
    
    UILabel *lbTitle = [[UILabel alloc]initWithFrame:CGRectMake(40, (iconPopupError.frame.origin.y + iconPopupError.frame.size.height + 20), self.frame.size.width - 80, 20)];
    [lbTitle setText:@"Vamos começar?"];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setTextColor:[UIColor darkGrayColor]];
    [lbTitle setNumberOfLines:0];
    [lbTitle setFont:[UIFont boldSystemFontOfSize:20.0]];
    [self addSubview:lbTitle];
    
    UILabel *lbDescription = [[UILabel alloc]initWithFrame:CGRectMake(30, lbTitle.frame.origin.y + 5, self.frame.size.width - 60, 60)];
    [lbDescription setText:@"Siga as dicas abaixo para facilitar:"];
    
    [lbDescription setTextAlignment:NSTextAlignmentCenter];
    [lbDescription setTextColor:[UIColor darkGrayColor]];
    [lbDescription setNumberOfLines:0];
    [lbDescription setFont:[UIFont systemFontOfSize:14.0]];
    [self addSubview:lbDescription];
    
    if(baseValue == 0) {
        baseValue = (lbDescription.frame.origin.y + lbDescription.frame.size.height - 5);
    }
   
    [self createAttentionItem:baseValue icon:[UIImage imageNamed:@"ic_reset_lamp"] textItem:@"Esteja em um local bem iluminado"];
    [self createAttentionItem:baseValue icon:[UIImage imageNamed:@"ic_reset_phone"] textItem:@"Posicione o celular na altura dos olhos"];
    [self createAttentionItem:baseValue icon:[UIImage imageNamed:@"ic_reset_hat"] textItem:@"Não utilize chapéu ou gorros"];
    [self createAttentionItem:baseValue icon:[UIImage imageNamed:@"ic_reset_glass"] textItem:@"Retire os óculos escuros ou de grau"];

    btOK = [[UIButton alloc]initWithFrame:CGRectMake(40, (baseValue + 20), self.frame.size.width - 80, 45)];
    [btOK addTarget:self action:@selector(removePopup) forControlEvents:UIControlEventTouchUpInside];
    [btOK setTitle:@"" forState:UIControlStateNormal];
    [btOK.layer setMasksToBounds:YES];
    [btOK.layer setCornerRadius:22.75];
    [btOK setEnabled:NO];
    [self addSubview:btOK];
    
    spin = [[UIActivityIndicatorView alloc]initWithFrame:btOK.frame];
    [spin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [spin startAnimating];
    [self addSubview:spin];
    
}



- (void)createAttentionItem :(float)y icon:(UIImage *)icon textItem: (NSString *)textItem{
    
    UIImageView *ivItem  = [[UIImageView alloc]initWithFrame:CGRectMake(37, (y + 10), 30, 30)];
    [ivItem setImage:icon];
    [ivItem setContentMode:UIViewContentModeScaleAspectFit];
    
    UILabel *lbItem = [[UILabel alloc]initWithFrame:CGRectMake(80, y, (self.frame.size.width - 100), 50)];
    [lbItem setText:textItem];
    [lbItem setTextAlignment:NSTextAlignmentLeft];
    [lbItem setFont:[UIFont fontWithName:@"Avenir-Book" size:14.0f]];
    [lbItem setNumberOfLines:0];
    [lbItem setTextColor:[UIColor lightGrayColor]];
    
    baseValue = (lbItem.frame.origin.y + lbItem.frame.size.height);
    
    [self addSubview:ivItem];
    [self addSubview:lbItem];
    
}

- (void) shake {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.layer addAnimation:animation forKey:@"shake"];
}

- (void)enableButton {
    [btOK setTitle:@"Entendi" forState:UIControlStateNormal];
    [btOK setEnabled:YES];
    [spin stopAnimating];
}

- (void)removePopup {
    [lView popupIntroHidden];
}

- (void)setBackgroundColorButton : (UIColor *)color {
   // colorButtonPopupError = color;
    [btOK setBackgroundColor:color];
}

- (void)setTitleColorButton : (UIColor *)color {
    [btOK setTitleColor:color forState:UIControlStateNormal];
}

- (void)setImageIconPopupError : (UIImage *)image {
    [iconPopupError setImage:image];
}


@end

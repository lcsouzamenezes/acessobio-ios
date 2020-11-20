//
//  NSStringExtensions.m
//  AcessoBio
//
//  Created by  Matheus Domingos on 19/10/20.
//

#import "NSStringExtensions.h"

@implementation NSString (NSStringExtensions)


+ (NSString *)checkIfNull : (NSString *)str {
    
    if([str isKindOfClass:[NSNull class]])
        return @"";
    
    if(str == nil)
        return @"";
    
    if([str length] > 0)
        return str;
    else
        return @"";
    
}

@end

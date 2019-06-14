//
//  NSString+MD5.m
//  iMuker
//
//  Created by XJIMI on 2018/6/10.
//  Copyright © 2018年 XJIMI. All rights reserved.
//

#import "NSString+XJExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (XJExtension)

- (CGFloat)xj_height:(UIFont*)font maxWidth:(CGFloat)width
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSDictionary *attributes = (font) ? @{NSFontAttributeName : font} : @{};
    return [self xj_heightForAttribute:attributes option:options maxWidth:width];
}

- (CGFloat)xj_heightForLineSpace:(CGFloat)lSpace characterSpace:(CGFloat)cSpace font:(UIFont*)font maxWidth:(CGFloat)width
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    if (font)
    {
        attributes[NSFontAttributeName] = font;
    }

    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    [style setLineSpacing:lSpace];
    attributes[NSParagraphStyleAttributeName] = style;
    attributes[NSKernAttributeName] = @(cSpace);

    return [self xj_heightForAttribute:attributes option:options maxWidth:width];
}

- (CGFloat)xj_heightForAttribute:(NSDictionary *)attributes maxWidth:(CGFloat)width
{
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    return [self xj_heightForAttribute:attributes option:options maxWidth:width];
}

- (CGFloat)xj_heightForAttribute:(NSDictionary *)attributes option:(NSStringDrawingOptions)options maxWidth:(CGFloat)width
{
    CGFloat height = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:options
                                     attributes:attributes
                                        context:nil].size.height;

    CGFloat strHeight = ceilf(height) + 1; // add 1 point as padding
    return strHeight;
}

- (NSString *)xj_md5
{
    const char *ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }
    return output;
}

@end

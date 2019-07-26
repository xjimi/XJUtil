//
//  XJBundleResource.m
//  Pods-XJUtil_Example
//
//  Created by XJIMI on 2019/7/26.
//

#import "XJBundleResource.h"

static NSString * const kXJBundleType = @"bundle";

@implementation XJBundleResource

+ (UIImage *)imageNamed:(NSString *)name {
    return [XJBundleResource imageNamed:name class:[self class] resource:@""];
}

+ (UIImage *)imageNamed:(NSString *)name class:(Class)class {
    return [XJBundleResource imageNamed:name class:class resource:@""];
}

+ (UIImage *)imageNamed:(NSString *)name class:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [XJBundleResource bundleForClass:class resource:resource];
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key {
    return [XJBundleResource LocalizedStringWithKey:key class:[self class] resource:@""];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key class:(Class)class {
    return [XJBundleResource LocalizedStringWithKey:key class:class resource:@""];
}

+ (NSString *)LocalizedStringWithKey:(NSString *)key class:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [XJBundleResource bundleForClass:class resource:resource];
    return NSLocalizedStringFromTableInBundle(key, nil, bundle, nil);
}

+ (NSBundle *)bundleForClass:(Class)class resource:(NSString *)resource
{
    NSBundle *bundle = [NSBundle bundleForClass:class];
    NSString *resourcePath = [bundle pathForResource:resource ofType:kXJBundleType];
    return [NSBundle bundleWithPath:resourcePath];
}

@end

//
//  XJBundleResource.h
//  Pods-XJUtil_Example
//
//  Created by XJIMI on 2019/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XJBundleResource : NSObject

+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageNamed:(NSString *)name class:(Class)class;
+ (UIImage *)imageNamed:(NSString *)name class:(Class)class resource:(NSString *)resource;

+ (NSString *)LocalizedStringWithKey:(NSString *)key;
+ (NSString *)LocalizedStringWithKey:(NSString *)key class:(Class)class;
+ (NSString *)LocalizedStringWithKey:(NSString *)key class:(Class)class resource:(NSString *)resource;

+ (NSBundle *)bundleForClass:(Class)class resource:(NSString *)resource;

@end

NS_ASSUME_NONNULL_END

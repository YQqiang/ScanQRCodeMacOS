//
//  Utils.h
//  ScanQRCode_Mac
//
//  Created by yuqiang on 2021/5/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (void)scanQRCodeOnScreen;

+ (NSImage *)createQRImageWithString:(NSString *)string size:(NSSize)size;

@end

NS_ASSUME_NONNULL_END

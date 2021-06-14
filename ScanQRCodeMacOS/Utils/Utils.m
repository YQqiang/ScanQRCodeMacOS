//
//  Utils.m
//  ScanQRCode_Mac
//
//  Created by yuqiang on 2021/5/10.
//

#import "Utils.h"
#import <CoreImage/CoreImage.h>
#import <AppKit/AppKit.h>

@implementation Utils

+ (void)scanQRCodeOnScreen {
    /* displays[] Quartz display ID's */
    CGDirectDisplayID   *displays = nil;

    CGError             err = CGDisplayNoErr;
    CGDisplayCount      dspCount = 0;

    /* How many active displays do we have? */
    err = CGGetActiveDisplayList(0, NULL, &dspCount);

    /* If we are getting an error here then their won't be much to display. */
    if(err != CGDisplayNoErr)
    {
        NSLog(@"Could not get active display count (%d)\n", err);
        return;
    }

    /* Allocate enough memory to hold all the display IDs we have. */
    displays = calloc((size_t)dspCount, sizeof(CGDirectDisplayID));

    // Get the list of active displays
    err = CGGetActiveDisplayList(dspCount,
                                 displays,
                                 &dspCount);

    /* More error-checking here. */
    if(err != CGDisplayNoErr)
    {
        NSLog(@"Could not get active display list (%d)\n", err);
        return;
    }

    NSMutableArray *foundQRCode = [NSMutableArray array];

    CIDetector *detector = [CIDetector detectorOfType:@"CIDetectorTypeQRCode"
                                              context:nil
                                              options:@{ CIDetectorAccuracy:CIDetectorAccuracyHigh }];

    for (unsigned int displaysIndex = 0; displaysIndex < dspCount; displaysIndex++)
    {
        /* Make a snapshot image of the current display. */
        CGImageRef image = CGDisplayCreateImage(displays[displaysIndex]);
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image]];
        for (CIQRCodeFeature *feature in features) {
            NSLog(@"%@", feature.messageString);
            [foundQRCode addObject:feature.messageString];
        }
         CGImageRelease(image);
    }

    free(displays);

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"NOTIFY_FOUND_QR_CODE"
     object:nil
     userInfo: @{ @"message": foundQRCode,
                  @"source": @"qrcode"
                 }
     ];
}

+ (NSImage *)createQRImageWithString:(NSString *)string size:(NSSize)size {
    NSImage *outputImage = [[NSImage alloc]initWithSize:size];
    [outputImage lockFocus];

    // Setup the QR filter with our string
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];

    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    /*
     L: 7%
     M: 15%
     Q: 25%
     H: 30%
     */
    [filter setValue:@"Q" forKey:@"inputCorrectionLevel"];

    CIImage *image = [filter valueForKey:@"outputImage"];

    // Calculate the size of the generated image and the scale for the desired image size
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width / CGRectGetWidth(extent), size.height / CGRectGetHeight(extent));

    CGImageRef bitmapImage = [NSGraphicsContext.currentContext.CIContext createCGImage:image fromRect:extent];

    CGContextRef graphicsContext = NSGraphicsContext.currentContext.CGContext;

    CGContextSetInterpolationQuality(graphicsContext, kCGInterpolationNone);
    CGContextScaleCTM(graphicsContext, scale, scale);
    CGContextDrawImage(graphicsContext, extent, bitmapImage);

    // Cleanup
    CGImageRelease(bitmapImage);

    [outputImage unlockFocus];
    return outputImage;
}

@end

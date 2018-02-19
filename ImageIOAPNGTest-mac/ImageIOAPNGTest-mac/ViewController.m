//
//  ViewController.m
//  ImageIOAPNGTest-mac
//
//  Created by lizhuoli on 2018/2/19.
//  Copyright © 2018年 lizhuoli. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self testAPNG1];
    [self testAPNG2];
    [self testAPNG3];
    
    NSLog(@"%@", @"All test finished");
}

// image1.apng, original from the Web, works on both iOS and macOS
- (void)testAPNG1 {
    // Load
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSAssert(data, @"data");
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSAssert(source, @"source");
    NSUInteger count = CGImageSourceGetCount(source);
    NSAssert(count > 1, @"animated");
}

// image1.gif, load from file, and encode to apng, then decode again. Works only on iOS but failed on macOS
- (void)testAPNG2 {
    // Load
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSAssert(data, @"data");
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSAssert(source, @"source");
    NSUInteger count = CGImageSourceGetCount(source);
    NSAssert(count > 1, @"animated");
    
    // Encode
    NSMutableData *encodeData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)encodeData, kUTTypePNG, count, NULL);
    NSAssert(destination, @"destination");
    for (size_t i = 0; i < count; i++) {
        CGImageDestinationAddImageFromSource(destination, source, i, NULL);
    }
    BOOL success = CGImageDestinationFinalize(destination);
    NSAssert(success, @"success");
    
    // Decode
    NSData *decodeData = [encodeData copy];
    NSAssert(decodeData, @"decodeData");
    CGImageSourceRef newSource = CGImageSourceCreateWithData((__bridge CFDataRef)decodeData, NULL);
    NSAssert(newSource, @"newSource");
    NSUInteger newCount = CGImageSourceGetCount(newSource);
    NSAssert(newCount == count, @"newCount equal to count"); // <- This fail on macOS, but works on iOS. macOS always be 1, and when set breakpoint on `LogDebug()` it called `CountProc, *** bad fcTL.sequence_number: %d/%d\n`
}

// image2.apng, original from Web, works on iOS but fail on macOS
- (void)testAPNG3 {
    // Load
    NSString *path = [[NSBundle mainBundle] pathForResource:@"image2" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSAssert(data, @"data");
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    NSAssert(source, @"source");
    NSUInteger count = CGImageSourceGetCount(source);
    NSAssert(count > 1, @"animated"); // <- This fail on macOS too. And also trigger the same `LogDebug()` above
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

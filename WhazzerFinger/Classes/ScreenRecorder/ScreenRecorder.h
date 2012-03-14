//
//  ScreenRecorder.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>


@class ScreenRecorder;

@protocol ScreenRecorderDelegate <NSObject>

- (void)encodingDidProgress:(ScreenRecorder *)screenRecorder percentage:(NSNumber *)percentage;
- (void)encodingDidFinish:(ScreenRecorder *)screenRecorder;
- (void)recordingDidStop:(ScreenRecorder *)screenRecorder;
- (void)recordingDidProgress:(ScreenRecorder *)screenRecorder leftDuration:(NSTimeInterval)leftDuration totalDuration:(NSTimeInterval)totalDuration;

@end

@interface ScreenRecorder : NSObject 

@property (readonly) BOOL recording;
@property (readonly) BOOL encoding;
@property NSRect rect;
@property NSInteger fps;
@property (assign, nonatomic) id delegate;

- (NSImage *)takeScreenShot;
- (void)takeScreenShotAndWriteToFile:(NSString *)path;

- (NSTimeInterval)maximumRecordingTime;
- (void)start;
- (void)startWithMaximumDuration:(NSTimeInterval)duration;
- (void)stop;

- (void)encodeAndWriteToFile:(NSString *)path;

@end

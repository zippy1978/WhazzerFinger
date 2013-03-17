//
//  WFIScreenRecorder.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>


@class WFIScreenRecorder;

@protocol WFIScreenRecorderDelegate <NSObject>

- (void)encodingDidProgress:(WFIScreenRecorder *)screenRecorder percentage:(NSNumber *)percentage;
- (void)encodingDidFinish:(WFIScreenRecorder *)screenRecorder;
- (void)recordingDidStop:(WFIScreenRecorder *)screenRecorder;
- (void)recordingDidProgress:(WFIScreenRecorder *)screenRecorder leftDuration:(NSTimeInterval)leftDuration totalDuration:(NSTimeInterval)totalDuration;

@end

@interface WFIScreenRecorder : NSObject 

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

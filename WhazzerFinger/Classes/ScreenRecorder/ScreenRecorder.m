//
//  ScreenRecorder.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScreenRecorder.h"

#import <sys/sysctl.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/task_info.h>
#import <mach/task.h>
#import <malloc/malloc.h>

#import "NSObject+DDExtensions.h"


@interface ScreenRecorder (Private)

- (size_t)systemFreeMemory;

@end
    
@implementation ScreenRecorder (Private)

- (size_t)systemFreeMemory
{
    int mib[6]; 
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    
    int pagesize;
    size_t length;
    length = sizeof (pagesize);
    if (sysctl (mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        fprintf (stderr, "getting page size");
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics (mach_host_self (), HOST_VM_INFO, (host_info_t) &vmstat, &count) != KERN_SUCCESS)
    {
        fprintf (stderr, "Failed to get VM statistics.");
    }
    
    task_basic_info_64_data_t info;
    unsigned size = sizeof (info);
    task_info (mach_task_self (), TASK_BASIC_INFO_64, (task_info_t) &info, &size);
    
    
    return vmstat.free_count * pagesize;
}

@end

@implementation ScreenRecorder {
    
    NSTimer *_captureTimer;
    NSDictionary *_captureAttributes;
    NSUInteger _captureMaxFrames;
    NSInteger _frameCountSinceLastNotification;
    NSDate *_captureStartDate;
    
    NSMutableArray *_frameBuffer;
    
}

@synthesize recording = _recording;
@synthesize encoding = _encoding;
@synthesize rect = _rect;
@synthesize fps = _fps;
@synthesize delegate = _delegate;

- (id)init
{
    if (self = [super init])
    {
        _recording = NO;
        _encoding = NO;
        
        // Default rect is full screen
        _rect = [[NSScreen mainScreen] visibleFrame];
        
        // Default capture attributes
        _captureAttributes = [NSDictionary dictionaryWithObjectsAndKeys: @"avc1", QTAddImageCodecType,
                              [NSNumber numberWithLong: codecHighQuality], QTAddImageCodecQuality
                              , nil];
        
        // Defaut FPS
        _fps = 18;
        
    }
    return self;
}

- (NSImage *)takeScreenShot;
{
   CGImageRef screenShot = CGWindowListCreateImage(_rect, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
   
    // Create a bitmap rep from the image...
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:screenShot];
    // Create an NSImage and add the bitmap rep to it...
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    
    CFRelease(screenShot);
    
    return image;
}

- (void)takeScreenShotAndWriteToFile:(NSString *)path
{
    NSImage *screenShot = [self takeScreenShot];
    
    NSBitmapImageRep *bits = [[screenShot representations] objectAtIndex: 0];
    
    NSData *data;
    data = [bits representationUsingType:NSPNGFileType properties: nil];
    [data writeToFile: path atomically: NO];
}

- (NSTimeInterval)maximumRecordingTime
{
    
    // Take sample image
    NSImage *screenShot = [self takeScreenShot];
    NSUInteger sampleMemorySize = [screenShot TIFFRepresentation].length;
    
    // System free memory
    size_t freeMemorySize = [self systemFreeMemory];
    
    // How much memory for 1 second
    size_t oneSecondMemorysize = sampleMemorySize * _fps;
    
    return freeMemorySize / oneSecondMemorysize;
    
}

- (void)start
{
    [self startWithMaximumDuration:0];

}

- (void)startWithMaximumDuration:(NSTimeInterval)duration
{

    if (_encoding) 
    {
        NSLog(@"Cannot record while encoding");
        return;
    }
    
    _captureStartDate = [NSDate date];
    
    _captureMaxFrames = (NSUInteger)duration * _fps;
    
    _recording = YES;
    
    _frameBuffer = [NSMutableArray array];
    
    _captureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/(NSTimeInterval)_fps
                                                     target:self
                                                   selector:@selector(record:)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)record:(NSTimer*)timer;
{
    
    // Store image to buffer
    NSImage *image = [self takeScreenShot];
    
    NSMutableDictionary *frame = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"date", image, @"image", nil];
    [_frameBuffer addObject:frame];
    _frameCountSinceLastNotification++;
    
    // Notify progress
    if ((_frameCountSinceLastNotification >= _fps) || [_frameBuffer count] == 1) {
        if ([[self delegate] respondsToSelector:@selector(recordingDidProgress:leftDuration:totalDuration:)]) {
            NSTimeInterval totalDuration = [[NSDate date] timeIntervalSinceDate:_captureStartDate];
            NSTimeInterval leftDuration = (_captureMaxFrames / _fps) - totalDuration;
            [[self delegate] recordingDidProgress:self leftDuration:leftDuration totalDuration:totalDuration];
        }
        _frameCountSinceLastNotification = 0;
    }

    // NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];
    
    // If maximum frame is captured: stop recording
    if (_captureMaxFrames > 0 && [_frameBuffer count] > _captureMaxFrames) {
        [self stop];
    }
    
}

- (void)stop
{
    if (_recording) {
    
        // Stop
        [_captureTimer invalidate];
        
            
        _recording = NO;
        
        // Notify stop
        if ([[self delegate] respondsToSelector:@selector(recordingDidStop:)]) {
            [[self delegate] recordingDidStop:self];
        }
        
    }
    
}

- (void)encodeAndWriteToFile:(NSString *)path
{
    if (_recording) {
        NSLog(@"Cannot encode while recording");
        return;
    }

    _encoding = YES;
    
    // Notify progression
    if ([[self delegate] respondsToSelector:@selector(encodingDidProgress:percentage:)]) {
        [[self delegate] encodingDidProgress:self percentage:[NSNumber numberWithFloat:0]];
    }
    
    // Prepare movie
    NSError *error;
    QTMovie *movie = [[QTMovie alloc] initToWritableFile:path error:&error];
    
    if(error) NSLog(@"Error %@", error);
    
    [movie setAttribute:[NSNumber numberWithBool:YES] 
                  forKey:QTMovieEditableAttribute]; 
    
    // Encode movie
    NSInteger i = 0;
    for(NSMutableDictionary *frame in _frameBuffer) {
        // Compute frame duration
        QTTime time = QTMakeTime(1, _fps);
        if ([_frameBuffer count] > (i + 2)) {
            
            NSDictionary *nextFrame = [_frameBuffer objectAtIndex:(i  + 1)];
            
            NSDate *start = [frame objectForKey:@"date"];
            
            NSDate *end = [nextFrame objectForKey:@"date"];
            
            // Duration
            time = QTMakeTimeWithTimeInterval([end timeIntervalSinceDate:start]);
            
        }
        
        [movie addImage:[frame objectForKey:@"image"] forDuration:time withAttributes:_captureAttributes];
        
        // Clear frame (to free up memory)
        [frame removeAllObjects];
        
        i++;
        
        // Notify progression
        if ([[self delegate] respondsToSelector:@selector(encodingDidProgress:percentage:)]) {
            [[[self delegate] dd_invokeOnMainThread] encodingDidProgress:self percentage:[NSNumber numberWithFloat:(float)((float)i / (float)[_frameBuffer count])]];
        }
    }
    
    // Clear buffer
    [_frameBuffer removeAllObjects];
    _frameBuffer = nil;
    
    // Write to movie file
    [movie updateMovieFile];
    movie = nil;
    
    _encoding = NO;
    
    // Notify completion
    if ([[self delegate] respondsToSelector:@selector(encodingDidFinish:)]) {
        [[[self delegate] dd_invokeOnMainThread] encodingDidFinish:self];
    }

}
        
@end


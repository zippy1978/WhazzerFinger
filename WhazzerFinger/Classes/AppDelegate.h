//
//  AppDelegate.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Pointer.h"
#import "ScreenRecorder.h"
#import "EncodeWindowController.h"
#import "AboutWindowController.h"

#define kiPhoneWidth 368
#define kiPhoneHeight 716
#define kiPadWidth 852
#define kiPadHeight 1108
#define kBackgroundBorderWidth 11 // 10px + 1px
#define kWindowShadowWidth 10


#define kHadwareOverlayiPhonePortraitImageDefault @"iPhone4PortraitBlackHardware"
#define kBackgroundiPhonePortraitImageDefault @"iPhonePortraitBackground"
#define kHadwareOverlayiPhoneLandscapeImageDefault @"iPhone4LandscapeBlackHardware"
#define kBackgroundiPhoneLandscapeImageDefault @"iPhoneLandscapeBackground"

CGEventRef tapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *info);
void windowFrameDidChangeCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData);

@interface AppDelegate : NSObject <NSApplicationDelegate, ScreenRecorderDelegate> {
    
    NSStatusItem * _statusItem;
    
    NSRect _screenRect;
	
	NSWindow *_pointerOverlayWindow;
	NSWindow *_hardwareOverlayWindow;
    NSWindow *_backgroundWindow;
	NSWindow *_fadeOverlayWindow;
    
    EncodeWindowController *_encodeWindowController;
    AboutWindowController *_aboutWindowController;
    
    id<Pointer> _pointer;
    
    ScreenRecorder *_screenRecorder;
}

@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) IBOutlet NSMenuItem *screenShotMenuItem;
@property (strong, nonatomic) IBOutlet NSMenuItem *recordMenuItem;
@property (strong, nonatomic) IBOutlet NSMenuItem *aboutMenuItem;
@property (strong, nonatomic) IBOutlet NSMenuItem *quitMenuItem;

- (void)hardwareOverlayImage:(NSImage *)image;
- (void)backgroundImage:(NSImage *)image;

- (void)activateStatusMenu;

- (AXUIElementRef)simulatorApplication;
- (void)positionSimulatorWindow:(id)sender;
- (void)updateWindowPosition;
- (void)registerForSimulatorWindowResizedNotification;
- (void)hideCursor;
- (void)hideScene;
- (void)showScene;

- (IBAction)quit:(id)sender;
- (IBAction)screenShot:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)about:(id)sender;

@end

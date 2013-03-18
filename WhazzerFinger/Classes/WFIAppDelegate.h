//
//  WFIAppDelegate.h
//  WhazzerFinger
//
//  Created by Gilles Grousset on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WFIEncodeWindowController.h"
#import "WFIAboutWindowController.h"
#import "WFIScreenRecorder.h"

#define kBackgroundBorderWidth 11 // 10px + 1px
#define kWindowShadowWidth 10


CGEventRef tapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *info);
void windowFrameDidChangeCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData);

@interface WFIAppDelegate : NSObject <NSApplicationDelegate, WFIScreenRecorderDelegate>

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

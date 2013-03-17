//
//  WFIAppDelegate.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 23/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WFIAppDelegate.h"
#import "WFISimFingerPointer.h"
#import "WFIDefaultPointer.h"

@implementation WFIAppDelegate

@synthesize statusMenu = _statusMenu;
@synthesize screenShotMenuItem = _screenShotMenuItem;
@synthesize recordMenuItem = _recordMenuItem;
@synthesize aboutMenuItem = _aboutMenuItem;
@synthesize quitMenuItem = _quitMenuItem;

#pragma mark - Application delegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // i18n
    [_screenShotMenuItem setTitle:NSLocalizedString(@"Screenshot", @"Screenshot menu item title")];
    [_recordMenuItem setTitle:NSLocalizedString(@"Record", @"Record menu item title")];
    [_aboutMenuItem setTitle:NSLocalizedString(@"About", @"About menu item title")];
    [_quitMenuItem setTitle:NSLocalizedString(@"Quit", @"Quit menu item title")];
    
    // Initialize pointer overlay
    _pointer = [[WFIDefaultPointer alloc] init];
    _pointerOverlayWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, _pointer.size.width, _pointer.size.height) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[_pointerOverlayWindow setAlphaValue:0.8];
	[_pointerOverlayWindow setOpaque:NO];
	[_pointerOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:[_pointer imageForState:kWFIPointerMouseStateMoved]]];
	[_pointerOverlayWindow setLevel:NSFloatingWindowLevel];
	[_pointerOverlayWindow setIgnoresMouseEvents:YES];
    
	[self updateWindowPosition];
    
    // Initialize screen recorder
    _screenRecorder = [[WFIScreenRecorder alloc] init];
    _screenRecorder.delegate = self;
    
    // Initialize encode window
    _encodeWindowController = [[WFIEncodeWindowController alloc] initWithWindowNibName:NSStringFromClass([WFIEncodeWindowController class])];

    // Initialize about window
    _aboutWindowController = [[WFIAboutWindowController alloc] initWithWindowNibName:NSStringFromClass([WFIAboutWindowController class])];
    
    // Event run loop
    CGEventMask mask =	CGEventMaskBit(kCGEventLeftMouseDown) | 
    CGEventMaskBit(kCGEventLeftMouseUp) | 
    CGEventMaskBit(kCGEventLeftMouseDragged) | 
    CGEventMaskBit(kCGEventMouseMoved);
    
	CFMachPortRef tap = CGEventTapCreate(kCGAnnotatedSessionEventTap,
                                         kCGTailAppendEventTap,
                                         kCGEventTapOptionListenOnly,
                                         mask,
                                         tapCallBack,
                                         (__bridge void *)self);
	
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(NULL, tap, 0);
	CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, kCFRunLoopCommonModes);
	
	CFRelease(runLoopSource);
	CFRelease(tap);
    
    [self registerForSimulatorWindowResizedNotification];
    
    // Position simulator
    [self positionSimulatorWindow:nil];
    
    // Show menu
    [self activateStatusMenu];
    
    // Hide cursor
    [self hideCursor];
    
    // Hide scene
    [self hideScene];

}

#pragma mark - Look and Fell control

- (void)backgroundImage:(NSImage *)image
{
    
    _backgroundWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, image.size.width, image.size.height) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
	[_backgroundWindow setAlphaValue:1.0];
	[_backgroundWindow setOpaque:NO];
	[_backgroundWindow setBackgroundColor:[NSColor colorWithPatternImage:image]];
	[_backgroundWindow setIgnoresMouseEvents:YES];
	[_backgroundWindow setLevel:NSFloatingWindowLevel - 1];
    [_backgroundWindow setContentSize:NSMakeSize(image.size.width, image.size.height)];
    
    // Center on screen
    CGFloat screenWidth = [_backgroundWindow screen].frame.size.width;
    CGFloat screenHeight = [_backgroundWindow screen].frame.size.height;
    [_backgroundWindow setFrameOrigin:NSMakePoint((screenWidth / 2) - (image.size.width / 2), (screenHeight / 2) - (image.size.height / 2))];    
    
}


- (void)hardwareOverlayImage:(NSImage *)image
{
    // TODO: detect portrait or landscape mode
    
    _hardwareOverlayWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, -50, image.size.width, image.size.height) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
	[_hardwareOverlayWindow setAlphaValue:1.0];
	[_hardwareOverlayWindow setOpaque:NO];
	[_hardwareOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:image]];
	[_hardwareOverlayWindow setIgnoresMouseEvents:YES];
	[_hardwareOverlayWindow setLevel:NSFloatingWindowLevel - 1];
    [_hardwareOverlayWindow setContentSize:NSMakeSize(image.size.width, image.size.height)];
	
	_screenRect = [[_hardwareOverlayWindow screen] frame];
    
    // Center on screen
    CGFloat screenWidth = [_hardwareOverlayWindow screen].frame.size.width;
    CGFloat screenHeight = [_hardwareOverlayWindow screen].frame.size.height;
    [_hardwareOverlayWindow setFrameOrigin:NSMakePoint((screenWidth / 2) - (image.size.width / 2), (screenHeight / 2) - (image.size.height / 2))];    
    
    

}


#pragma mark - Windows handling

- (AXUIElementRef)simulatorApplication
{
	if(AXAPIEnabled())
	{
		NSArray *applications = [[NSWorkspace sharedWorkspace] runningApplications];
		
		for(NSRunningApplication *application in applications)
		{
            // TODO : internationalize Simulator name here !
			if([application.localizedName isEqualToString:NSLocalizedString(@"iOS Simulator", @"iOS Simulator application name")])
			{
				pid_t pid = application.processIdentifier;
				
				[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:application.bundleIdentifier
                                                                     options:NSWorkspaceLaunchDefault 
                                              additionalEventParamDescriptor:nil 
                                                            launchIdentifier:nil];
				
				AXUIElementRef element = AXUIElementCreateApplication(pid);
				return element;
			}
		}
        
	} else {
        
		NSRunAlertPanel(NSLocalizedString(@"Universal Access Disabled", @"Universal Access alert title"), 
                        NSLocalizedString(@"You must enable access for assistive devices in the System Preferences, under Universal Access.", @"Universal Access disabled message"), @"OK", nil, nil, nil);
        
        exit(0);
        
	}
	
    NSRunAlertPanel(NSLocalizedString(@"Couldn't find Simulator", @"Simulator not found alert title"), NSLocalizedString(@"Couldn't find iOS Simulator.", @"Simulator not found message"), @"OK", nil, nil, nil);
    
    exit(0);
	
    return NULL;
}

- (void)positionSimulatorWindow:(id)sender
{
    
	AXUIElementRef element = [self simulatorApplication];
	
	CFArrayRef attributeNames;
	AXUIElementCopyAttributeNames(element, &attributeNames);
	
	CFArrayRef value;
	AXUIElementCopyAttributeValue(element, CFSTR("AXWindows"), (CFTypeRef *)&value);
	
	for(id object in (__bridge NSArray *)value)
	{
		if(CFGetTypeID((__bridge void *)object) == AXUIElementGetTypeID())
		{
			AXUIElementRef subElement = (__bridge AXUIElementRef)object;
			
			AXUIElementPerformAction(subElement, kAXRaiseAction);
			
			CFArrayRef subAttributeNames;
			AXUIElementCopyAttributeNames(subElement, &subAttributeNames);
			
			CFTypeRef sizeValue;
			AXUIElementCopyAttributeValue(subElement, kAXSizeAttribute, (CFTypeRef *)&sizeValue);
			
			CGSize size;
			AXValueGetValue(sizeValue, kAXValueCGSizeType, (void *)&size);
			
			BOOL supportedSize = NO;
			BOOL iPadMode = NO;
			BOOL landscape = NO;
			
            // iPhone portrait
			if((int)size.width == kiPhoneWidth && (int)size.height == kiPhoneHeight) 
            {
                landscape = NO;
				supportedSize = YES;
                // iPhone landscape
			} else if((int)size.width == kiPhoneHeight && (int)size.height == kiPhoneWidth) 
            {
				supportedSize = YES;
				landscape = YES;
                // iPad portrait
			} else if ((int)size.width == kiPadWidth && (int)size.height == kiPadHeight) 
            {
				supportedSize = YES;
				iPadMode = YES;
                // iPad landscape
			} else if ((int)size.width == kiPadHeight && (int)size.height == kiPadWidth) 
            {
                supportedSize = YES;
				iPadMode = YES;
				landscape = YES;
			}
			
			if(supportedSize) 
            {
                // Initialize background and hardware overlay
                
				Boolean settable;
				AXUIElementIsAttributeSettable(subElement, kAXPositionAttribute, &settable);
				
				CGPoint point;
                
                // iPad
                if(iPadMode) 
                {
                    // Portrait
                    if(!landscape) 
                    {
                        NSLog(@"No yet...");
                    } 
                    
                    // Landscape
                    else 
                    {
                        NSLog(@"No yet...");
                    }
                 
                }
                
                // iPhone
                else 
                {
                    // Portrait
                    if (!landscape) 
                    {
                        
                        [self backgroundImage:[NSImage imageNamed:kBackgroundiPhonePortraitImageDefault]];
                        [self hardwareOverlayImage:[NSImage imageNamed:kHadwareOverlayiPhonePortraitImageDefault]];
                    } 
                    
                    // Landscape
                    else 
                    {
                        [self backgroundImage:[NSImage imageNamed:kBackgroundiPhoneLandscapeImageDefault]];
                        [self hardwareOverlayImage:[NSImage imageNamed:kHadwareOverlayiPhoneLandscapeImageDefault]];
                    }					
                }
                
                
                // Center on screen
                CGFloat screenWidth = [_hardwareOverlayWindow screen].frame.size.width;
                CGFloat screenHeight = [_hardwareOverlayWindow screen].frame.size.height;
                point.x = (screenWidth / 2) - ((int)size.width / 2);
                point.y = (screenHeight / 2) - ((int)size.height / 2);
                
				AXValueRef pointValue = AXValueCreate(kAXValueCGPointType, &point);
				
				AXUIElementSetAttributeValue(subElement, kAXPositionAttribute, (CFTypeRef)pointValue);
                
			}							
			
		}
    }  
}

- (void)registerForSimulatorWindowResizedNotification
{
	// This method is leaking ...
	
	AXUIElementRef simulatorApp = [self simulatorApplication];
	if (!simulatorApp) return;
	
	AXUIElementRef frontWindow = NULL;
	AXError err = AXUIElementCopyAttributeValue( simulatorApp, kAXFocusedWindowAttribute, (CFTypeRef *) &frontWindow );
	if ( err != kAXErrorSuccess ) return;
    
	AXObserverRef observer = NULL;
	pid_t pid;
	AXUIElementGetPid(simulatorApp, &pid);
	err = AXObserverCreate(pid, windowFrameDidChangeCallback, &observer );
	if ( err != kAXErrorSuccess ) return;
	
	AXObserverAddNotification( observer, frontWindow, kAXResizedNotification, (__bridge void *)self );
	AXObserverAddNotification( observer, frontWindow, kAXMovedNotification, (__bridge void *)self );
    
	CFRunLoopAddSource( [[NSRunLoop currentRunLoop] getCFRunLoop],  AXObserverGetRunLoopSource(observer),  kCFRunLoopDefaultMode );
    
}

- (void)updateWindowPosition
{
    NSPoint mousePosition = [NSEvent mouseLocation];
    [_pointerOverlayWindow setFrameOrigin:NSMakePoint(mousePosition.x - (_pointer.size.width  / 2), mousePosition.y - (_pointer.size.height  / 2))];
}

- (void)hideCursor
{
    NSPoint mousePosition = [NSEvent mouseLocation];
    
    void CGSSetConnectionProperty(int, int, CFStringRef, CFBooleanRef);
    int _CGSDefaultConnection();

    CFStringRef propertyString = CFStringCreateWithCString(NULL, "SetsCursorInBackground", kCFStringEncodingUTF8);
    
    // Cursor is never hidden if scene is not visible
    if ([_backgroundWindow isVisible]) {

        if (NSPointInRect (mousePosition, _backgroundWindow.frame)) 
        {
            [_pointerOverlayWindow orderFront:nil];
                
            // Hack to make background cursor setting work
            CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
            // Hide the cursor and wait
            CGDisplayHideCursor(kCGDirectMainDisplay);
            
                
        } else {
            
            // Show cursor
            CGSSetConnectionProperty(_CGSDefaultConnection(), _CGSDefaultConnection(), propertyString, kCFBooleanTrue);
            CGDisplayShowCursor(kCGDirectMainDisplay);
            CGAssociateMouseAndMouseCursorPosition (true);
            CGDisplayShowCursor(kCGNullDirectDisplay);
            
            [_pointerOverlayWindow orderOut:nil];  
            
        }
            
    }
    
    CFRelease(propertyString);
    
}

- (void)hideScene
{
    [_backgroundWindow orderOut:nil];
    [_hardwareOverlayWindow orderOut:nil];
    [_pointerOverlayWindow orderOut:nil];
}

- (void)showScene
{
    [self positionSimulatorWindow:nil];
    
    [_hardwareOverlayWindow orderFront:nil];
    [_backgroundWindow orderBack:_hardwareOverlayWindow];
    [_pointerOverlayWindow orderFront:nil];
    
}


#pragma mark - Status menu

- (void)activateStatusMenu {
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:_statusMenu];
    [_statusItem setImage:[NSImage imageNamed:@"StatusItemIcon"]];
    [_statusItem setAlternateImage:[NSImage imageNamed:@"StatusItemAlternateIcon"]];
}

#pragma mark - Mouse events

- (void)mouseDown
{
	[_pointerOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:[_pointer imageForState:kWFIPointerMouseStateDown]]];
}

- (void)mouseUp
{
	[_pointerOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:[_pointer imageForState:kWFIPointerMouseStateUp]]];
}

- (void)mouseMoved
{
    [self hideCursor];
    [_pointerOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:[_pointer imageForState:kWFIPointerMouseStateMoved]]];
	[self updateWindowPosition];
}

- (void)mouseDragged
{
    [_pointerOverlayWindow setBackgroundColor:[NSColor colorWithPatternImage:[_pointer imageForState:kWFIPointerMouseStateDragged]]];
	[self updateWindowPosition];
}

#pragma mark - ScreenRecorderDelegate methods

- (void)encodingDidProgress:(WFIScreenRecorder *)screenRecorder percentage:(NSNumber *)percentage
{
    // Update progress indicator on encode window
    _encodeWindowController.progessIndicator.doubleValue = [percentage doubleValue] * 100;
}

- (void)encodingDidFinish:(WFIScreenRecorder *)screenRecorder
{
    // Close encode window
    [_encodeWindowController.window close];
    [NSApp stopModal];
}

- (void)recordingDidProgress:(WFIScreenRecorder *)screenRecorder leftDuration:(NSTimeInterval)leftDuration totalDuration:(NSTimeInterval)totalDuration
{
    NSInteger minutes = floor(leftDuration / 60);
    NSInteger seconds = round(leftDuration - minutes * 60);
    
    [_statusItem setTitle:[NSString stringWithFormat:@"%2d:%2d", minutes, seconds]];
}

- (void)recordingDidStop:(WFIScreenRecorder *)screenRecorder
{
    
    [self hideScene];
    
    [_statusItem setTitle:nil];
    
    [_recordMenuItem setTitle:NSLocalizedString(@"Record", @"Record menu item title")];
    
    // Desktop path
    NSString *desktopPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, NO) objectAtIndex:0] stringByExpandingTildeInPath];
    
    // Timestamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; 
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    
    // Encode (in thread)
    [NSThread detachNewThreadSelector:@selector(encodeMovieThreaded:) toTarget:self withObject:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@/movie-%@.mov", desktopPath, timestamp] forKey:@"path"]]; 
    
    // Show encode window
    NSWindow *encodeWindow = _encodeWindowController.window;
    [NSApp runModalForWindow: encodeWindow];
    [NSApp endSheet: encodeWindow];
    [encodeWindow orderOut: self];
}

#pragma mark - Menu actions

- (IBAction)quit:(id)sender
{
    [_screenRecorder stop];
    
    exit(0);
}

- (IBAction)about:(id)sender
{
    
    // Show about window
    NSWindow *aboutWindow = _aboutWindowController.window;
    [NSApp runModalForWindow: aboutWindow];
    [NSApp endSheet: aboutWindow];
    [aboutWindow orderOut: self];
    
}

- (IBAction)screenShot:(id)sender
{
    [self showScene];
    
    // Just to make sure scene is ready
    [NSThread sleepForTimeInterval:1];
    
    // Desktop path
    NSString *desktopPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, NO) objectAtIndex:0] stringByExpandingTildeInPath];
    
    // Timestamp
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH-mm-ss"]; 
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
 
    // Remove shadow border
    _screenRecorder.rect = NSMakeRect(_backgroundWindow.frame.origin.x + kBackgroundBorderWidth, _backgroundWindow.frame.origin.y + kBackgroundBorderWidth, _backgroundWindow.frame.size.width - kBackgroundBorderWidth - kWindowShadowWidth, _backgroundWindow.frame.size.height - kBackgroundBorderWidth - kWindowShadowWidth);
    
    // Shot
    [_screenRecorder takeScreenShotAndWriteToFile:[NSString stringWithFormat:@"%@/screenshot-%@.png", desktopPath, timestamp]];
    
    [self hideScene];
}

- (IBAction)record:(id)sender
{
    [self showScene];
    
    // Start
    if (!_screenRecorder.recording) {
    
        // Remove shadow border
        _screenRecorder.rect = NSMakeRect(_backgroundWindow.frame.origin.x + kBackgroundBorderWidth, _backgroundWindow.frame.origin.y + kBackgroundBorderWidth, _backgroundWindow.frame.size.width - kBackgroundBorderWidth - kWindowShadowWidth, _backgroundWindow.frame.size.height - kBackgroundBorderWidth - kWindowShadowWidth);
        
        [_recordMenuItem setTitle:NSLocalizedString(@"Stop recording", @"Stop recording menu item title")];
        
        [_screenRecorder startWithMaximumDuration:[_screenRecorder maximumRecordingTime]];
            
    // Stop
    } else {
        
        [_screenRecorder stop];
    
    }
}

- (void)encodeMovieThreaded:(NSDictionary *)parameters
{
    NSString *path = [parameters objectForKey:@"path"];
    [_screenRecorder encodeAndWriteToFile:path];
}


@end

#pragma mark - C functions

void windowFrameDidChangeCallback( AXObserverRef observer, AXUIElementRef element, CFStringRef notificationName, void * contextData)
{
    WFIAppDelegate * delegate= (__bridge WFIAppDelegate *) contextData;
	[delegate positionSimulatorWindow:nil];
}

CGEventRef tapCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *info)
{
	WFIAppDelegate *delegate = (__bridge WFIAppDelegate *)info;
	switch(type)
    {
     case kCGEventLeftMouseDown:
     [delegate mouseDown];
     break;
     case kCGEventLeftMouseUp:
     [delegate mouseUp];
     break;
     case kCGEventLeftMouseDragged:
     [delegate mouseDragged];
     break;
     case kCGEventMouseMoved:
     [delegate mouseMoved];
     break;
    }
    
	return event;
}

//
//  WFIAboutWindowController.m
//  WhazzerFinger
//
//  Created by Gilles Grousset on 19/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WFIAboutWindowController.h"

@implementation WFIAboutWindowController

@synthesize versionLabel = _versionLabel;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _versionLabel.stringValue = [NSString stringWithFormat:@"Version %@ by Gilles Grousset",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [NSApp stopModal];
}

- (void)keyDown:(NSEvent *)theEvent
{
    // Close window on space bar
    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@" "]) {
        [self.window close];
    }
    
}

@end

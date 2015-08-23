//
//  MusicKeysAppDelegate.m
//  MusicKeys
//
//  Created by Joshua Halickman on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MusicKeysAppDelegate.h"
#import <Carbon/Carbon.h>
#import "PTHotKey.h"
#import "PTHotKeyCenter.h"
#import "ExFmController.h"

#define ServiceGoogleMusic @"ServiceGoogleMusic"
#define ServiceAmazon @"ServiceAmazon"
#define ServiceExFM @"ServiceExFM"

@interface MusicKeysAppDelegate ()
CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon);
@end

@implementation MusicKeysAppDelegate

#pragma mark "Launch at Login"
- (BOOL)isSetForLogin:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	BOOL exists = NO;
	UInt32 seedValue;
	CFURLRef thePath;
	
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				exists = YES;
				break;
			}
		}
	}
    //	CFRelease(thePath);
	CFRelease(loginItemsArray);
	return exists;
}

- (void)enableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	CFURLRef url = (CFURLRef)[NSURL fileURLWithPath:path];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item) {
		CFRelease(item);
	}
}

- (void)disableLoginItem:(LSSharedFileListRef)loginItems ForPath:(NSString *)path {
	UInt32 seedValue;
	CFURLRef thePath;
	CFArrayRef loginItemsArray = LSSharedFileListCopySnapshot(loginItems, &seedValue);
	for (id item in (NSArray *)loginItemsArray) {
		LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)item;
		if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&thePath, NULL) == noErr) {
			if ([[(NSURL *)thePath path] hasPrefix:path]) {
				LSSharedFileListItemRemove(loginItems, itemRef);
			}
			CFRelease(thePath);
		}
	}
	CFRelease(loginItemsArray);
}


#pragma mark Hotkeys
- (void)registerHotKeys:(BOOL)registerKeys {
	if (registerKeys == YES) {
		if (hotKeyRegistered == NO) {
			
			[self registerAction:@selector(previous) forKey:@"PreviousKey"];
			[self registerAction:@selector(next) forKey:@"NextKey"];
			[self registerAction:@selector(playPause) forKey:@"PlayPauseKey"];
			[self registerAction:@selector(shuffle) forKey:@"ShuffleKey"];
            [self registerAction:@selector(toggleThumbsUp) forKey:@"ThumbsUpKey"];
            [self registerAction:@selector(toggleThumbsDown) forKey:@"ThumbsDownKey"];
			
			hotKeyRegistered = YES;
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableGlobalKeys"];
			[mi_globalKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (hotKeyRegistered == YES) {
			[[PTHotKeyCenter sharedCenter] unregisterAllKeys];
			[mi_globalKeys setState:NSOffState];
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableGlobalKeys"];
			hotKeyRegistered = NO;
		}
	}
}

- (void)registerAction:(SEL)method forKey:(NSString *)key {
	
	NSDictionary *keyDefinition = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];	
	
	PTHotKey *globalHotKey = [[PTHotKey alloc] initWithIdentifier:key
											 keyCombo:[PTKeyCombo keyComboWithKeyCode:[[keyDefinition objectForKey:@"keyCode"] intValue]
																			modifiers:SRCocoaToCarbonFlags([[keyDefinition objectForKey:@"modifierFlags"] intValue])]];
	[globalHotKey setTarget: controller];
	[globalHotKey setAction:method];
	[[PTHotKeyCenter sharedCenter] registerHotKey: globalHotKey];
	[globalHotKey release];
}

- (void) callControllerMethod: (id)sender {
	
	NSLog(@"%@",sender);
}

#pragma mark MediaKeys
CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	MusicKeysAppDelegate *appDelegate = (MusicKeysAppDelegate *)refcon;
	return [appDelegate processEvent:event withType:type];
}

- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type {
	//Paranoid sanity check.
	if (type == kCGEventTapDisabledByTimeout) {
		CGEventTapEnable(eventTap, YES);
		return event;
	} else if (type != NX_SYSDEFINED) {
		return event;
	}
	
	NSEvent *e = [NSEvent eventWithCGEvent:event];
	//We're getting a special event
	if ([e type] == NSSystemDefined && [e subtype] == 8) {
		if ([e data1] == 1051136) {
			[controller playPause];
			return NULL;
		} else if ([e data1] == 1313280) {
			[controller previous];
			return NULL;
		} else if ([e data1] == 1247744) {
			[controller next];
			return NULL;
		}
	}
	
	return event;
}

- (void) setupEvents {
	// Create an event tap. We are interested in system defined keys.
	eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(NX_SYSDEFINED), myCGEventCallback, self);
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	//Add to the current run loop.
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
}

- (void)registerMediaKeys:(BOOL)registerKeys {
	if (registerKeys == YES) {
		if (mediaKeyRegistered == NO) {
			mediaKeyRegistered = YES;
			CGEventTapEnable(eventTap, true);
			[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOnState];
		}
	} else if (registerKeys == NO) {
		if (mediaKeyRegistered == YES) {
			mediaKeyRegistered = NO;
			CGEventTapEnable(eventTap, false);
			[[NSUserDefaults standardUserDefaults] setBool:0 forKey:@"EnableMediaKeys"];
			[mi_mediaKeys setState:NSOffState];
		}
	}
}

#pragma mark Status Menu Actions
- (IBAction)showGoogleMusic:(id)sender {
	[controller show];
}

- (IBAction)startAtLogin:(id)sender {
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		if ([sender state] == NSOnState) {
			[self disableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOffState];
		} else {
			[self enableLoginItem:loginItems ForPath:bundlePath];
			[sender setState:NSOnState];
		}
	}
	CFRelease(loginItems);
}

- (IBAction)mediaKeys:(id)sender {
	if ([mi_mediaKeys state] == NSOffState) {
		[self registerMediaKeys:YES];
	} else {
		[self registerMediaKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)globalKeys:(id)sender {
	if ([mi_globalKeys state] == NSOffState) {
		[self registerHotKeys:YES];
	} else {
		[self registerHotKeys:NO];
	}
	if ([[NSUserDefaults standardUserDefaults] synchronize]) {
	}
}

- (IBAction)openPreferencesWindow:(id)sender {
	[NSBundle loadNibNamed:@"PreferencePane" owner:self];
}


- (IBAction)showAbout:(id)sender {
	[mi_firstLaunch makeKeyAndOrderFront:self];
}

- (IBAction)openLink:(id)sender {
	[mi_firstLaunch close];
	NSURL *moreInfoURL = [[NSURL alloc] initWithString:@"http://halickman.com/music-keys"];
	[[NSWorkspace sharedWorkspace] openURL:[moreInfoURL absoluteURL]];
	[moreInfoURL release];
}

-(void) showMesage:(NSString *) message {
    NSRect frame = [[statusItem view] frame];
    NSPoint pt = NSMakePoint(NSMidX(frame), NSMinY(frame));
    attachedWindow = [[MAAttachedWindow alloc] initWithView:view 
                                            attachedToPoint:pt 
                                                   inWindow:nil 
                                                     onSide:MAPositionBottom 
                                                 atDistance:5.0];
    [textField setTextColor:[attachedWindow borderColor]];
    [textField setStringValue:message];
    [attachedWindow makeKeyAndOrderFront:self];
    //[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideMessage) userInfo:nil repeats:NO];
    
}

-(void) hideMessage {
    [attachedWindow orderOut:self];
    [attachedWindow release];
    attachedWindow = nil;
}

- (IBAction)serviceSelected:(id)sender {
	NSMenuItem *mi = (NSMenuItem *)sender;
	switch ([mi tag]) {
		case 0:
			[[NSUserDefaults standardUserDefaults] setObject:ServiceGoogleMusic forKey:@"ServiceName"];
			break;
		case 1:
			[[NSUserDefaults standardUserDefaults] setObject:ServiceAmazon forKey:@"ServiceName"];
			break;
		case 2:
			[[NSUserDefaults standardUserDefaults] setObject:ServiceExFM forKey:@"ServiceName"];
			break;
		default:
			break;
	}
	
	[self setService:[[NSUserDefaults standardUserDefaults]  objectForKey:@"ServiceName"]];
}

- (void)setService:(NSString *)serviceName {
	
	[mi_serviceExFm setState:NSOffState];
	[mi_serviceAmazon setState:NSOffState];
	[mi_serviceGoogleMusic setState:NSOffState];
	[controller release];
	controller = nil;
	
	if ([serviceName isEqualToString:ServiceGoogleMusic]) {
		controller = [[GoogleMusicController alloc] init];
		[mi_serviceGoogleMusic setState:NSOnState];
	} else if ([serviceName isEqualToString:ServiceAmazon]) {
		controller = [[AmazonCloudPlayerController alloc] init];
		[mi_serviceAmazon setState:NSOnState];
	} else if ([serviceName isEqualToString:ServiceExFM]) {
		controller = [[ExFmController alloc] init];
		[mi_serviceExFm setState:NSOnState];
	}
	
	controller.error = ^(NSString *message) {
		NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
		[alert runModal];
		//[self showMesage:message];
		//[self performSelectorOnMainThread:@selector(showMesage:) withObject:message waitUntilDone:YES];
    };
}

#pragma mark Initalization
+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:file];
	[defaults registerDefaults:appDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
	bundlePath = [[NSBundle mainBundle] bundlePath];
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	if ([self isSetForLogin:loginItems ForPath:bundlePath]) {
		loadAtLogin = YES;
		[mi_startAtLogin setState:NSOnState];
	}
	
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	NSImage *statusImage = [NSImage imageNamed:@"MenuIcon.png"];
	[statusItem setImage:statusImage];
	[statusItem setHighlightMode:YES];
	
	[statusItem setMenu:statusMenu];
	
	[self setService:[[NSUserDefaults standardUserDefaults]  objectForKey:@"ServiceName"]];

	
	hotKeyRegistered = NO;
	mediaKeyRegistered = YES;
	[mi_mediaKeys setState:NSOnState];
	[self setupEvents];
	[self registerHotKeys:[[NSUserDefaults standardUserDefaults] boolForKey:@"EnableGlobalKeys"]];
	[self registerMediaKeys:[[NSUserDefaults standardUserDefaults]boolForKey:@"EnableMediaKeys"]];
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
		[mi_firstLaunch makeKeyAndOrderFront:self];
		[[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"HasLaunchedOnce"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}
@end

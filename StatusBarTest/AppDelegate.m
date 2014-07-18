//
//  AppDelegate.m
//  StatusBarTest
//
//  Created by Asger Pedersen on 26/06/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "MASShortcutView.h"
#import "MASShortcutView+UserDefaults.h"
#import "MASShortcut+UserDefaults.h"
#import "MASShortcut+Monitoring.h"

NSString *const CopyPasteShortCut = @"CopyPasteShortCut";

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    const int MAX_NUMBER_OF_ITEMS = 5;
    self.shortcutView.associatedUserDefaultsKey = CopyPasteShortCut;
    // Execute your block of code automatically when user triggers a shortcut from preferences
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:CopyPasteShortCut handler:^{
        
        // Let me know if you find a better or more convenient API.
    }];
    self.pBoard = [NSPasteboard generalPasteboard];
    self.count = [self.pBoard changeCount];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage:[NSImage imageNamed:@"Status"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"StatusHighlighted"]];
    [self.statusItem setHighlightMode:YES];
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:CopyPasteShortCut handler:^{

        // Let me know if you find a better or more convenient API.
    }];
    [self addMenuItem];
    NSLog(@"updatemenuitem");
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(updateMenuItem)
                                   userInfo:nil
                                    repeats:YES];
    NSLog(@"updatemenuitem done");

    
}

- (BOOL)changeCountChange
{
    if (self.count != [self.pBoard changeCount]) {
        self.count = [self.pBoard changeCount];
        return false;
    }
    return true;
}

- (void)updateMenuItem
{
    NSLog(@"updating");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);

        dispatch_async(queue, ^{

            BOOL change = [self changeCountChange];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!change) {
                    [self addMenuItem];
                }
            });
        });
    
    
}
/*-(IBAction)openNewWindow:(id)sender {
    controllerWindow = [[NSWindowController alloc] initWithWindowNibName:@"You Window XIB Name"];
    [controllerWindow showWindow:self];
}*/

-(void)setPasteBoardString:(id)sender
{
    NSLog(@"%@",[sender representedObject]);
   /* NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:[sender representedObject] forType:NSPasteboardTypeString];*/
    [self addMenuItem];
}

-(void)addMenuItem
{
    NSString* myString = [self.pBoard  stringForType:NSPasteboardTypeString];
    NSInteger changecount = [self.pBoard changeCount];
    NSLog(@"%ld",(long)changecount);
    NSLog(@"%@",myString);
    NSMenu* menu = [self.statusItem menu];
    NSMenuItem* menuItem = [[NSMenuItem alloc] init];
    [menuItem setTitle:myString];

    [menuItem setRepresentedObject:menuItem.title];
    [menuItem setTarget:self];
    [menuItem setEnabled:TRUE];
    [menuItem setAction:@selector(setPasteBoardString:)];
    NSInteger numberOfItems = [menu numberOfItems] + 1;
    NSString *keyString = [@(numberOfItems) stringValue];
    [menuItem setKeyEquivalent:keyString];
    [menu addItem: menuItem];
}

@end

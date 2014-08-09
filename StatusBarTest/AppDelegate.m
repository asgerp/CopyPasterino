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

#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    const int MAX_NUMBER_OF_ITEMS = 5;
    self.shortcutView.associatedUserDefaultsKey = CopyPasteShortCut;
    _tableContents = [NSMutableArray new];
    self.tableView.dataSource = self;
    
    self.isOpen = FALSE;
    self.pBoard = [NSPasteboard generalPasteboard];
    self.count = [self.pBoard changeCount];
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [[self.statusItem menu] setDelegate:self];
    [self.statusItem setImage:[NSImage imageNamed:@"Status"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"StatusHighlighted"]];
    [self.statusItem setHighlightMode:YES];
    [self addMenuItem];
    // Execute your block of code automatically when user triggers a shortcut from preferences
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:CopyPasteShortCut handler:^{
        NSLog([self isOpen] ? @"Yes" : @"No");
        if ([[self window] isVisible]) {
            [[self window ] close];
            self.isOpen = NO;
        }
        else {
            NSApplication *myApp = [NSApplication sharedApplication];
            [myApp activateIgnoringOtherApps:YES];
            [self.window orderFrontRegardless];
        }

    }];
    NSLog(@"updatemenuitem");
    [NSTimer scheduledTimerWithTimeInterval:0.9
                                     target:self
                                   selector:@selector(updateMenuItem)
                                   userInfo:nil
                                    repeats:YES];
    NSLog(@"updatemenuitem done");

    
}

#pragma mark -

- (BOOL)changeCountChange
{
    if (self.count != [self.pBoard changeCount]) {
        self.count = [self.pBoard changeCount];
        return false;
    }
    return true;
}

#pragma mark -

- (void)updateMenuItem
{
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

#pragma mark -

/*-(IBAction)openNewWindow:(id)sender {
    controllerWindow = [[NSWindowController alloc] initWithWindowNibName:@"You Window XIB Name"];
    [controllerWindow showWindow:self];
}*/

#pragma mark -

-(void)setPasteBoardString:(id)sender
{
    
    NSMenuItem *currentItem = [sender representedObject];
    NSMenu *menu = [self.statusItem menu ];
    [menu removeItem: currentItem];
    NSLog(@"Removing %@",[currentItem title]);
    [self.pBoard clearContents];
    [self.pBoard setString:[currentItem title] forType:NSPasteboardTypeString];
}

#pragma mark -

-(void)addMenuItem
{
    NSString* myString = [self.pBoard  stringForType:NSPasteboardTypeString];

    if (myString != nil) {
        NSMenu* menu = [self.statusItem menu];
        NSMenuItem* menuItem = [[NSMenuItem alloc] init];
        [menuItem setTitle:myString];

        [menuItem setRepresentedObject:menuItem];
        [menuItem setTarget:self];
        [menuItem setEnabled:TRUE];
        [menuItem setAction:@selector(setPasteBoardString:)];
        NSInteger numberOfItems = [menu numberOfItems] + 1;
        NSString *keyString = [@(numberOfItems) stringValue];
        [menuItem setKeyEquivalent:keyString];
        [menu addItem: menuItem];
        NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        NSString *activeAppName = [activeApp objectForKey:@"NSApplicationName"];
        NSString *activeAppBundleIdentifier = [activeApp objectForKey:@"NSApplicationBundleIdentifier"];
        NSLog(@"Active application is: %@", activeAppName );
        NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:activeAppBundleIdentifier];
        if (runningApps.count > 0) {
            NSRunningApplication *runningApp = runningApps[0];
            NSImage *image = runningApp.icon;

            NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:activeAppName, @"Name", image, @"Image", nil];
            [_tableContents addObject:dictionary];
            NSLog(@"running app is: %@", activeAppName);
        }
        
    
        
        [self.tableView reloadData];
    }
}

#pragma mark -

- (void)menuWillOpen:(NSMenu *)menu
{
    NSLog(@"called menuWillOpen");
    self.isOpen = YES;
}


- (void)menuDidClose:(NSMenu *)menu
{
    NSLog(@"called menuDidClose");
    self.isOpen = NO;
}

#pragma mark -

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView{
    NSLog(@"called numberOfRowsInTableView");
    NSLog(@" has %@", [_tableContents objectAtIndex:_tableContents.count -1]);
    return _tableContents.count;
}

- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"called tableView");

    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSDictionary *dictionary = [_tableContents objectAtIndex:row];
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    NSLog(@"identifier %@",identifier);
    
    NSTableCellView *cellView = [aTableView makeViewWithIdentifier:identifier owner:self];
    cellView.textField.stringValue = [dictionary objectForKey:@"Name"];
    cellView.imageView.objectValue = [dictionary objectForKey:@"Image"];

    
    return cellView;
}

@end

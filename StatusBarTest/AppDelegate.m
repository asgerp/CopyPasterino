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
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#pragma mark -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    const int MAX_NUMBER_OF_ITEMS = 5;
    self.shortcutView.associatedUserDefaultsKey = CopyPasteShortCut;
    _tableContents = [NSMutableArray new];
    self.tableView.dataSource = self;
    [self.tableView setTarget:self];
    [self.tableView setAction:@selector(updateTableAndPaste)];
    
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
    [NSTimer scheduledTimerWithTimeInterval:0.9
                                     target:self
                                   selector:@selector(updateMenuItem)
                                   userInfo:nil
                                    repeats:YES];

    
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


-(void)updateTableAndPaste
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    NSInteger row = [self.tableView clickedRow];
    dispatch_async(queue, ^{
        
        NSDictionary *dict = [_tableContents objectAtIndex:row];
        [_tableContents removeObjectAtIndex:row];
        [_tableContents insertObject:dict atIndex:0];
        self.count += 1;
        [self.pBoard clearContents];
        [self.pBoard setString:[dict objectForKey:@"Name"] forType:NSPasteboardTypeString];

        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView moveRowAtIndex:row toIndex:1];
        });
    });
    
}

#pragma mark -

-(void)setPasteBoardString:(id)sender
{
    
    NSMenuItem *currentItem = [sender representedObject];
    NSMenu *menu = [self.statusItem menu ];
    [menu removeItem: currentItem];
    DLog(@"Removing %@",[currentItem title]);
    [self.pBoard clearContents];
    [self.pBoard setString:[currentItem title] forType:NSPasteboardTypeString];
}

#pragma mark -

-(void)addMenuItem
{
    DLog(@"called menu item");
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
        NSRunningApplication *activeApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        
        NSString *activeAppName = activeApp.localizedName;

        NSImage *image = activeApp.icon.copy;

        NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:myString, @"Name", image, @"Image", nil];
        [_tableContents insertObject:dictionary atIndex:0];

        
        [self.tableView reloadData];
    }
}

#pragma mark -

- (void)menuWillOpen:(NSMenu *)menu
{

    self.isOpen = YES;
}


- (void)menuDidClose:(NSMenu *)menu
{

    self.isOpen = NO;
}

#pragma mark -

- (NSInteger) numberOfRowsInTableView:(NSTableView *)aTableView{
    return _tableContents.count;
}

- (NSView *)tableView:(NSTableView *)aTableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {


    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSDictionary *dictionary = [_tableContents objectAtIndex:row];
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    NSTableCellView *cellView = [aTableView makeViewWithIdentifier:identifier owner:self];
    cellView.textField.stringValue = [dictionary objectForKey:@"Name"];
    cellView.imageView.objectValue = [dictionary objectForKey:@"Image"];

    return cellView;
}

@end

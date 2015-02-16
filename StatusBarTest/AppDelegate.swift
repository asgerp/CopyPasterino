//
//  AppDelegate.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 15/02/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSTableViewDelegate, NSTableViewDataSource {
    let MAX_NUMBER_OF_ITEMS:Int = 5
    var _tableContents: [Paste] = []
    var isOpen:Bool = false
    var pBoard:NSPasteboard = NSPasteboard.generalPasteboard()
    
    var count:Int = 0

    //MARK: outlets
    @IBOutlet var window:NSWindow!
    @IBOutlet var tableView:NSTableView!
    @IBOutlet var scrollView:NSView!
    @IBOutlet var statusItem:NSStatusItem!
    @IBOutlet var statusMenu:NSMenu!
    
    // MARK: did finish launch
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        // Insert code here to initialize your application
        self.tableView.setDataSource(self)
        self.tableView.target = self
        self.tableView.doubleAction = Selector("updateTableAndPaste")
        self.count = pBoard.changeCount
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
        self.statusItem.image = NSImage(named: "Status")
        self.statusItem.alternateImage = NSImage(named: "StatusHighlighted")
        self.statusItem.highlightMode = true
        
        self.addMenuItem()
        
        NSTimer.scheduledTimerWithTimeInterval(0.9, target: self, selector: Selector("updateMenuItem:"), userInfo: nil, repeats: true)
        
    

        
    }
    //MARK:
    
    /*- (void)updateMenuItem
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
    
    
    }*/
    
    func updateMenuItem(){
        var queue:dispatch_queue_attr_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue, {
            () -> Void in
            var change = self.changeCountChange()
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                if(!change){
                    self.addMenuItem()
                }
            })
        })
    }


    //MARK:
    func changeCountChange() -> Bool {
        if (self.count != self.pBoard.changeCount){
            self.count = self.pBoard.changeCount
            return false
        }
        return true
    }
    
    func updateTableAndPaste(){}
    
    
    func setPasteBoardString(sender: NSMenuItem){
        
        var menu:NSMenu = self.statusItem.menu!
        
        menu.removeItem(sender)
        self.pBoard.clearContents()
        self.pBoard.setString(sender.title, forType: NSPasteboardTypeString)
        
    }


    func addMenuItem(){
        var myString:String = self.pBoard.stringForType(NSPasteboardTypeString)!
        
        var menu:NSMenu = self.statusItem.menu!
        var numberOfItems = menu.numberOfItems + 1
        var menuItem:NSMenuItem = NSMenuItem(title: myString, action: Selector("setPasteBoardString:"),
            keyEquivalent: String(numberOfItems))
        menuItem.representedObject = menuItem
        menuItem.target = self
        menuItem.enabled = true
        menu.addItem(menuItem)
        
        var activeApp = NSWorkspace.sharedWorkspace().frontmostApplication
        
        let activeAppName = activeApp?.localizedName
        
        let image = activeApp?.icon?.copy() as NSImage
        
        let paste:Paste = Paste(paste: myString, name: activeAppName!, image: image)
        self._tableContents.insert(paste, atIndex: 0)
        
        self.tableView.reloadData()
    }

    
    //MARK:
    func menuWillOpen(menu: NSMenu) {
        self.isOpen = true
    }
    
    func menuDidClose(menu: NSMenu) {
        self.isOpen = false
    }
    
    // MARK:
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return _tableContents.count
    }
    
    func tableView(aTableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn!, row: Int) -> CopyPasterinoTableCellView? {
        var dictionary:Paste = _tableContents.removeAtIndex(row)
        var identifier:String = tableColumn.identifier
        

        var cellView:CopyPasterinoTableCellView = aTableView.makeViewWithIdentifier(identifier, owner: self) as CopyPasterinoTableCellView
        
        cellView.textField?.stringValue = dictionary.paste
        cellView.appNameTextField.stringValue = dictionary.name
        cellView.imageView?.objectValue = dictionary.image
        
        return cellView
    }
    
}


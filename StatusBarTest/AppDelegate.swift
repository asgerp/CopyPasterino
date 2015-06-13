//
//  AppDelegate.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 15/02/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSTableViewDelegate, NSTableViewDataSource {
    let MAX_NUMBER_OF_ITEMS:Int = 5
    var _tableContents: [Paste] = []
    var isOpen:Bool = false
    var pasteBoardObserver : PasteBoardObserver = PasteBoardObserver()
    
    var pBoard:NSPasteboard = NSPasteboard.generalPasteboard()
    

    //MARK: outlets
    @IBOutlet var window:NSWindow!
    @IBOutlet var tableView:NSTableView!
    @IBOutlet var scrollView:NSView!
    @IBOutlet var statusItem:NSStatusItem!
    @IBOutlet var statusMenu:NSMenu!
    
    // MARK: did finish launch
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        self.tableView.setDataSource(self)
        self.tableView.target = self
        self.tableView.headerView = nil
        self.tableView.doubleAction = Selector("updateTableAndPaste")
        
        self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
        self.statusItem.menu = self.statusMenu
        self.statusItem.menu?.delegate = self
        self.statusItem.title = "CP"
        self.statusItem!.image = NSImage(named: "Status")
        self.statusItem!.alternateImage = NSImage(named: "StatusHighlighted")
        self.statusItem!.highlightMode = true
        
        // init observer and subscribers
        var textSubscriber = PasteBoardTextSubscriber()
        pasteBoardObserver.addSubscriber(textSubscriber)
        pasteBoardObserver.startObserving()
        //  set up keyboard shortcut
        let keyMask: NSEventModifierFlags = .CommandKeyMask | .ControlKeyMask | .AlternateKeyMask
        let keyCode = UInt(kVK_Space)
        let shortcut = MASShortcut(keyCode: keyCode, modifierFlags: keyMask.rawValue)
        
        MASShortcutMonitor.sharedMonitor().registerShortcut(shortcut, withAction: shortCutCallBack)
        
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        MASShortcutMonitor.sharedMonitor().unregisterAllShortcuts()
    }
    
    func shortCutCallBack(){
        if(self.window.visible == true ){
            self.window.orderOut(self)
        } else {
            self.window.makeKeyAndOrderFront(self)
            NSApp.activateIgnoringOtherApps(true)
        }
    }
    
    
    func updateTableAndPaste(){
        println("updateTableAndPaste")
        var queue:dispatch_queue_attr_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        var row:Int = self.tableView.clickedRow
        dispatch_async(queue, {() -> Void in
            var paste = self._tableContents.removeAtIndex(row)
            self._tableContents.insert(paste, atIndex: 0)
            self.pasteBoardObserver.change += 1
            self.pBoard.clearContents()
            self.pBoard.setString(paste.paste, forType: NSPasteboardTypeString)
            dispatch_sync(dispatch_get_main_queue(), {() -> Void in
                self.tableView.moveRowAtIndex(row, toIndex: 0)
            })
        })
    }


    func setPasteBoardString(Sender: NSMenuItem){
        var menu:NSMenu = self.statusItem!.menu!
        
        menu.removeItem(Sender)
        self.pBoard.clearContents()
        self.pBoard.setString(Sender.title, forType: NSPasteboardTypeString)
        
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
    
    func tableView(aTableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let dictionary:Paste = _tableContents[row]
        var identifier:String = tableColumn!.identifier
        

        var cellView:CopyPasterinoTableCellView = aTableView.makeViewWithIdentifier(identifier, owner: self) as! CopyPasterinoTableCellView
        
        cellView.textField?.stringValue = dictionary.paste
        cellView.appNameTextField.stringValue = dictionary.name
        cellView.imageView?.objectValue = dictionary.image
        
        return cellView
    }
    
}


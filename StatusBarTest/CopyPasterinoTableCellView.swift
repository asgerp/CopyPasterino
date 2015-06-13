//
//  CopyPasterinoTableCellView.swift
//  CopyPasterino
//
//  Created by Asger Pedersen on 15/02/15.
//  Copyright (c) 2015 Asger Pedersen. All rights reserved.
//

import Foundation
@IBDesignable
class CopyPasterinoTableCellView: NSTableCellView {
    @IBOutlet var appNameTextField: NSTextField!
    @IBOutlet var dateTextField: NSTextField!
    
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
    }
    
}

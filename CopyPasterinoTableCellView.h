//
//  CopyPasterinoTableCellView.h
//  CopyPasterino
//
//  Created by Asger Pedersen on 11/08/14.
//  Copyright (c) 2014 Asger Pedersen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CopyPasterinoTableCellView : NSTableCellView {
@private
    NSTextField *_appNameTextField;
    
}
@property(retain) IBOutlet NSTextField *appNameTextField;

@end

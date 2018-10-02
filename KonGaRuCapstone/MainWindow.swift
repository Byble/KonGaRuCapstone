//
//  MainWindow.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 25/09/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

class MainWindow: NSWindow, NSWindowDelegate {
    
    override init(contentRect: NSRect,
                  styleMask aStyle: NSWindowStyleMask,
                  backing bufferingType: NSBackingStoreType,
                  defer flag: Bool) {
        
        super.init(contentRect: contentRect,
                   styleMask: aStyle,
                   backing: bufferingType,
                   defer: flag)
            ...
            self.delegate = self
    }
    
    ...
    
    // MARK: - NSWindowDelegate
    
    func window(_ window: NSWindow,
                willUseFullScreenPresentationOptions
        proposedOptions: NSApplicationPresentationOptions = []) ->
        NSApplicationPresentationOptions {
            
            return [.autoHideMenuBar, .autoHideToolbar, .fullScreen]
    }
    
}

//
//  MainView.swift
//  KonGaRuCapstone
//
//  Created by 김민국 on 25/09/2018.
//  Copyright © 2018 MGHouse. All rights reserved.
//

import Cocoa

class MainView: NSWindow {
    class MainWindow: NSWindow, NSWindowDelegate {
        
        override init(contentRect: NSRect,
                      styleMask aStyle: NSWindow.StyleMask,
                      backing bufferingType: NSWindow.BackingStoreType,
                      defer flag: Bool) {
            
            super.init(contentRect: contentRect,
                       styleMask: aStyle,
                       backing: bufferingType,
                       defer: flag)
            
                self.delegate = self
        }
        
        func window(_ window: NSWindow,
                    willUseFullScreenPresentationOptions
            proposedOptions: NSApplication.PresentationOptions = []) ->
            NSApplication.PresentationOptions {
                
                return [.autoHideMenuBar, .autoHideToolbar, .fullScreen]
        }
        
    }
}

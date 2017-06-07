//
//  AppDelegate.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var gameController: GameViewController!
    var optionsWindowController: OptionsWindowController!
    var windowedFrame: NSRect?
    
    @IBAction func showOptionsWindow(_ sender: NSMenuItem) {
        optionsWindowController.showWindow(nil)
    }
    
    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [
            "difficulty":  "Medium",
            "numCols":     30,
            "numRows":     20,
            "numMines":    60,
            "colorScheme": "Sierra"
            ])
        optionsWindowController = OptionsWindowController()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillUseStandardFrame(_ window: NSWindow, defaultFrame newFrame: NSRect) -> NSRect {
        var size = gameController.gameViewSize
        size.height += window.frame.size.height - window.contentView!.frame.size.height
        return NSRect(origin: window.frame.origin, size: size)
    }
    
    func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool {
        return window.frame.size != gameController.gameViewSize
    }
    
    func windowWillEnterFullScreen(_ notification: Notification) {
        windowedFrame = window.frame
    }
    
    func windowWillExitFullScreen(_ notification: Notification) {
        window.setFrame(windowedFrame!, display: false)
    }
    
}

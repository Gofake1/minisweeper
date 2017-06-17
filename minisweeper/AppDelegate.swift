//
//  AppDelegate.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject {

    @IBOutlet weak var gameWindow: NSWindow!
    @IBOutlet weak var gameViewController: GameViewController!
    var optionsWindowController: OptionsWindowController!
    var preferencesWindowController: PreferencesWindowController!
    var windowedFrame: NSRect?
    
    @IBAction func showOptionsWindow(_ sender: NSMenuItem) {
        optionsWindowController.showWindow(nil)
    }

    @IBAction func showPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
}

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        Preferences.registerDefaults()
        optionsWindowController = OptionsWindowController()
        preferencesWindowController = PreferencesWindowController()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillUseStandardFrame(_ window: NSWindow, defaultFrame newFrame: NSRect) -> NSRect {
        var size = gameViewController.gameViewSize
        size.height += window.frame.size.height - window.contentView!.frame.size.height
        return NSRect(origin: window.frame.origin, size: size)
    }

    func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool {
        return window.frame.size != gameViewController.gameViewSize
    }

    func windowWillEnterFullScreen(_ notification: Notification) {
        windowedFrame = gameWindow.frame
    }

    func windowWillExitFullScreen(_ notification: Notification) {
        gameWindow.setFrame(windowedFrame!, display: false)
    }
}

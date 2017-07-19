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
    var highScoresWindowController: HighScoresWindowController!
    var optionsWindowController: OptionsWindowController!
    var preferencesWindowController: PreferencesWindowController!
    var scoresController: ScoresController!
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "minisweeper")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Persistant container: \(storeDescription) failed with error \(error)")
            }
        }
        return container
    }()

    @IBAction func showHighScores(_ sender: NSMenuItem) {
        highScoresWindowController.showWindow(nil)
    }
    
    @IBAction func showOptionsWindow(_ sender: NSMenuItem) {
        optionsWindowController.showWindow(nil)
    }

    @IBAction func showPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
}

extension AppDelegate: NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: ["colorScheme", "Modern"])
        
        highScoresWindowController = HighScoresWindowController()
        optionsWindowController = OptionsWindowController()
        preferencesWindowController = PreferencesWindowController()
        scoresController = ScoresController(persistentContainer)

        highScoresWindowController.managedObjectContext = persistentContainer.viewContext
        gameViewController.scoresController = scoresController
        preferencesWindowController.scoresController = scoresController
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
        return window.contentView?.frame.size != gameViewController.gameViewSize
    }
}

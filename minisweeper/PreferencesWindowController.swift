//
//  PreferencesWindowController.swift
//  minisweeper
//
//  Created by David Wu on 6/16/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    weak var scoresController: ScoresController?

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("PreferencesWindowController")
    }

    @IBAction func resetHighScores(_ sender: NSButton) {
        scoresController?.reset()
    }
}

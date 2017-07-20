//
//  HighScoresWindowController.swift
//  minisweeper
//
//  Created by David Wu on 6/16/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

class HighScoresWindowController: NSWindowController {

    @objc weak var managedObjectContext: NSManagedObjectContext?

    override var windowNibName: String? {
        return "HighScoresWindowController"
    }
}

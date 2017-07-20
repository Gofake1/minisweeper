//
//  OptionsWindowController.swift
//  minisweeper
//
//  Created by David Wu on 11/2/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

class OptionsWindowController: NSWindowController {

    @IBOutlet weak var difficultyControl: NSSegmentedControl!
    @IBOutlet weak var numRowsField: NSTextField!
    @IBOutlet weak var numColsField: NSTextField!
    @IBOutlet weak var numMinesField: NSTextField!
    
    override var windowNibName: String? {
        return "OptionsWindowController"
    }
    
    override func windowDidLoad() {
        let difficulty = Preferences.difficulty
        if difficulty == nil {
            Preferences.setDefaults()
        }
        switch difficulty ?? .medium {
        case .easy:   difficultyControl.selectedSegment = 0
        case .medium: difficultyControl.selectedSegment = 1
        case .hard:   difficultyControl.selectedSegment = 2
        case .custom: difficultyControl.selectedSegment = 3
        }
        updateViews()
    }
    
    func updateViews() {
        if difficultyControl.selectedSegment != 3 {
            numRowsField.isEnabled  = false
            numColsField.isEnabled  = false
            numMinesField.isEnabled = false
        } else {
            numRowsField.isEnabled  = true
            numColsField.isEnabled  = true
            numMinesField.isEnabled = true
        }

        (gridSize: (cols: numRowsField.integerValue,
                    rows: numColsField.integerValue),
         numMines: numMinesField.integerValue) = Preferences.options
    }
    
    @IBAction func changeDifficulty(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:  Preferences.setDifficulty(.easy)
        case 1:  Preferences.setDifficulty(.medium)
        case 2:  Preferences.setDifficulty(.hard)
        case 3:  Preferences.setDifficulty(.custom)
        default: return
        }
        updateViews()
    }
}

extension OptionsWindowController: NSControlTextEditingDelegate {
    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        // TODO: make error alert message more informative
        switch control {
        case numRowsField, numColsField:
            return control.integerValue >= 10 && control.integerValue <= 100
        case numMinesField:
            return control.integerValue < numColsField.integerValue * numRowsField.integerValue
        default:
            return true
        }
    }
}

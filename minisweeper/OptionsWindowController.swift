//
//  OptionsWindowController.swift
//  minisweeper
//
//  Created by David Wu on 11/2/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

enum Preset: String {
    case easy   = "Easy"
    case medium = "Medium"
    case hard   = "Hard"
    case custom = "Custom"
}

typealias Options = (gridSize: (cols: Int, rows: Int), numMines: Int)

class OptionsWindowController: NSWindowController, NSControlTextEditingDelegate {

    @IBOutlet weak var difficultyControl: NSSegmentedControl!
    @IBOutlet weak var numRowsField: NSTextField!
    @IBOutlet weak var numColsField: NSTextField!
    @IBOutlet weak var numMinesField: NSTextField!
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name(rawValue: "OptionsWindowController")
    }
    
    static let presets = [
        Preset.easy:   (gridSize: (cols: 10, rows: 10), numMines: 10),
        Preset.medium: (gridSize: (cols: 30, rows: 20), numMines: 60),
        Preset.hard:   (gridSize: (cols: 30, rows: 30), numMines: 100)
    ]
    
    override func windowDidLoad() {
        guard let difficulty = UserDefaults.standard.string(forKey: "difficulty") else {return}
        switch Preset(rawValue: difficulty)! {
        case .easy:
            difficultyControl.selectedSegment = 0
        case .medium:
            difficultyControl.selectedSegment = 1
        case .hard:
            difficultyControl.selectedSegment = 2
        case .custom:
            difficultyControl.selectedSegment = 3
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
        
        var options: Options
        switch difficultyControl.selectedSegment {
        case 0:
            options = OptionsWindowController.presets[.easy]!
        case 1:
            options = OptionsWindowController.presets[.medium]!
        case 2:
            options = OptionsWindowController.presets[.hard]!
        case 3:
            let numCols  = UserDefaults.standard.integer(forKey: "numCols")
            let numRows  = UserDefaults.standard.integer(forKey: "numRows")
            let numMines = UserDefaults.standard.integer(forKey: "numMines")
            options = (gridSize: (cols: numCols, rows: numRows), numMines: numMines)
        default:
            return
        }
        numRowsField.integerValue  = options.gridSize.rows
        numColsField.integerValue  = options.gridSize.cols
        numMinesField.integerValue = options.numMines
    }
    
    @IBAction func changeDifficulty(_ sender: NSSegmentedControl) {
        updateViews()
    }
    
    // MARK: - NSControlTextEditingDelegate
    
    func control(_ control: NSControl, isValidObject obj: Any?) -> Bool {
        // TODO: make error alert message more informative
        switch control.tag {
        case 0:
            return control.integerValue >= 10 && control.integerValue <= 100
        case 1:
            return control.integerValue < numColsField.integerValue * numRowsField.integerValue
        default:
            return true
        }
    }
    
}

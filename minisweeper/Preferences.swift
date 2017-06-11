//
//  Preferences.swift
//  minisweeper
//
//  Created by David Wu on 6/10/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Foundation

typealias Options = (gridSize: (cols: Int, rows: Int), numMines: Int)

enum Difficulty: String {
    case easy
    case medium
    case hard
    case custom
}

struct Preferences {

    static var difficulty: Difficulty? {
        guard let difficultyRawValue = UserDefaults.standard.string(forKey: "difficulty") else { return nil }
        return Difficulty(rawValue: difficultyRawValue)
    }

    static var options: Options {
        switch difficulty ?? .medium {
        case .easy, .medium, .hard:
            return presets[difficulty ?? .medium]!
        case .custom:
            return ((UserDefaults.standard.integer(forKey: "numCols"),
                     UserDefaults.standard.integer(forKey: "numRows")),
                    UserDefaults.standard.integer(forKey: "numMines"))
        }
    }

    static let presets = [
        Difficulty.easy:   (gridSize: (cols: 10, rows: 10), numMines: 10),
        Difficulty.medium: (gridSize: (cols: 30, rows: 20), numMines: 60),
        Difficulty.hard:   (gridSize: (cols: 30, rows: 30), numMines: 100)
    ]

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            "difficulty":  Difficulty.medium.rawValue,
            "colorScheme": "Sierra"
            ])
    }

    static func setDefaults() {
        UserDefaults.standard.set(Difficulty.medium.rawValue, forKey: "difficulty")
        UserDefaults.standard.set(20, forKey: "numRows")
        UserDefaults.standard.set(30, forKey: "numCols")
        UserDefaults.standard.set(60, forKey: "numMines")
    }

    static func setDifficulty(_ difficulty: Difficulty) {
        UserDefaults.standard.set(difficulty.rawValue, forKey: "difficulty")
    }
}

//
//  Game.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Foundation

class Game {
    
    enum GameState {
        case inProgress
        case won
        case lost
    }
    
    private(set) var grid: [[Tile]] = []
    private(set) var height:   Int
    private(set) var width:    Int
    private(set) var numFlags: Int = 0
    private(set) var numMines: Int
    var numSafeTilesCleared: Int = 0 {
        didSet {
            if numSafeTilesCleared - (height * width - numMines) == 0 {
                state = .won
            }
        }
    }
    var safeStartingTile: (Int, Int) {
        var x, y: Int
        repeat {
            x = Int(arc4random_uniform(UInt32(width)))
            y = Int(arc4random_uniform(UInt32(height)))
        } while (grid[x][y].type != .safe || grid[x][y].numAdjacentMines != 0)
        return (x, y)
    }
    var state: GameState = .inProgress
    
    /// - parameter numMines: must be less than width times height
    init(width: Int, height: Int, numMines: Int) {
        self.width    = width
        self.height   = height
        self.numMines = numMines
        var tileTypes = tileSequence()
        for i in 0..<width {
            var col: [Tile] = []
            for j in 0..<height {
                col.append(Tile(x: i, y: j, type: tileTypes.popLast()!, game: self))
            }
            grid.append(col)
        }
    }
    
    func flag(x: Int, y: Int) {
        guard let col = grid[safe: x], let tile = col[safe: y] else {return}
        switch tile.state {
        case .hidden:
            tile.state = .flagged
            numFlags += 1
        case .flagged:
            tile.state = .hidden
            numFlags -= 1
        case .cleared:  fallthrough
        case .revealed: fallthrough
        case .exploded:
            return
        }
    }
    
    func sweep(x: Int, y: Int) {
        guard let col = grid[safe: x], let tile = col[safe: y] else {return}
        if (tile.state == .flagged) {return}
        switch tile.type {
        case .safe:
            tile.expand()
        case .mined:
            tile.state = .exploded
            state = .lost
        }
    }
    
    func revealMines() {
        for col in grid {
            for tile in col {
                if tile.type == .mined && tile.state == .hidden {
                    tile.state = .revealed
                }
            }
        }
    }
    
    private func tileSequence() -> [Tile.TileType] {
        var sequence = Array(repeating: Tile.TileType.safe, count: width * height)
        if numMines < 1 {
            return sequence
        }
        for _ in 0..<numMines {
            var pos: Int
            repeat {
                pos = Int(arc4random_uniform(UInt32(width * height)))
            } while sequence[pos] == .mined
            sequence[pos] = .mined
        }
        return sequence
    }
    
}

extension Game: CustomStringConvertible {
    var description: String {
        var _description = ""
        for col in grid {
            for tile in col {
                switch tile.state {
                case .hidden:
                    switch tile.type {
                    case .safe:
                        _description += "H"
                    case .mined:
                        _description += "!"
                    }
                case .cleared:
                    _description += "_"
                case .revealed:
                    _description += "*"
                case .flagged:
                    _description += "F"
                case .exploded:
                    _description += "X"
                }
            }
            _description += "\n"
        }
        return _description
    }
}



class Tile {
    
    enum TileType {
        case safe
        case mined
    }
    
    enum TileState {
        case hidden
        case cleared
        case revealed
        case flagged
        case exploded
    }
    
    var game: Game
    private var _neighbors: [Tile?]?
    var neighbors: [Tile?] {
        if let _neighbors = _neighbors {
            return _neighbors
        }
        var a, b, c, d, f, g, h, i: Tile?
        if let col = game.grid[safe: x-1] {
            a = col[safe: y+1]
            d = col[y]
            g = col[safe: y-1]
        }
        b = game.grid[x][safe: y+1]
        h = game.grid[x][safe: y-1]
        if let col = game.grid[safe: x+1] {
            c = col[safe: y+1]
            f = col[y]
            i = col[safe: y-1]
        }
        _neighbors = [a, b, c, d, f, g, h, i]
        return _neighbors!
    }
    private var _numAdjacentMines: Int?
    var numAdjacentMines: Int {
        if let _numAdjacentMines = _numAdjacentMines {
            return _numAdjacentMines
        }
        var count = 0
        for neighbor in neighbors {
            if let neighbor = neighbor {
                if neighbor.type == .mined {
                    count += 1
                }
            }
        }
        _numAdjacentMines = count
        return _numAdjacentMines!
    }
    var state: TileState = .hidden
    var type:  TileType
    private var x: Int
    private var y: Int
    
    init(x: Int, y: Int, type: TileType, game: Game) {
        self.x    = x
        self.y    = y
        self.type = type
        self.game = game
    }
    
    fileprivate func expand() {
        guard state == .hidden, type == .safe else {return}
        state = .cleared
        game.numSafeTilesCleared += 1
        if numAdjacentMines > 0 {
            return
        }
        for neighbor in neighbors {
            if let neighbor = neighbor {
                neighbor.expand()
            }
        }
    }
    
}

extension Collection {
    
    // http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    /// Return nil if out of bounds
    subscript(safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
    
}

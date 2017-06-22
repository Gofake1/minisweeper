//
//  Game.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func gameDidUpdate(_ dirtyTiles: [Tile])
}

class Game {
    
    enum State {
        case notStarted
        case inProgress
        case paused
        case won
        case lost
    }

    var allTiles: [Tile] {
        return grid.flatMap { $0 }
    }
    var numSafeTilesCleared: Int = 0 {
        didSet {
            if numSafeTilesCleared - (height * width - numMines) == 0 {
                state = .won
            }
        }
    }
    // Unused
    var safeStartingTile: (Int, Int) {
        var x, y: Int
        repeat {
            x = Int(arc4random_uniform(UInt32(width)))
            y = Int(arc4random_uniform(UInt32(height)))
        } while (grid[x][y].kind != .safe || grid[x][y].numAdjacentMines != 0)
        return (x, y)
    }

    let height:   Int
    let width:    Int
    let numMines: Int
    private(set) var grid     = [[Tile]]()
    private(set) var numFlags = 0
    private(set) var state    = State.notStarted
    private(set) var elapsedTime: TimeInterval = 0
    private unowned var delegate: GameDelegate
    private var startTime: Date?
    
    /// - parameter numMines: must be less than width times height
    init(width: Int, height: Int, numMines: Int, delegate: GameDelegate) {
        self.width    = width
        self.height   = height
        self.numMines = numMines
        self.delegate = delegate
        var kinds = tileSequence()
        for i in 0..<width {
            var col: [Tile] = []
            for j in 0..<height {
                col.append(Tile(x: i, y: j, kind: kinds.popLast()!, game: self))
            }
            grid.append(col)
        }
    }
    
    func flag(x: Int, y: Int) {
        guard state == .inProgress else { fatalError() }
        guard let col = grid[safe: x], let tile = col[safe: y] else { return }
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
        delegate.gameDidUpdate([tile])
    }

    func sweep(x: Int, y: Int) {
        guard state == .inProgress else { fatalError() }
        guard let col = grid[safe: x],
            let tile = col[safe: y],
            tile.state != .flagged
            else { return }
        switch tile.kind {
        case .safe:
            let revealedTiles = tile.expand()
            if state == .won {
                stopTiming()
                delegate.gameDidUpdate(revealedTiles + revealMines())
            } else {
                delegate.gameDidUpdate(revealedTiles)
            }
        case .mined:
            stopTiming()
            tile.state = .exploded
            state = .lost
            delegate.gameDidUpdate(revealMines())
        }
    }

    /// Start counting elapsed time
    func resume() {
        state = .inProgress
        startTime = Date()
    }

    /// Stop counting elapsed Time
    func pause() {
        state = .paused
        stopTiming()
    }

    /// - postcondition: Mutates `elapsedTime`
    private func stopTiming() {
        defer { startTime = nil }
        guard let startTime = startTime else { fatalError() }
        elapsedTime += Date().timeIntervalSince(startTime)
    }
    
    private func tileSequence() -> [Tile.Kind] {
        var sequence = Array(repeating: Tile.Kind.safe, count: width * height)
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

    private func revealMines() -> [Tile] {
        var tiles = [Tile]()
        for col in grid {
            for tile in col {
                if tile.kind == .mined {
                    if tile.state != .exploded {
                        tile.state = .revealed
                    }
                    tiles.append(tile)
                }
            }
        }
        return tiles
    }
}

extension Game: CustomStringConvertible {
    var description: String {
        var _description = ""
        for col in grid {
            for tile in col {
                switch tile.state {
                case .hidden:
                    switch tile.kind {
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
    
    enum Kind {
        case safe
        case mined
    }
    
    enum State {
        case hidden
        case cleared
        case revealed
        case flagged
        case exploded
    }
    
    unowned var game: Game
    private var _neighbors: [Tile?]?
    var neighbors: [Tile?] {
        if _neighbors != nil {
            return _neighbors!
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
        if _numAdjacentMines == nil {
            var count = 0
            for neighbor in neighbors {
                if let neighbor = neighbor {
                    if neighbor.kind == .mined {
                        count += 1
                    }
                }
            }
            _numAdjacentMines = count
        }
        return _numAdjacentMines!
    }
    var state = State.hidden
    private(set) var kind: Kind
    private(set) var x: Int
    private(set) var y: Int
    
    init(x: Int, y: Int, kind: Kind, game: Game) {
        self.x    = x
        self.y    = y
        self.kind = kind
        self.game = game
    }
    
    func expand() -> [Tile] {
        guard state == .hidden, kind == .safe else { return [] }
        state = .cleared
        game.numSafeTilesCleared += 1
        var dirtyTiles = [self]
        if numAdjacentMines > 0 {
            return dirtyTiles
        }
        for neighbor in neighbors {
            if let neighbor = neighbor {
                dirtyTiles.append(contentsOf: neighbor.expand())
            }
        }
        return dirtyTiles
    }
}

extension Collection {
    // http://stackoverflow.com/questions/25329186/safe-bounds-checked-array-lookup-in-swift-through-optional-bindings
    /// - returns: nil if out of bounds
    subscript(safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

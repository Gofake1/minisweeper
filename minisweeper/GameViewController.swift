//
//  GameViewController.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController {

    var gameViewSize: NSSize {
        return NSSize(width: game.width*20, height: game.height*20)
    }
    private var game: Game!
    private var gameViewLayer = CALayer()
    private var tileShapeLayers: [[CAShapeLayer]]!
    private var tileTextLayers: [[CATextLayer]]!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer?.addSublayer(gameViewLayer)
        newGame()
    }
    
    private func newGame() {
        let gameHeight, gameWidth, gameMineCount: Int
        guard let difficulty = Preset(rawValue: UserDefaults.standard.string(forKey: "difficulty")!) else {return}
        switch difficulty {
        case .easy, .medium, .hard:
            guard let preset = OptionsWindowController.presets[difficulty] else {return}
            gameHeight    = preset.gridSize.rows
            gameWidth     = preset.gridSize.cols
            gameMineCount = preset.numMines
        case .custom:
            gameHeight    = UserDefaults.standard.integer(forKey: "numRows")
            gameWidth     = UserDefaults.standard.integer(forKey: "numCols")
            gameMineCount = UserDefaults.standard.integer(forKey: "numMines")
        guard gameMineCount <= gameWidth * gameHeight else { fatalError() }
        game = Game(width: gameWidth, height: gameHeight, numMines: gameMineCount, delegate: self)

        gameViewLayer.sublayers = nil
        tileShapeLayers = makeLayers(width: game.width, height: game.height) {
            let path = NSBezierPath()
            path.move(to: NSPoint(x: $1.x*20,    y: $1.y*20))
            path.line(to: NSPoint(x: $1.x*20+20, y: $1.y*20))
            path.line(to: NSPoint(x: $1.x*20+20, y: $1.y*20+20))
            path.line(to: NSPoint(x: $1.x*20,    y: $1.y*20+20))
            $0.path = path.cgPath
            $0.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
            $0.lineWidth = 0.5
            gameViewLayer.addSublayer($0)
            return $0
        }
        tileTextLayers = makeLayers(width: game.width, height: game.height) {
            $0.alignmentMode = kCAAlignmentCenter
            $0.fontSize = 13.5
            $0.frame = NSRect(x: $1.x*20, y: $1.y*20, width: 20, height: 20)
            gameViewLayer.addSublayer($0)
            return $0
        }

        view.window?.title = "\(game.numMines) mines"
        view.window?.performZoom(nil)
        drawGame(game.allTiles)
    }

    private func makeLayers<T: CALayer>(width: Int, height: Int, setup: (T, (x: Int, y: Int)) -> T) -> [[T]] {
        var layers = [[T]]()
        for x in 0..<width {
            var col = [T]()
            for y in 0..<height {
                col.append(setup(T.init(), (x, y)))
            }
            layers.append(col)
        }
        return layers
    }

    private func drawGame(_ dirtyTiles: [Tile]) {
        for tile in dirtyTiles {
            let shapeLayer = tileShapeLayers[tile.x][tile.y]
            let textLayer = tileTextLayers[tile.x][tile.y]

            switch tile.state {
            case .cleared:
                shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                if tile.numAdjacentMines != 0 {
                    textLayer.string = "\(tile.numAdjacentMines)"
                }
                if let textColor = textColorForTile(tile) {
                    textLayer.foregroundColor = textColor
                }
            case .exploded:
                shapeLayer.fillColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
                textLayer.string = "💥"
            case .flagged:
                shapeLayer.fillColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor
                textLayer.string = "🚩"
            case .hidden:
                shapeLayer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
            case .revealed:
                textLayer.string = "💣"
            }
        }
    }

    private func textColorForTile(_ tile: Tile) -> CGColor? {
        switch tile.numAdjacentMines {
        case 1:  return #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
        case 2:  return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor
        case 3:  return #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
        case 4:  return #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor
        case 5:  return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
        case 6:  return #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
        case 7:  return #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor
        case 8:  return #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1).cgColor
        default: return nil
        }
    }

    /// - postcondition: Will call `gameDidUpdate`
    private func endGame() {
        switch game.state {
        case .won:
            view.window?.title = "Congratulations"
        case .lost:
            view.window?.title = "Uh-oh"
        default:
            fatalError("Invalid state \(game.state)")
        }
        game.revealMines()
    }

    /// - postcondition: Will call `gameDidUpdate`
    override func mouseDown(with event: NSEvent) {
        guard game.state == .inProgress else {
            newGame()
            return
        }
        game.sweep(x: Int(event.locationInWindow.x/20), y: Int(event.locationInWindow.y/20))
        if game.state != .inProgress {
            endGame()
        }
    }

    /// - postcondition: Will call `gameDidUpdate`
    override func rightMouseDown(with event: NSEvent) {
        guard game.state == .inProgress else {
            newGame()
            return
        }
        game.flag(x: Int(event.locationInWindow.x/20), y: Int(event.locationInWindow.y/20))
    }
    
    @IBAction func startNewGame(_ sender: NSMenuItem) {
        newGame()
    }
}

extension GameViewController: GameDelegate {
    func gameDidUpdate(_ dirtyTiles: [Tile]) {
        drawGame(dirtyTiles)
    }
}

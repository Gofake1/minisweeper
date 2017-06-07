//
//  GameViewController.swift
//  minisweeper
//
//  Created by David Wu on 10/28/16.
//  Copyright © 2016 Gofake1. All rights reserved.
//

import Cocoa

class GameViewController: NSViewController {
    
    private var game: Game?
    private var gameViewLayer = CALayer()
    var gameViewSize: NSSize {
        return NSSize(width: game!.width*20, height: game!.height*20)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newGame()
        view.layer?.addSublayer(gameViewLayer)
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
        }
        if gameMineCount > gameHeight * gameWidth {return}
        game = Game(width: gameWidth, height: gameHeight, numMines: gameMineCount)
        view.window?.title = "\(game!.numMines) mines"
        view.window?.performZoom(nil)
        drawGame()
    }
    
    private func drawGame() {
        guard let game = game else {return}
        gameViewLayer.sublayers = nil
        for (i, col) in game.grid.enumerated() {
            for (j, tile) in col.enumerated() {
                
                let tileLayer = CAShapeLayer()
                tileLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
                tileLayer.lineWidth = 0.5
                
                let textLayer = CATextLayer()
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.fontSize = 12.0
                textLayer.frame = NSRect(x: i*20, y: j*20, width: 20, height: 20)
                
                let tilePath = NSBezierPath()
                
                switch tile.state {
                case .hidden:
                    tileLayer.fillColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor
                case .cleared:
                    tileLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
                    if tile.numAdjacentMines != 0 {
                        textLayer.string = "\(tile.numAdjacentMines)"
                    }
                    switch tile.numAdjacentMines {
                    case 1:
                        textLayer.foregroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
                    case 2:
                        textLayer.foregroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor
                    case 3:
                        textLayer.foregroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor
                    case 4:
                        textLayer.foregroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor
                    case 5:
                        textLayer.foregroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor
                    case 6:
                        textLayer.foregroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor
                    case 7:
                        textLayer.foregroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor
                    case 8:
                        textLayer.foregroundColor = #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1).cgColor
                    default:
                        break
                    }
                case .revealed:
                    textLayer.string = "💣"
                    break
                case .flagged:
                    tileLayer.fillColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor
                    textLayer.string = "🚩"
                case .exploded:
                    tileLayer.fillColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor
                    textLayer.string = "💥"
                }
                tilePath.move(to: NSPoint(x: i*20,    y: j*20))
                tilePath.line(to: NSPoint(x: i*20+20, y: j*20))
                tilePath.line(to: NSPoint(x: i*20+20, y: j*20+20))
                tilePath.line(to: NSPoint(x: i*20,    y: j*20+20))
                tileLayer.path = tilePath.cgPath
                gameViewLayer.addSublayer(tileLayer)
                gameViewLayer.addSublayer(textLayer)
            }
        }
    }
    
    private func endGame() {
        guard let game = game else {return}
        switch game.state {
        case .won:
            view.window?.title = "Congratulations"
        case .lost:
            view.window?.title = "Uh-oh"
        default:
            return
        }
        game.revealMines()
        drawGame()
    }
    
    override func mouseDown(with event: NSEvent) {
        guard let game = game, game.state == .inProgress else {
            newGame()
            return
        }
        game.sweep(x: Int(event.locationInWindow.x/20), y: Int(event.locationInWindow.y/20))
        drawGame()
        if game.state != .inProgress {
            endGame()
        }
    }
    
    override func rightMouseDown(with event: NSEvent) {
        guard let game = game, game.state == .inProgress else {
            newGame()
            return
        }
        game.flag(x: Int(event.locationInWindow.x/20), y: Int(event.locationInWindow.y/20))
        drawGame()
    }
    
    @IBAction func startNewGame(_ sender: NSMenuItem) {
        newGame()
    }
    
}

extension NSBezierPath {
    
    // https://gist.github.com/juliensagot/9749c3a1df28c38fb9f9
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        if elementCount > 0 {
            var didClosePath = true
            for i in 0...elementCount-1 {
                let pathType = element(at: i, associatedPoints: points)
                switch pathType {
                case .moveToBezierPathElement:
                    path.move(to: points[0])
                case .lineToBezierPathElement:
                    path.addLine(to: points[0])
                    didClosePath = false
                case .curveToBezierPathElement:
                    path.addCurve(to: points[0], control1: points[1], control2: points[2])
                    didClosePath = false
                case .closePathBezierPathElement:
                    path.closeSubpath()
                    didClosePath = true
                }
            }
            if !didClosePath {
                path.closeSubpath()
            }
        }
        points.deallocate(capacity: 3)
        return path
    }
    
}

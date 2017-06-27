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
    weak var scoresController: ScoresController?
    private var colorScheme: ColorScheme!
    private var game: Game!
    private var gameView: NSView!
    private var gameViewLayer = CALayer()
    private weak var gameViewWidthConstraint:  NSLayoutConstraint?
    private weak var gameViewHeightConstraint: NSLayoutConstraint?
    private var tileShapeLayers: [[CAShapeLayer]]!
    private var tileTextLayers:  [[CATextLayer]]!
    private var previousGameOptions: Options?
    private var nextGameOptions:     Options?

    override func viewDidLoad() {
        super.viewDidLoad()
        if Preferences.difficulty == nil {
            Preferences.setDefaults()
        }
        colorScheme = Preferences.colorScheme
        nextGameOptions = Preferences.options
        newGame()

        gameView = NSView(frame: NSRect(origin: view.bounds.origin, size: gameViewSize))
        view.addSubview(gameView)
        gameView.wantsLayer = true
        gameView.layer?.addSublayer(gameViewLayer)

        gameView.translatesAutoresizingMaskIntoConstraints = false
        gameViewWidthConstraint = gameView.widthAnchor.constraint(equalToConstant: gameViewSize.width)
        gameViewHeightConstraint = gameView.heightAnchor.constraint(equalToConstant: gameViewSize.height)
        let centerX = NSLayoutConstraint(item:       gameView,
                                         attribute:  .centerX,
                                         relatedBy:  .equal,
                                         toItem:     view,
                                         attribute:  .centerX,
                                         multiplier: 1.0,
                                         constant:   0.0)
        let centerY = NSLayoutConstraint(item:       gameView,
                                         attribute:  .centerY,
                                         relatedBy:  .equal,
                                         toItem:     view,
                                         attribute:  .centerY,
                                         multiplier: 1.0,
                                         constant:   0.0)
        NSLayoutConstraint.activate([gameViewWidthConstraint!, gameViewHeightConstraint!, centerX, centerY])

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDefaultsDidChange(_:)),
                                               name: UserDefaults.didChangeNotification,
                                               object: UserDefaults.standard)

        view.window?.zoom(nil)
    }

    @objc func userDefaultsDidChange(_ sender: UserDefaults) {
        if colorScheme! != Preferences.colorScheme {
            colorScheme = Preferences.colorScheme
            drawGame(game.allTiles)
        }
        previousGameOptions = nextGameOptions
        nextGameOptions = Preferences.options
    }

    /// - postcondition: Adds sublayers to `gameViewLayer`, mutates `game`, `tileShapeLayers`,
    ///   `tileTextLayers`, and `previousGameSize`
    private func newGame() {
        guard let options = nextGameOptions,
            options.numMines <= options.gridSize.cols * options.gridSize.rows
            else { fatalError() }
        game = Game(size: options.gridSize, numMines: options.numMines, delegate: self)

        // (Re)create layers if first run or game dimensions changed
        if previousGameOptions == nil || previousGameOptions!.gridSize != options.gridSize {
            resetGameBoard()
            // Reset constraints
            if gameView != nil {
                gameViewWidthConstraint?.isActive = false
                gameViewHeightConstraint?.isActive = false
                gameViewWidthConstraint = gameView.widthAnchor.constraint(equalToConstant:
                    gameViewSize.width)
                gameViewHeightConstraint = gameView.heightAnchor.constraint(equalToConstant:
                    gameViewSize.height)
                NSLayoutConstraint.activate([gameViewWidthConstraint!, gameViewHeightConstraint!])
            }
        }

        previousGameOptions = options
        view.window?.title = "\(game.numMines) mines"
        drawGame(game.allTiles)
    }

    private func resetGameBoard() {
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
                shapeLayer.fillColor = colorScheme.tileColorCleared
                if tile.numAdjacentMines != 0 {
                    textLayer.string = "\(tile.numAdjacentMines)"
                }
                if let textColor = textColorForTile(tile) {
                    textLayer.foregroundColor = textColor
                }
            case .exploded:
                shapeLayer.fillColor = colorScheme.tileColorExploded
                textLayer.string = "💥"
            case .flagged:
                shapeLayer.fillColor = colorScheme.tileColorFlagged
                textLayer.string = "🚩"
            case .hidden:
                shapeLayer.fillColor = colorScheme.tileColorHidden
                textLayer.string = ""
            case .revealed:
                textLayer.string = "💣"
            }
        }
    }

    private func textColorForTile(_ tile: Tile) -> CGColor? {
        switch tile.numAdjacentMines {
        case 1:  return colorScheme.textColor1Mine
        case 2:  return colorScheme.textColor2Mine
        case 3:  return colorScheme.textColor3Mine
        case 4:  return colorScheme.textColor4Mine
        case 5:  return colorScheme.textColor5Mine
        case 6:  return colorScheme.textColor6Mine
        case 7:  return colorScheme.textColor7Mine
        case 8:  return colorScheme.textColor8Mine
        default: return nil
        }
    }

    private func endGame(_ won: Bool) {
        switch won {
        case true:
            view.window?.title = "Congratulations"
            scoresController?.addScore(Score(date:     Date(),
                                             numCols:  game.width,
                                             numMines: game.numMines,
                                             numRows:  game.height,
                                             time:     game.elapsedTime))
        case false:
            view.window?.title = "Uh-oh"
        }
    }

    /// - postcondition: Will call `gameDidUpdate`
    override func mouseUp(with event: NSEvent) {
        switch game.state {
        case .notStarted:
            game.resume()
            let point = gameView.convert(event.locationInWindow, from: nil)
            game.sweep(x: Int(point.x/20), y: Int(point.y/20))
        case .inProgress:
            let point = gameView.convert(event.locationInWindow, from: nil)
            game.sweep(x: Int(point.x/20), y: Int(point.y/20))
        case .paused:
            game.resume()
        case .won, .lost:
            newGame()
        }
    }

    /// - postcondition: Will call `gameDidUpdate`
    override func rightMouseDown(with event: NSEvent) {
        switch game.state {
        case .notStarted:
            game.resume()
            let point = gameView.convert(event.locationInWindow, from: nil)
            game.flag(x: Int(point.x/20), y: Int(point.y/20))
        case .inProgress:
            let point = gameView.convert(event.locationInWindow, from: nil)
            game.flag(x: Int(point.x/20), y: Int(point.y/20))
        case .paused:
            game.resume()
        case .won, .lost:
            newGame()
        }
    }
    
    @IBAction func startNewGame(_ sender: NSMenuItem) {
        newGame()
    }
}

extension GameViewController: GameDelegate {
    func gameDidUpdate(_ dirtyTiles: [Tile]) {
        drawGame(dirtyTiles)
        if game.state == .won || game.state == .lost {
            endGame(game.state == .won)
        }
    }
}

//
//  NSBezierPath+.swift
//  minisweeper
//
//  Created by David Wu on 6/10/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

extension NSBezierPath {
    // https://gist.github.com/juliensagot/9749c3a1df28c38fb9f9
    var cgPath: CGPath {
        let path = CGMutablePath()
        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
        if elementCount > 0 {
            var didClosePath = true
            for i in 0..<elementCount {
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

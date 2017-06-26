//
//  ColorScheme.swift
//  minisweeper
//
//  Created by David Wu on 6/23/17.
//  Copyright © 2017 Gofake1. All rights reserved.
//

import Cocoa

struct ColorScheme {

    static let modern =  ColorScheme(name: "Modern",
                                     tileColorCleared:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     tileColorHidden:   #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor,
                                     tileColorFlagged:  #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor,
                                     tileColorExploded: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor,
                                     textColor1Mine:    #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor,
                                     textColor2Mine:    #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor,
                                     textColor3Mine:    #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor,
                                     textColor4Mine:    #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor,
                                     textColor5Mine:    #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor,
                                     textColor6Mine:    #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,
                                     textColor7Mine:    #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor,
                                     textColor8Mine:    #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1).cgColor)

    static let sierra =  ColorScheme(name: "Sierra",
                                     tileColorCleared:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     tileColorHidden:   #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                                     tileColorFlagged:  #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor,
                                     tileColorExploded: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor,
                                     textColor1Mine:    #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor,
                                     textColor2Mine:    #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor,
                                     textColor3Mine:    #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor,
                                     textColor4Mine:    #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor,
                                     textColor5Mine:    #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor,
                                     textColor6Mine:    #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,
                                     textColor7Mine:    #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor,
                                     textColor8Mine:    #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1).cgColor)
    
    static let windows = ColorScheme(name: "Windows",
                                     tileColorCleared:  #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor,
                                     tileColorHidden:   #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).cgColor,
                                     tileColorFlagged:  #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor,
                                     tileColorExploded: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor,
                                     textColor1Mine:    #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor,
                                     textColor2Mine:    #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor,
                                     textColor3Mine:    #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1).cgColor,
                                     textColor4Mine:    #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).cgColor,
                                     textColor5Mine:    #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor,
                                     textColor6Mine:    #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).cgColor,
                                     textColor7Mine:    #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor,
                                     textColor8Mine:    #colorLiteral(red: 0.3176470697, green: 0.07450980693, blue: 0.02745098062, alpha: 1).cgColor)

    let name: String
    let tileColorCleared:  CGColor
    let tileColorHidden:   CGColor
    let tileColorFlagged:  CGColor
    let tileColorExploded: CGColor
    let textColor1Mine:    CGColor
    let textColor2Mine:    CGColor
    let textColor3Mine:    CGColor
    let textColor4Mine:    CGColor
    let textColor5Mine:    CGColor
    let textColor6Mine:    CGColor
    let textColor7Mine:    CGColor
    let textColor8Mine:    CGColor
}

extension ColorScheme: Equatable {
    static func ==(lhs: ColorScheme, rhs: ColorScheme) -> Bool {
        return lhs.name == rhs.name
    }
}

//
//  BoardView.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHiddenColors)
    var allGuessColors = [[UIColor]]()
    var turnNumber = 0
    
    private let globalData = GlobalData.sharedInstance
    private var leftOffset: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        leftOffset = (bounds.width - CGFloat(Constants.numberHiddenColors) * globalData.circleSeparation) / 2
        setNeedsDisplay()
    }
    
    func getHoleCenterPointFor(row: Int, col: Int) -> CGPoint {
        return CGPoint(x: leftOffset + globalData.circleSeparation * (CGFloat(col) + 0.5),
                       y: globalData.topOffset + globalData.circleSeparation * (CGFloat(row) + 0.5))
    }
    
    func getHoleColFor(xPos: CGFloat) -> Int {
        return Int(round((xPos - globalData.topOffset) / globalData.circleSeparation - 0.5))
    }
    
    func getHoleRowAndColFor(point: CGPoint) -> (row: Int, col: Int) {
        return (Int(round((point.x - globalData.topOffset) / globalData.circleSeparation - 0.5)),
                Int(round((point.y - globalData.topOffset) / globalData.circleSeparation - 0.5)))
    }

    override func draw(_ rect: CGRect) {
        for row in 0..<Constants.maxGuesses {
            if row < Constants.maxGuesses - 1 {
                drawLine(yPos: globalData.topOffset +  globalData.circleSeparation * CGFloat(row + 1))
            }
            for col in 0..<Constants.numberHiddenColors {
                let center = getHoleCenterPointFor(row: row, col: col)
                let color: UIColor = row < turnNumber ? allGuessColors[row][col] : row == turnNumber ? currentGuessColors[col] : Constants.boardColor
                drawHole(center: center, color: color)
            }
        }
    }

    private func drawHole(center: CGPoint, color: UIColor) {
        let circle = UIBezierPath(arcCenter: center,
                                  radius: globalData.marbleRadius,
                                  startAngle: 0.0,
                                  endAngle: 2.0 * CGFloat.pi,
                                  clockwise: true)
        circle.lineWidth = 2
        UIColor.black.setStroke()
        circle.stroke()
        color.setFill()
        circle.fill()
    }
    
    private func drawLine(yPos: CGFloat) {
        let indent = 0.04 * bounds.width
        let line = UIBezierPath()
        line.move(to: CGPoint(x: indent, y: yPos))
        line.addLine(to: CGPoint(x: bounds.width - indent, y: yPos))
        line.lineWidth = 1
        UIColor.black.setStroke()
        line.stroke()
    }
}

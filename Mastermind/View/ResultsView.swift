//
//  ResultsView.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

struct ResultsConst {
    static let pegRows = 2
}

class ResultsView: UIView {
    
    var results = [[Result]]()

    private let globalData = GlobalData.sharedInstance

    private var pegSeparation: CGFloat = 0
    private var leftPegOffset: CGFloat = 0
    private var numberPegColumns = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        numberPegColumns = Int(round(CGFloat(Constants.numberHidden) / 2))
        pegSeparation = globalData.circleSeparation / CGFloat(ResultsConst.pegRows)
        leftPegOffset = (bounds.width - CGFloat(numberPegColumns) * pegSeparation) / 2
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        for row in 0..<Constants.maxGuesses {
            if row < Constants.maxGuesses - 1 { drawLine(yPos: globalData.topOffset +  globalData.circleSeparation * CGFloat(row + 1)) }
            for subRow in 0..<ResultsConst.pegRows {
                for col in 0..<numberPegColumns {
                    let pegNumber = subRow * numberPegColumns + col
                    if pegNumber < Constants.numberHidden {
                        let center = CGPoint(x: leftPegOffset + pegSeparation * (CGFloat(col) + 0.5),
                                             y: globalData.topOffset + pegSeparation * (CGFloat(row * ResultsConst.pegRows + subRow) + 0.5))
                        let color: UIColor = row < results.count ?
                            Constants.resultColors[results[row][subRow * numberPegColumns + col].rawValue] : Constants.boardColor
                        drawHole(center: center, color: color)
                    }
                }
            }
        }
    }

    private func drawHole(center: CGPoint, color: UIColor) {
        let circle = UIBezierPath(arcCenter: center,
                                  radius: 0.3 * pegSeparation,
                                  startAngle: 0.0,
                                  endAngle: 2.0 * CGFloat.pi,
                                  clockwise: true)
        circle.lineWidth = 1
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

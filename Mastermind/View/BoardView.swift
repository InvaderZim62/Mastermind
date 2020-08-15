//
//  BoardView.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var guesses = [[UIColor]]()
    
    private let globalData = GlobalData.sharedInstance
    private var leftOffset: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        globalData.circleSeparation = min(bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                                          bounds.width / (CGFloat(Constants.numberHidden) + 0.5))
        globalData.topOffset = (bounds.height - CGFloat(Constants.maxGuesses) * globalData.circleSeparation) / 2
        leftOffset = (bounds.width - CGFloat(Constants.numberHidden) * globalData.circleSeparation) / 2
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        for row in 0..<Constants.maxGuesses {
            for col in 0..<Constants.numberHidden {
                let center = CGPoint(x: leftOffset + globalData.circleSeparation * (CGFloat(col) + 0.5),
                                     y: globalData.topOffset + globalData.circleSeparation * (CGFloat(row) + 0.5))
                let color: UIColor = row < guesses.count ? guesses[row][col] : row == guesses.count ? Constants.backgroundColor : Constants.boardColor
                drawHole(center: center, color: color)
            }
        }
    }
    
    private func drawLine(yPos: Double) {
        
    }

    private func drawHole(center: CGPoint, color: UIColor) {
        let circle = UIBezierPath(arcCenter: center,
                                  radius: 0.3 * globalData.circleSeparation,
                                  startAngle: 0.0,
                                  endAngle: 2.0 * CGFloat.pi,
                                  clockwise: true)
        circle.lineWidth = 2
        UIColor.black.setStroke()
        circle.stroke()
        color.setFill()
        circle.fill()
    }
}

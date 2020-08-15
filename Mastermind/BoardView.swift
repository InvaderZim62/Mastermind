//
//  BoardView.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

class BoardView: UIView {
    
    var guessesMade = 0
    var guesses = [[UIColor]]()

    private var circleSeparation: CGFloat = 0
    private var topOffset: CGFloat = 0
    private var leftOffset: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        // center 10 x 4 group of circles, no matter what the aspect ratio of BoardView is
        circleSeparation = min(bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                               bounds.width / (CGFloat(Constants.maxColumns) + 0.5))
        topOffset = (bounds.height - CGFloat(Constants.maxGuesses) * circleSeparation) / 2
        leftOffset = (bounds.width - CGFloat(Constants.maxColumns) * circleSeparation) / 2
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        for row in 0..<Constants.maxGuesses {
            for col in 0..<Constants.maxColumns {
                let center = CGPoint(x: leftOffset + circleSeparation * (CGFloat(col) + 0.5),
                                     y: topOffset + circleSeparation * (CGFloat(row) + 0.5))
                let color: UIColor = row < guessesMade ? guesses[row][col] : row == guessesMade ? Constants.backgroundColor : Constants.boardColor
                drawHole(center: center, color: color)
            }
        }
    }

    private func drawHole(center: CGPoint, color: UIColor) {
        let circle = UIBezierPath(arcCenter: center,
                                  radius: 0.3 * circleSeparation,
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

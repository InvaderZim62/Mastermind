//
//  PalletView.swift
//  Mastermind
//
//  Created by Phil Stern on 8/18/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

class PalletView: UIView {
    
    var isShowing = false { didSet { setNeedsDisplay() } }  // isShowing true after game over (show hidden marbles)
    var hiddenColors = [UIColor]()
    
    private let globalData = GlobalData.sharedInstance
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }

    func getHoleCenterPointFor(col: Int) -> CGPoint {
        return CGPoint(x: globalData.leftOffset + globalData.circleSeparation * (CGFloat(col) + 0.5),
                       y: bounds.midY)
    }

    override func draw(_ rect: CGRect) {
        if isShowing {
            for col in 0..<hiddenColors.count {
                let center = getHoleCenterPointFor(col: col)
                let color: UIColor = hiddenColors[col]
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
}

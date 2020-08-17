//
//  MarbleView.swift
//  Avalanche
//
//  Created by Phil Stern on 9/26/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit

class MarbleView: UIView {
    
    var color = UIColor()
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        self.color = color
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        let radius = min(self.bounds.width, self.bounds.height) / 2.05
        let circle = UIBezierPath(arcCenter: center,
                                  radius: radius,
                                  startAngle: 0.0,
                                  endAngle: 2.0 * CGFloat.pi,
                                  clockwise: true)
        color.setFill()
        circle.fill()
    }
}

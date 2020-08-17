//
//  CGPointExtension.swift
//  Gears
//
//  Created by Phil Stern on 8/15/19.
//  Copyright © 2019 Phil Stern. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func distance(from point: CGPoint) -> Double {
        return Double(sqrt(pow((self.x - point.x), 2) + pow((self.y - point.y), 2)))
    }
    
    func angle(from point: CGPoint) -> Double {
        return Double(atan2(self.y - point.y, self.x - point.x))  // zero to right, positive clockwise
    }
}

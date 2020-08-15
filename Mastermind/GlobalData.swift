//
//  GlobalData.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

class GlobalData: NSObject {
    static let sharedInstance = GlobalData()
    private override init() {}  // private to prevent: let myInstance = GlobalData() (a non-shared instance)
    
    var circleSeparation: CGFloat = 0
    var topOffset: CGFloat = 0
}

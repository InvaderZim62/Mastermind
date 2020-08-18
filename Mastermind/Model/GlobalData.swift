//
//  GlobalData.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//
//  This class contains the properties that change with screen orientation.  They are computed based on
//  the layout of BoardView.  Since the order that iOS calls layoutSubviews for each view (BoardView,
//  ResultsView, pallet UIView,...) is arbitrary, the properties are updated in
//  MastermindViewController.viewDidLayoutSubviews, which is called after the views are layed out, but
//  before the layoutSubviews functions are called.
//

import UIKit

class GlobalData: NSObject {
    static let sharedInstance = GlobalData()
    private override init() {}  // private to prevent: let myInstance = GlobalData() (a non-shared instance)
    
    var circleSeparation: CGFloat = 0
    var topOffset: CGFloat = 0
    var leftOffset: CGFloat = 0
    var marbleRadius: CGFloat = 0
}

//
//  MastermindViewController.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import UIKit

struct Constants {
    static let backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    static let boardColor = #colorLiteral(red: 0.9607843137, green: 0.8941176471, blue: 0.8588235294, alpha: 1)
    static let marbleColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
    static let maxGuesses = 10
    static let maxColumns = 4
}

class MastermindViewController: UIViewController {
    
    var guessesMade = 0
    var guesses = [[UIColor]]()

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var codeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        boardView.backgroundColor = Constants.boardColor
        createTestData()
    }
    
    private func createTestData() {
        guessesMade = 3
        for _ in 0..<guessesMade {
            var colorRow = [UIColor]()
            for _ in 0..<Constants.maxColumns {
                colorRow.append(Constants.marbleColors.randomElement()!)
            }
            guesses.append(colorRow)
        }
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        boardView.guesses = guesses
        boardView.guessesMade = guessesMade
        boardView.setNeedsDisplay()
    }
}


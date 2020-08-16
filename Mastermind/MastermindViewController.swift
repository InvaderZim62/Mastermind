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
    static let resultColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), Constants.boardColor]  // same order as enum Result
    static let maxGuesses = 10
    static let numberHidden = 4
}

enum Result: Int, CaseIterable {  // CaseIterable allows Ressult.allCases
    case rightColorRightPosition
    case rightColorWrongPosition
    case wrongColor
}

class MastermindViewController: UIViewController {
    
    var guesses = [[UIColor]]()  // guesses[row][col]
    var results = [[Result]]()  // results[row][position]

    private let globalData = GlobalData.sharedInstance

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var marbleView: MarblesView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        boardView.backgroundColor = Constants.boardColor
        createTestData()
    }
    
    override func viewDidLayoutSubviews() {  // pws: delete this (redundant)
        super.viewDidLayoutSubviews()
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        // Note: don't move this to BoardView, since ResultsView gets called before BoardView
        globalData.circleSeparation = min(boardView.bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                                          boardView.bounds.width / (CGFloat(Constants.numberHidden) + 0.5))
        globalData.topOffset = (boardView.bounds.height - CGFloat(Constants.maxGuesses) * globalData.circleSeparation) / 2
    }

    private func createTestData() {
        let numberOfGuesses = 3
        for _ in 0..<numberOfGuesses {
            var colorRow = [UIColor]()
            var resultRow = [Result]()
            for _ in 0..<Constants.numberHidden {
                colorRow.append(Constants.marbleColors.randomElement()!)
                resultRow.append(Result.allCases.randomElement()!)
            }
            guesses.append(colorRow)
            results.append(resultRow)
        }
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        boardView.guesses = guesses
        boardView.setNeedsDisplay()
        resultsView.results = results
        resultsView.setNeedsDisplay()
    }
}

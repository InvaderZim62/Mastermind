//
//  MastermindViewController.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//
//  Useful conversion...
//  UIColor to value in marbleColors array     marbleView.color.value
//
// To do...
// - add "Get Results" button
// - allow marbles to be removed, before getting results
// - show hidden marbles when game is over (maybe just if game is lost)
// - send won/lost message to screen
// - add a "Play Again" button, and add reset capability
//

import UIKit

struct Constants {
    static let backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    static let boardColor = #colorLiteral(red: 0.9607843137, green: 0.8941176471, blue: 0.8588235294, alpha: 1)
    static let marbleColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
    static let resultColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), Constants.boardColor]  // same order as enum Result
    static let maxGuesses = 10  // max guesses allowed
    static let numberHidden = 4  // number of hidden colors
}

class MastermindViewController: UIViewController {
    
    var mastermind = Mastermind(numberHidden: Constants.numberHidden, maxGuesses: Constants.maxGuesses)
    let globalData = GlobalData.sharedInstance
    var currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHidden)  // the current guess, being built up
    var results = [[Result]]()  // results[row][position]
    var isGameOver = false
    var pannableMarbleViews = [MarbleView]()
    var startPanPoint = CGPoint()

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var marbleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        boardView.backgroundColor = Constants.boardColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        // Note: don't move this to BoardView, since ResultsView gets called before BoardView
        globalData.circleSeparation = min(boardView.bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                                          boardView.bounds.width / (CGFloat(Constants.numberHidden) + 0.5))
        globalData.topOffset = (boardView.bounds.height - CGFloat(Constants.maxGuesses) * globalData.circleSeparation) / 2
        globalData.marbleRadius = 0.3 * globalData.circleSeparation
        
        // remove and re-add marbles (with new sizes) when orientation changes
        pannableMarbleViews.forEach { $0.removeFromSuperview() }
        pannableMarbleViews.removeAll()
        
        // add marbles to self.view, using marbleView for alignment
        let marbleSpacing = marbleView.frame.width / CGFloat(Constants.marbleColors.count + 1)
        for (index, marbleColor) in Constants.marbleColors.enumerated() {
            let center = CGPoint(x: marbleView.frame.origin.x + marbleSpacing * CGFloat(index + 1),
                                 y: marbleView.frame.midY)
            createPannableMarbleAt(center, color: marbleColor)
        }
    }
    
    private func updateViewFromModel() {
        if isGameOver {
            currentGuessColors = [UIColor](repeating: Constants.boardColor, count: Constants.numberHidden)  // don't darken next row
        }
        boardView.currentGuess = currentGuessColors
        boardView.guessColors = mastermind.guessColors  // .guessColors from extension, below
        boardView.turnNumber = mastermind.guessNumber
        boardView.setNeedsDisplay()
        resultsView.results = results
        resultsView.setNeedsDisplay()
    }

    // create pannable marble in pallet or extra area
    private func createPannableMarbleAt(_ center: CGPoint, color: UIColor) {
        let marbleDiameter = 2 * globalData.marbleRadius
        let frame = CGRect(x: 0, y: 0, width: marbleDiameter, height: marbleDiameter)
        let marbleView = MarbleView(frame: frame, color: color)
        marbleView.center = center
        marbleView.backgroundColor = .clear

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        marbleView.addGestureRecognizer(pan)
        
        pannableMarbleViews.append(marbleView)
        view.addSubview(marbleView)
    }

    // have pallet marble follow user's finger.  if released at a hole, return
    // panned marble to pallet (instantly) and fill in the hole
    @objc private func handlePan(pan: UIPanGestureRecognizer) {
        guard !isGameOver else { return }
        let translation = pan.translation(in: view)
        if let marbleView = pan.view as? MarbleView {
            if pan.state == .began {
                startPanPoint = marbleView.center
            }
            marbleView.center = CGPoint(x: marbleView.center.x + translation.x,
                                        y: marbleView.center.y + translation.y)
            pan.setTranslation(CGPoint.zero, in: view)
            
            // if panned marble at a hole, return it to pallet and fill in the hole
            if pan.state == .ended {
                if isInHole(marbleView) {
                    // return marble to startPanPoint instantly, if in hole (isInHole stores the guess)
                    marbleView.center = self.startPanPoint
                    let colorsFilled = currentGuessColors.filter { $0 != Constants.backgroundColor }
                    if colorsFilled.count == Constants.numberHidden {
                        checkResults()
                    }
                } else {
                    // return marble to startPanPoint slowly, if missed hole
                    UIView.animate(withDuration: 0.3, animations: {  // move to pallet in 0.3 sec
                        marbleView.center = self.startPanPoint
                    })
                }
            }
        }
    }
    
    private func isInHole(_ marbleView: MarbleView) -> Bool {
        var isInHole = false
        for holeIndex in 0..<Constants.numberHidden {
            let holeCenter = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
            let marblePoint = view.convert(marbleView.center, to: boardView)  // convert from view to boardView coords
            if marblePoint.distance(from: holeCenter) < 12 {
                currentGuessColors[holeIndex] = marbleView.color
                updateViewFromModel()
                isInHole = true
                break
            }
        }
        return isInHole
    }
    
    private func checkResults() {
        let currentGuessValues = currentGuessColors.map { $0.value }
        let result = mastermind.getResultsFor(guess: currentGuessValues)
        currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHidden)  // reset
        results.append(result)
        let rightMarbles = result.filter { $0 == .rightColorRightPosition }
        if rightMarbles.count == Constants.numberHidden {
            isGameOver = true
            print("You Win!")
        } else if mastermind.guessNumber == Constants.maxGuesses {
            isGameOver = true
            print("You Lose!")
        }
        updateViewFromModel()
    }
}

extension UIColor {
    // index of UIColor in Constants.marbleColors array
    var value: Int {
        return Constants.marbleColors.firstIndex(of: self)!
    }
}

extension Mastermind {
    // 2D array of UIColors corresponding to guessValues
    var guessColors: [[UIColor]] {
        return guessValues.map { $0.map { Constants.marbleColors[$0] } }
    }
}

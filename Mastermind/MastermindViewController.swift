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
// - allow marbles to be removed, before getting results
// - show hidden marbles when game is over (maybe just if game is lost)
// - send won/lost message to screen
// - add settingsVC for changing maxGuesses and numberHidden
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
    var pannableMarbleViews = [MarbleView]()
    var startPanPoint = CGPoint()
    var isGameOver = false {
        didSet {
            playAgainButton.isHidden = !isGameOver
            if isGameOver {
                currentGuessColors = [UIColor](repeating: Constants.boardColor, count: Constants.numberHidden)  // don't darken next row
            } else {
                currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHidden)  // darken first row for new game
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var palletView: UIView!  // view at bottom where pannable marbles reside
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var showResultsButton: UIButton!
    @IBOutlet weak var resultsButtonOffset: NSLayoutConstraint!
    
    // MARK: - Start of Code
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        boardView.backgroundColor = Constants.boardColor
        playAgainButton.isHidden = true
        playAgainButton.layer.borderWidth = 2
        playAgainButton.layer.borderColor = UIColor.white.cgColor
        showResultsButton.isHidden = true  // unhide when all four guess positions are filled
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        // Note: don't move this to BoardView, since ResultsView gets called before BoardView
        globalData.circleSeparation = min(boardView.bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                                          boardView.bounds.width / (CGFloat(Constants.numberHidden) + 0.5))
        globalData.topOffset = (boardView.bounds.height - CGFloat(Constants.maxGuesses) * globalData.circleSeparation) / 2
        globalData.marbleRadius = 0.3 * globalData.circleSeparation

        setResultsButtonOffset()

        // remove and re-add marbles (with new sizes) when orientation changes
        pannableMarbleViews.forEach { $0.removeFromSuperview() }
        pannableMarbleViews.removeAll()
        
        // add marbles to self.view, using palletView for alignment
        let marbleSpacing = palletView.frame.width / CGFloat(Constants.marbleColors.count + 1)
        for (index, marbleColor) in Constants.marbleColors.enumerated() {
            let center = CGPoint(x: palletView.frame.origin.x + marbleSpacing * CGFloat(index + 1),
                                 y: palletView.frame.midY)
            createPannableMarbleAt(center, color: marbleColor)
        }
    }
    
    private func reset() {
        mastermind.reset()
        isGameOver = false
        setResultsButtonOffset()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        boardView.currentGuess = currentGuessColors
        boardView.guessColors = mastermind.guessColors  // .guessColors from extension, below
        boardView.turnNumber = mastermind.guessNumber
        boardView.setNeedsDisplay()
        resultsView.results = mastermind.results
        resultsView.setNeedsDisplay()
    }
    
    private func setResultsButtonOffset() {
        let holeCenterPoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: 0)
        resultsButtonOffset.constant = holeCenterPoint.y
    }

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

    // Have pallet marble follow user's finger.  If released at a hole, return
    // panned marble to pallet (instantly) and fill in the hole.
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
            
            if pan.state == .ended {
                if isInHole(marbleView) {
                    // return marble to startPanPoint instantly, to allow re-use (isInHole stores the guess)
                    marbleView.center = self.startPanPoint
                    let colorsFilled = currentGuessColors.filter { $0 != Constants.backgroundColor }
                    if colorsFilled.count == Constants.numberHidden {
                        showResultsButton.isHidden = false
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
    
    // MARK: - Button Actions
    
    @IBAction func playAgainPressed(_ sender: UIButton) {
        reset()
    }
    
    @IBAction func showResultsPressed(_ sender: UIButton) {
        showResultsButton.isHidden = true
        getResults()
        setResultsButtonOffset()  // move button to next row
    }
    
    private func getResults() {
        let currentGuessValues = currentGuessColors.map { $0.value }
        let result = mastermind.getResultFor(guess: currentGuessValues)
        currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHidden)  // reset
        let rightMarbles = result.filter { $0 == .rightColorRightPosition }
        if rightMarbles.count == Constants.numberHidden {
            isGameOver = true
            print("You Won!")
        } else if mastermind.guessNumber == Constants.maxGuesses {
            isGameOver = true
            print("You Lost!")
        }
        updateViewFromModel()
    }
}

// MARK: - Extensions

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

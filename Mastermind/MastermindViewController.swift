//
//  MastermindViewController.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//
//  currentGuessColors is an array of UIColor (one for each hole in the current row).  It is passed to boardView for drawing.
//  It starts out using the darker Constants.background color, to let the user know which row (mastermind.guessNumber) is being
//  worked on.  As each "marble" is panned to a hole, the color of the marbleView is saved in the corresponding position in
//  currentGuessColors.  When all four (numberHiddenColors) holes are filled, the showResults button is shown.  When the
//  showResults button is pressed, currentGuessColors is set back to Constants.background color.
//
//  mastermind.allGuessValues is a 2D array (row x col) of Int.  It contains the color values (indices into the
//  Constants.marbleColors array) of all past guesses.  It is past to boardView for drawing.  It starts out empty and grows
//  one row at a time.  allGuessValues is converted to a 2D array of UIColor called allGuessColors, using the computed property
//  in an extention to Mastermind at the bottom of this file.
//
//  Useful conversions...
//  UIColor to value in marbleColors array     marbleView.color.value     let currentGuessValues = currentGuessColors.map { $0.value }
//
//  To do...
//  - position board marbleViews correctly when orientation changes
//  - show hidden marbles when game is over (maybe just if game is lost)
//  - send won/lost message to screen
//  - add settingsVC for changing maxGuesses and numberHiddenColors
//

import UIKit

struct Constants {
    static let backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    static let boardColor = #colorLiteral(red: 0.9607843137, green: 0.8941176471, blue: 0.8588235294, alpha: 1)
    static let marbleColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
    static let resultColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), Constants.boardColor]  // same order as enum Result
    static let maxGuesses = 10  // max guesses allowed
    static let numberHiddenColors = 4  // number of hidden colors
}

class MastermindViewController: UIViewController {
    
    var mastermind = Mastermind(numberHidden: Constants.numberHiddenColors, maxGuesses: Constants.maxGuesses)
    let globalData = GlobalData.sharedInstance
    var currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHiddenColors)  // the current guess, being built up
    var palletMarbleViews = [MarbleView]()
    var boardMarbleViews = [Int: MarbleView]()  // [hole number: marbleView]
    var startPalletPanPoint = CGPoint()
    var startBoardPanHoleIndex = 0
    var isGameOver = false {
        didSet {
            playAgainButton.isHidden = !isGameOver
            if isGameOver {
                currentGuessColors = [UIColor](repeating: Constants.boardColor, count: Constants.numberHiddenColors)  // don't darken next row
            } else {
                currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.numberHiddenColors)  // darken first row for new game
            }
            updateViewFromModel()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var palletView: UIView!  // view at bottom where marble selection resides
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
        
        // add marbles to self.view, using palletView for alignment
        for marbleColor in Constants.marbleColors {
            createPalletMarbleWith(color: marbleColor)
        }
    }
    
    // called when orientation changes or subview added
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        // Note: don't move this to BoardView, since ResultsView gets called before BoardView
        globalData.circleSeparation = min(boardView.bounds.height / (CGFloat(Constants.maxGuesses) + 0.5),
                                          boardView.bounds.width / (CGFloat(Constants.numberHiddenColors) + 0.5))
        globalData.topOffset = (boardView.bounds.height - CGFloat(Constants.maxGuesses) * globalData.circleSeparation) / 2
        globalData.marbleRadius = 0.3 * globalData.circleSeparation

        setResultsButtonOffset()
        setFrameAndCenterForPalletMarbles()
        setFrameAndCenterForBoardMarbles()
    }
    
    private func reset() {
        mastermind.reset()
        setResultsButtonOffset()
        isGameOver = false
    }
    
    private func updateViewFromModel() {
        boardView.currentGuessColors = currentGuessColors
        boardView.allGuessColors = mastermind.allGuessColors  // .allGuessColors from extension, below
        boardView.turnNumber = mastermind.guessNumber
        boardView.setNeedsDisplay()
        resultsView.results = mastermind.results
        resultsView.setNeedsDisplay()
    }
    
    private func createPalletMarbleWith(color: UIColor) {
        let marbleView = MarbleView(color: color)  // frame and center will be set in viewDidLayoutSubviews

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanFromPallet))
        marbleView.addGestureRecognizer(pan)
        
        palletMarbleViews.append(marbleView)
        view.addSubview(marbleView)
    }

    private func setResultsButtonOffset() {
        let holeCenterPoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: 0)
        resultsButtonOffset.constant = holeCenterPoint.y
    }
    
    private func setFrameAndCenterForPalletMarbles() {
        let marbleSpacing = palletView.frame.width / CGFloat(Constants.marbleColors.count + 1)
        for (index, palletMarbleView) in palletMarbleViews.enumerated() {
            let marbleDiameter = 2 * globalData.marbleRadius
            let frame = CGRect(x: 0, y: 0, width: marbleDiameter, height: marbleDiameter)
            let center = CGPoint(x: palletView.frame.origin.x + marbleSpacing * CGFloat(index + 1),
                                 y: palletView.frame.midY)
            palletMarbleView.frame = frame
            palletMarbleView.center = center
        }
    }

    // Have pallet marble follow user's finger.  If released at a hole, return it to the pallet instantly,
    // and create a board marble in its place.  If released away from a hole, return it to the pallet slowly.
    @objc private func handlePanFromPallet(pan: UIPanGestureRecognizer) {
        guard !isGameOver else { return }
        let translation = pan.translation(in: view)
        if let marbleView = pan.view as? MarbleView {
            if pan.state == .began {
                marbleView.layer.zPosition = 2
                startPalletPanPoint = marbleView.center
            }
            marbleView.center = CGPoint(x: marbleView.center.x + translation.x,
                                        y: marbleView.center.y + translation.y)
            pan.setTranslation(CGPoint.zero, in: view)
            
            if pan.state == .ended {
                if let holeIndex = nearbyHole(marbleView) {
                    marbleView.layer.zPosition = 1
                    currentGuessColors[holeIndex] = marbleView.color
                    updateViewFromModel()  // pws: still needed?
                    // return marble to startPanPoint instantly, to allow re-use (isInHole stores the guess)
                    marbleView.center = self.startPalletPanPoint
                    // delete any existing marbleView at the destination hole
                    if let existingMarbleView = boardMarbleViews[holeIndex] {
                        existingMarbleView.removeFromSuperview()
                    }
                    createBoardMarbleWith(color: marbleView.color, at: holeIndex)
                    let colorsFilled = currentGuessColors.filter { $0 != Constants.backgroundColor }
                    showResultsButton.isHidden = colorsFilled.count != Constants.numberHiddenColors
                } else {
                    // return marble to startPanPoint slowly, if missed hole
                    UIView.animate(withDuration: 0.3, animations: {  // move to pallet in 0.3 sec
                        marbleView.center = self.startPalletPanPoint
                    })
                }
            }
        }
    }
    
    private func nearbyHole(_ marbleView: MarbleView) -> Int? {
        for holeIndex in 0..<Constants.numberHiddenColors {
            let holeCenter = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
            let marblePoint = view.convert(marbleView.center, to: boardView)  // convert from view to boardView coords
            if marblePoint.distance(from: holeCenter) < 15 {
                return holeIndex
            }
        }
        return nil
    }
    
    private func createBoardMarbleWith(color: UIColor, at holeIndex: Int) {
        let marbleView = MarbleView(color: color)  // frame and center will be set in viewDidLayoutSubviews

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanFromBoard))
        marbleView.addGestureRecognizer(pan)
        
        boardMarbleViews[holeIndex] = marbleView
        view.addSubview(marbleView)
    }
    
    private func setFrameAndCenterForBoardMarbles() {
        for (holeIndex, _) in boardMarbleViews {
            let marbleDiameter = 2 * globalData.marbleRadius
            let frame = CGRect(x: 0, y: 0, width: marbleDiameter, height: marbleDiameter)
            let holePoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
            boardMarbleViews[holeIndex]!.frame = frame
            boardMarbleViews[holeIndex]!.center = boardView.convert(holePoint, to: view)  // convert from boardView to view coords
        }
    }

    // Have board marble follow user's finger.  If released at a hole, center it there and remove any marble
    // at that location.  If released away from a hole, return it to its original hole slowly.
    @objc private func handlePanFromBoard(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view)
        if let marbleView = pan.view as? MarbleView {
            if pan.state == .began {
                marbleView.layer.zPosition = 2
                let marblePoint = view.convert(marbleView.center, to: boardView)  // convert from view to boardView coords
                startBoardPanHoleIndex = boardView.getHoleColFor(xPos: marblePoint.x)
                currentGuessColors[startBoardPanHoleIndex] = Constants.backgroundColor
                updateViewFromModel()
            }
            marbleView.center = CGPoint(x: marbleView.center.x + translation.x,
                                        y: marbleView.center.y + translation.y)
            pan.setTranslation(CGPoint.zero, in: view)
            
            if pan.state == .ended {
                if let holeIndex = nearbyHole(marbleView) {
                    marbleView.layer.zPosition = 1
                    // center marbleView at holeIndex
                    let holePoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
                    marbleView.center = boardView.convert(holePoint, to: view)  // convert from boardView to view coords
                    currentGuessColors[holeIndex] = marbleView.color
                    updateViewFromModel()  // pws: still needed?
                    // delete existing marble at destination hole (if not the panned marble)
                    if holeIndex != startBoardPanHoleIndex, let existingMarbleView = boardMarbleViews[holeIndex] {
                        existingMarbleView.removeFromSuperview()
                    }
                    boardMarbleViews[startBoardPanHoleIndex] = nil
                    boardMarbleViews[holeIndex] = marbleView
                } else {
                    // delete marble, if missed hole
                    marbleView.removeFromSuperview()
                    boardMarbleViews[startBoardPanHoleIndex] = nil
                }
                let colorsFilled = currentGuessColors.filter { $0 != Constants.backgroundColor }
                showResultsButton.isHidden = colorsFilled.count != Constants.numberHiddenColors
            }
        }
    }

    // MARK: - Button Actions
    
    @IBAction func playAgainPressed(_ sender: UIButton) {
        reset()
    }
    
    @IBAction func showResultsPressed(_ sender: UIButton) {
        showResultsButton.isHidden = true
        setResultsButtonOffset()  // move button to next row
        getResults()
        boardMarbleViews.values.forEach { $0.removeFromSuperview() }
        boardMarbleViews.removeAll()
    }
    
    private func getResults() {
        let currentGuessValues = currentGuessColors.map { $0.value }
        let result = mastermind.getResultFor(guess: currentGuessValues)
        let rightMarbles = result.filter { $0 == .rightColorRightPosition }
        if rightMarbles.count == Constants.numberHiddenColors {
            isGameOver = true
            print("You Won!")
        } else if mastermind.guessNumber == Constants.maxGuesses {
            isGameOver = true
            print("You Lost!")
        } else {
            isGameOver = false
        }
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
    // 2D array of UIColors corresponding to allGuessValues
    var allGuessColors: [[UIColor]] {
        return allGuessValues.map { $0.map { Constants.marbleColors[$0] } }
    }
}

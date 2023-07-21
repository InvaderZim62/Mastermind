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
//  mastermind.allGuessColors is a 2D array (row x col) of UIColor.  It contains the colors of all past guesses.  It is past
//  to boardView for drawing.  It starts out empty and grows one row at a time.
//
//  PalletView is used to show the hidden marble colors when the game is over.  It is also used to align the marbleViews for
//  use in the game, even though the marbleViews are subviews of the main view.  During the game, the palletView zPosition is
//  set to 0, so the hidden marbles drawn on it cannot be seen.  When the game is over, the zPosition is set to two, so it
//  covers the marbleViews.
//

import UIKit

struct Constants {
    static let backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
    static let boardColor = #colorLiteral(red: 0.9607843137, green: 0.8941176471, blue: 0.8588235294, alpha: 1)
    static let marbleColors = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1)]
    static let defaultMaxGuesses = 8  // max guesses allowed
    static let defaultNumberHiddenColors = 4  // number of hidden colors
}

enum Result: RawRepresentable, CaseIterable {  // RawRepresentable allows result.rawValue = UIColor, CaseIterable allows Result.allCases
    case rightColorRightPosition
    case rightColorWrongPosition
    case wrongColor
    
    init?(rawValue: UIColor) {  // needed for RawRepresentable
        return nil  // just return nil, since never going to declare result = Result(rawValue: .white)
    }
    
    var rawValue: UIColor {  // needed for RawRepresentable
        switch self {
        case .rightColorRightPosition:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .rightColorWrongPosition:
            return #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        case .wrongColor:
            return Constants.boardColor
        }
    }
}

class MastermindViewController: UIViewController {
    
    var maxGuesses = Constants.defaultMaxGuesses
    var numberHiddenColors = Constants.defaultNumberHiddenColors
    var mastermind = Mastermind<UIColor>(colorChoices: Constants.marbleColors,
                                         maxGuesses: Constants.defaultMaxGuesses,
                                         numberHidden: Constants.defaultNumberHiddenColors)
    var currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: Constants.defaultNumberHiddenColors)  // the current guess, being built up
    let globalData = GlobalData.sharedInstance
    var palletMarbleViews = [MarbleView]()
    var boardMarbleViews = [Int: MarbleView]()  // [hole number: marbleView]
    var startPalletPanPoint = CGPoint()
    var startBoardPanHoleIndex = 0
    var isSuccess = false {
        didSet {
            messageLabel.text = isSuccess ? "You Solved It!" : "Out of Guesses"
        }
    }
    var isGameOver = false {
        didSet {
            playAgainButton.isHidden = !isGameOver
            messageLabel.isHidden = !isGameOver
            coverView.alpha = isGameOver ? 0.4 : 0  // darken screen and prevent touches from passing through
            palletView.isShowing = isGameOver
            palletView.layer.zPosition = isGameOver ? 2 : 0
            if isGameOver {
                currentGuessColors = [UIColor](repeating: Constants.boardColor, count: numberHiddenColors)  // don't darken next row
            } else {
                currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: numberHiddenColors)  // darken first row for new game
            }
            updateViewFromModel()
        }
    }

    // MARK: - Outlets

    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var boardView: BoardView!
    @IBOutlet weak var resultsView: ResultsView!
    @IBOutlet weak var palletView: PalletView!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var showResultsButton: UIButton!
    @IBOutlet weak var resultsButtonOffset: NSLayoutConstraint!  // distance from top of resultsView to top of "Show Results" button
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Start of Code
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor
        boardView.backgroundColor = Constants.boardColor
        playAgainButton.isHidden = true
        playAgainButton.layer.borderWidth = 2
        playAgainButton.layer.borderColor = UIColor.white.cgColor
        showResultsButton.isHidden = true  // unhide when all four guess positions are filled
        messageLabel.isHidden = true
        // add marbles to self.view, using palletView for alignment
        for marbleColor in Constants.marbleColors {
            createPalletMarbleWith(color: marbleColor)
        }
        getUserDefaults()
        reset()
    }
    
    // called when orientation changes or subview added
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setGlobalData()
        
        setResultsButtonOffset()
        setFrameAndCenterForPalletMarbles()
        setFrameAndCenterForBoardMarbles()
        
        updateViewFromModel()
    }
    
    func getUserDefaults() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "maxGuesses") != nil {
            maxGuesses = defaults.integer(forKey: "maxGuesses")
            numberHiddenColors = defaults.integer(forKey: "numberHiddenColors")
        } else {
            maxGuesses = Constants.defaultMaxGuesses
            numberHiddenColors = Constants.defaultNumberHiddenColors
        }
        setUserDefaults()
    }
    
    func setUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(maxGuesses, forKey: "maxGuesses")
        defaults.set(numberHiddenColors, forKey: "numberHiddenColors")
    }

    // GlobalData has layout-dependent properties
    private func setGlobalData() {
        // center 10 x 4 grid of circles, no matter what the aspect ratio of BoardView is
        // Note: don't move this to BoardView, since ResultsView gets called before BoardView
        globalData.circleSeparation = min(boardView.bounds.height / (CGFloat(maxGuesses) + 0.5),
                                          boardView.bounds.width / (CGFloat(numberHiddenColors) + 0.5))
        globalData.topOffset = (boardView.bounds.height - CGFloat(maxGuesses) * globalData.circleSeparation) / 2
        globalData.leftOffset = (boardView.bounds.width - CGFloat(numberHiddenColors) * globalData.circleSeparation) / 2
        globalData.marbleRadius = 0.3 * globalData.circleSeparation
    }
    
    private func updateViewFromModel() {
        boardView.currentGuessColors = currentGuessColors
        boardView.allGuessColors = mastermind.allGuessColors
        resultsView.results = mastermind.results
    }

    // call reset to start new game, and after return from SettingsVC (maxGuesses and/or numberHiddenColors changed)
    private func reset() {
        setGlobalData()
        mastermind = Mastermind(colorChoices: Constants.marbleColors, maxGuesses: maxGuesses, numberHidden: numberHiddenColors)  // generates new hiddenColors
        currentGuessColors = [UIColor](repeating: Constants.backgroundColor, count: numberHiddenColors)
        palletView.hiddenColors = mastermind.hiddenColors
        boardView.maxGuesses = maxGuesses
        boardView.numberHiddenColors = numberHiddenColors
        resultsView.maxGuesses = maxGuesses
        resultsView.numberHiddenColors = numberHiddenColors
        boardMarbleViews.values.forEach { $0.removeFromSuperview() }
        boardMarbleViews.removeAll()
        setResultsButtonOffset()
        isGameOver = false
        
        let hiddenColorNames = mastermind.hiddenColors.map { $0.name }
        print("hidden colors: \(hiddenColorNames)")
    }
    
    // MARK: - Pallet Marbles

    private func createPalletMarbleWith(color: UIColor) {
        let marbleView = MarbleView(color: color)  // frame and center will be set in viewDidLayoutSubviews

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanFromPallet))
        marbleView.addGestureRecognizer(pan)
        
        palletMarbleViews.append(marbleView)
        view.addSubview(marbleView)
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
                marbleView.layer.zPosition = 1
                if let holeIndex = nearbyHole(marbleView) {
                    // panned marble near hole - replace with board marble and update guess colors
                    currentGuessColors[holeIndex] = marbleView.color
                    updateViewFromModel()
                    // return marble to startPanPoint instantly, to allow re-use (isInHole stores the guess)  pws: move storing of guess here?
                    marbleView.center = self.startPalletPanPoint
                    // delete any existing marbleView at the destination hole
                    if let existingMarbleView = boardMarbleViews[holeIndex] {
                        existingMarbleView.removeFromSuperview()
                    }
                    createBoardMarbleWith(color: marbleView.color, at: holeIndex)
                    let colorsFilled = currentGuessColors.filter { $0 != Constants.backgroundColor }
                    showResultsButton.isHidden = colorsFilled.count != numberHiddenColors
                } else {
                    // panned marble missed hole - return marble to startPanPoint slowly
                    UIView.animate(withDuration: 0.3, animations: {  // move to pallet in 0.3 sec
                        marbleView.center = self.startPalletPanPoint
                    })
                }
            }
        }
    }
    
    // MARK: - Board Marbles
    
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
                marbleView.layer.zPosition = 1
                if let holeIndex = nearbyHole(marbleView) {
                    // center marbleView at holeIndex
                    let holePoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
                    marbleView.center = boardView.convert(holePoint, to: view)  // convert from boardView to view coords
                    currentGuessColors[holeIndex] = marbleView.color
                    updateViewFromModel()
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
                showResultsButton.isHidden = colorsFilled.count != numberHiddenColors
            }
        }
    }
    
    // MARK: - Utilities
    
    private func setResultsButtonOffset() {
        let holeCenterPoint = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: 0)
        resultsButtonOffset.constant = holeCenterPoint.y
    }

    private func nearbyHole(_ marbleView: MarbleView) -> Int? {
        for holeIndex in 0..<numberHiddenColors {
            let holeCenter = boardView.getHoleCenterPointFor(row: mastermind.guessNumber, col: holeIndex)
            let marblePoint = view.convert(marbleView.center, to: boardView)  // convert from view to boardView coords
            if marblePoint.distance(from: holeCenter) < 20 {
                return holeIndex
            }
        }
        return nil
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
        let result = mastermind.getResultFor(guess: currentGuessColors)
        let rightMarbles = result.filter { $0 == .rightColorRightPosition }
        if rightMarbles.count == numberHiddenColors {
            isSuccess = true
            isGameOver = true
        } else if mastermind.guessNumber == maxGuesses {
            isSuccess = false
            isGameOver = true
        } else {
            isGameOver = false  // triggers updateViewFromModel (needed since mastermind.allGuessColors changed)
        }
    }
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Show Settings" {
            if let svc = segue.destination as? SettingsViewController {
                svc.maxGuesses = maxGuesses
                svc.numberHiddenColors = numberHiddenColors
                // provide callback for settings change
                svc.updateSettings = { [weak self] in
                    self?.maxGuesses = svc.maxGuesses
                    self?.numberHiddenColors = svc.numberHiddenColors
                    self?.setUserDefaults()
                    self?.reset()
                }
            }
        }
    }
}

extension UIColor {
    static let names = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1): "black", #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1): "white", #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1): "red", #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1): "yellow", #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1): "green", #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1): "blue"]
    var name: String {
        UIColor.names[self] ?? "unk."
    }
}

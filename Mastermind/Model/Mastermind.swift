//
//  Mastermind.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//
//  Mastermind is generic for Color, so that it doesn't need to import UIKit.
//  Color is set to UIColor when declared in MastermindViewController.
//

import Foundation

enum Result: Int, CaseIterable {  // CaseIterable allows Result.allCases
    case rightColorRightPosition
    case rightColorWrongPosition
    case wrongColor
}

struct Mastermind<Color> where Color: Equatable {

    // read-only properties
    private(set) var hiddenColors = [Color]()  // these are the colors you're trying to guess
    private(set) var allGuessColors = [[Color]]()  // these are the past guesses, allGuessColors[row][position]
    private(set) var results = [[Result]]()  // these are the past results of each guess, results[row][position]
    var guessNumber: Int {
        return allGuessColors.count
    }

    private var colorChoices = [Color]()  // all available game colors
    private var maxGuesses = 0  // max guesses allowed
    private var numberHidden = 0  // number of hidden marbles

    init(colorChoices: [Color], maxGuesses: Int, numberHidden: Int) {
        self.colorChoices = colorChoices
        self.maxGuesses = maxGuesses
        self.numberHidden = numberHidden
        reset()
    }
    
    mutating func selectHiddenColors() {
        for _ in 0..<numberHidden {
            hiddenColors.append(colorChoices.randomElement()!)
        }
    }
    
    mutating func reset() {
        hiddenColors.removeAll()
        allGuessColors.removeAll()
        results.removeAll()
        selectHiddenColors()
    }
    
    mutating func getResultFor(guess: [Color]) -> [Result] {
        precondition(guess.count == hiddenColors.count, "Number of colors in guess must match number of hidden colors")
        allGuessColors.append(guess)
        var result = [Result]()
        var tempHidden = hiddenColors
        var tempGuess = guess
        for (index, aGuess) in tempGuess.enumerated().reversed() {
            if aGuess == tempHidden[index] {
                result.append(.rightColorRightPosition)
                tempGuess.remove(at: index)
                tempHidden.remove(at: index)
            }
        }
        for (iGuess, aGuess) in tempGuess.enumerated().reversed() {
            for (iHidden, aHidden) in tempHidden.enumerated() {
                if aGuess == aHidden {
                    result.append(.rightColorWrongPosition)
                    tempGuess.remove(at: iGuess)
                    tempHidden.remove(at: iHidden)
                    break
                }
            }
        }
        // pad the rest with .wrongColor
        for _ in result.count..<guess.count {
            result.append(.wrongColor)
        }
        results.append(result)
        return result
    }
}

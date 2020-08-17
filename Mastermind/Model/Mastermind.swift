//
//  Mastermind.swift
//  Mastermind
//
//  Created by Phil Stern on 8/15/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//

import Foundation

enum Result: Int, CaseIterable {  // CaseIterable allows Ressult.allCases
    case rightColorRightPosition
    case rightColorWrongPosition
    case wrongColor
}

struct Mastermind {

    // read-only properties
    private(set) var guessValues = [[Int]]()
    var guessNumber: Int {
        return guessValues.count
    }

    private var numberHidden = 0  // number of hidden marbles
    private var maxGuesses = 0  // max guesses allowed
    private var hiddenValues = [Int]()  // these are the color values you're trying to guess

    init(numberHidden: Int, maxGuesses: Int) {
        self.numberHidden = numberHidden
        self.maxGuesses = maxGuesses
        pickRandomValues()
    }
    
    mutating func pickRandomValues() {
        for _ in 0..<numberHidden {
            hiddenValues.append(Int.random(in: 0..<Constants.marbleColors.count))
        }
    }
    
    mutating func getResultsFor(guess: [Int]) -> [Result] {
        precondition(guess.count == hiddenValues.count, "Number of values in guess must match number of hidden values")
        guessValues.append(guess)
        var results = [Result]()
        var tempHidden = hiddenValues
        var tempGuess = guess
        for (index, aGuess) in tempGuess.enumerated().reversed() {
            if aGuess == tempHidden[index] {
                results.append(.rightColorRightPosition)
                tempGuess.remove(at: index)
                tempHidden.remove(at: index)
            }
        }
        for (iGuess, aGuess) in tempGuess.enumerated().reversed() {
            for (iHidden, aHidden) in tempHidden.enumerated() {
                if aGuess == aHidden {
                    results.append(.rightColorWrongPosition)
                    tempGuess.remove(at: iGuess)
                    tempHidden.remove(at: iHidden)
                    break
                }
            }
        }
        // pad the rest with .wrongColor
        for _ in results.count..<guess.count {
            results.append(.wrongColor)
        }
        return results
    }
}

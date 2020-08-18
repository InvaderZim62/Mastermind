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
    private(set) var allGuessValues = [[Int]]()
    private(set) var results = [[Result]]()  // results[row][position]
    var guessNumber: Int {
        return allGuessValues.count
    }

    private var numberHidden = 0  // number of hidden marbles
    private var maxGuesses = 0  // max guesses allowed
    private var hiddenValues = [Int]()  // these are the color values you're trying to guess

    init(numberHidden: Int, maxGuesses: Int) {
        self.numberHidden = numberHidden
        self.maxGuesses = maxGuesses
        reset()
    }
    
    mutating func selectHiddenValues() {
        for _ in 0..<numberHidden {
            hiddenValues.append(Int.random(in: 0..<Constants.marbleColors.count))
        }
    }
    
    mutating func reset() {
        allGuessValues.removeAll()
        results.removeAll()
        hiddenValues.removeAll()
        selectHiddenValues()
        print("hidden values: \(hiddenValues)")
    }
    
    mutating func getResultFor(guess: [Int]) -> [Result] {
        precondition(guess.count == hiddenValues.count, "Number of values in guess must match number of hidden values")
        allGuessValues.append(guess)
        var result = [Result]()
        var tempHidden = hiddenValues
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

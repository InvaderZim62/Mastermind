//
//  SettingsViewController.swift
//  Mastermind
//
//  Created by Phil Stern on 8/18/20.
//  Copyright © 2020 Phil Stern. All rights reserved.
//
//  Note: Set the button type to Custom in InterfaceBuilder, or the cog image will be solid blue.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var numberHiddenColors = 4
    var maxGuesses = 10
    
    var updateSettings: (() -> Void)?  // callback

    private let numberHiddenColorsChoices = ["3", "4", "5", "6"]
    private let maxGuessesChoices = ["5", "6", "7", "8", "9", "10", "11", "12"]

    @IBOutlet weak var numberHiddenPicker: UIPickerView!
    @IBOutlet weak var maxGuessesPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        numberHiddenPicker.delegate = self
        numberHiddenPicker.dataSource = self
        numberHiddenPicker.selectRow(numberHiddenColors - 3, inComponent: 0, animated: false)
        
        maxGuessesPicker.delegate = self
        maxGuessesPicker.dataSource = self
        maxGuessesPicker.selectRow(maxGuesses - 5, inComponent: 0, animated: false)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView == numberHiddenPicker ? numberHiddenColorsChoices.count : maxGuessesChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerView == numberHiddenPicker ? numberHiddenColorsChoices[row] : maxGuessesChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == numberHiddenPicker {
            numberHiddenColors = Int(numberHiddenColorsChoices[row])!
            updateSettings?()
        } else if pickerView == maxGuessesPicker {
            maxGuesses = Int(maxGuessesChoices[row])!
            updateSettings?()
        }
    }
    
    @IBAction func doneSelected(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
    }
}

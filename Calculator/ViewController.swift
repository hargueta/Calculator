//
//  ViewController.swift
//  Calculator
//
//  Created by Hugo Argueta on 8/28/16.
//  Copyright © 2016 Hugo Argueta. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var userHistory: UILabel!
    
    var brain = CalculatorBrain()
    
    var userIsInTheMiddleOfTypingANumber = false
    var didPerformOperation = false
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." {
                if !display.text!.containsString(".") {
                    display.text = display.text! + digit
                }
            } else {
                display.text = display.text! + digit
            }
        } else {
            if digit != "." {
            }
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    @IBAction func pi(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        displayValue = brain.pushConstant("π")
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            userHistory.text = userHistory.text! + " " + operation
            
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func setM(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        if displayValue != nil {
            brain.variableValues["M"] = displayValue!
        }
        
        displayValue = brain.evaluate()
    }
    
    @IBAction func getM(sender: UIButton) {
        if(userIsInTheMiddleOfTypingANumber) {
            enter()
        }
        
        displayValue = brain.pushOperand("M")
    }
    
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if !didPerformOperation {
            if let disValue = displayValue {
                userHistory.text = userHistory.text! + " " + "\(disValue)"
            }
            
        }
        
        if let disValue = displayValue {
            if let result = brain.pushOperand(disValue) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        
        set {
            if let disValue = newValue {
                display.text = "\(disValue)"
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = nil
            }
        }
    }
    
    @IBAction func clear() {
        brain.clearOpStack()
        display.text = "\(0)"
        userHistory.text = ""
        brain.variableValues.removeAll()
        userIsInTheMiddleOfTypingANumber = false
    }
}

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
    
    @IBAction func operate(sender: UIButton) {
//        let operation = sender.currentTitle!
        
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
        
        
        
//        switch operation {
//            case "✕": performOperation {$0 * $1}
//            case "÷": performOperation {$1 / $0}
//            case "+": performOperation {$0 + $1}
//            case "-": performOperation {$1 - $0}
//            case "√": performOperation {sqrt($0)}
//            case "sin": performOperation { sin($0) }
//            case "cos": performOperation { cos($0) }
//            case "π":
//                displayValue = M_PI
//                enter()
//            default:
//                break
//        }
    }
    
//    func performOperation(operation: (Double, Double) -> Double) {
//        if operandStack.count >= 2 {
//            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
//            didPerformOperation = true
//            enter()
//            didPerformOperation = false
//        }
//    }
//    
//    private func performOperation(operation: Double -> Double) {
//        if operandStack.count >= 1 {
//            displayValue = operation(operandStack.removeLast())
//            didPerformOperation = true
//            enter()
//            didPerformOperation = false
//        }
//    }
    
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
//        operandStack.append(displayValue)
        if !didPerformOperation {
            userHistory.text = userHistory.text! + " " + "\(displayValue)"
        }
        
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
//        print("Operand Stack = \(operandStack)")
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func clear() {
        operandStack.removeAll()
        display.text = "\(0)"
        userHistory.text = ""
        userIsInTheMiddleOfTypingANumber = false
    }
}

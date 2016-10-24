//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Hugo Argueta on 9/11/16.
//  Copyright © 2016 Hugo Argueta. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op : CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        case Constant(String, Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Variable(let symbol):
                    return "\(symbol)"
                case .Constant(let symbol, _):
                    return "\(symbol)"
                }
                
                
            }
        }
        
        var precedence: Int {
            switch self {
            case .Operand(_), .Variable(_), .Constant(_, _), .UnaryOperation(_, _):
                return Int.max
            case .BinaryOperation(_, _):
                return Int.min
            }
        }
    }
    
    
    
    private var opStack = [Op]()
    
    private var knownOps = Dictionary<String, Op>()
    
    var variableValues = Dictionary<String, Double>()
    
    var description: String {
        let (desc, _) = description([String](), ops: opStack)
        return desc.joinWithSeparator(", ")
    }
    
    init() {
        knownOps["✕"] = Op.BinaryOperation("✕", *)
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        knownOps["π"] = Op.Constant("π", M_PI)
    }
    
    var program: AnyObject { // guaranteed to be a PropertyList
        get {
            return opStack.map {$0.description}
        }
        
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops : [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .Variable(let variable):
                if let variableValue = variableValues[variable] {
                    return (variableValue, remainingOps)
                }
                
            case .Constant(_, let constantValue):
                return (constantValue, remainingOps)
            }
        }
        
        return (nil, ops)
    }
    
    private func description(desc: [String], ops: [Op]) -> (descriptionResult: [String], remainingOps: [Op]) {
        var descriptionResult = desc
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeFirst()
            switch op {
            case .UnaryOperation(let symbol, _):
                if !descriptionResult.isEmpty {
                    let unaryOperand = descriptionResult.removeLast()
                    descriptionResult.append(symbol + "(\(unaryOperand))")
                    let (newDescription, remainingOps) = description(descriptionResult, ops: remainingOps)
                    return (newDescription, remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                if !descriptionResult.isEmpty {
                    let lastBinOperand = descriptionResult.removeLast()
                    if !descriptionResult.isEmpty {
                        let binaryOperandFirst = descriptionResult.removeLast()
                        if op.description == remainingOps.first?.description || op.precedence == remainingOps.first?.precedence {
                            descriptionResult.append("(\(binaryOperandFirst)" + symbol + "\(lastBinOperand))")
                        } else {
                            descriptionResult.append("\(binaryOperandFirst)" + symbol + "\(lastBinOperand)")
                        }
                        return description(descriptionResult, ops: remainingOps)
                    } else {
                        descriptionResult.append("?" + symbol + "\(lastBinOperand)")
                        return description(descriptionResult, ops: remainingOps)
                    }
                } else {
                    descriptionResult.append("?" + symbol + "?")
                    return description(descriptionResult, ops: remainingOps)
                }
            case .Operand(_), .Variable(_), .Constant(_, _):
                descriptionResult.append(op.description)
                return description(descriptionResult, ops: remainingOps)
                
            }
        }
        return (descriptionResult, ops)
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        
        print("\(opStack) result: \(result)")
        
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    func pushConstant(symbol: String) -> Double? {
        if let constant = knownOps[symbol] {
            opStack.append(constant)
        }
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
    
    func clearOpStack() {
        opStack.removeAll()
    }
    
    func opStackLength() -> Int {
        return opStack.count
    }
}

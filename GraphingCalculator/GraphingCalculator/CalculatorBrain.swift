//
//  CalculatorBrain.swift
//  MyCalculator
//
//  Created by John Burgess on 4/22/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import Foundation

// CustomStringConvertible is a protocol that prints the "description"
// class CalculatorBrain, CustomStringConvertible () -- syntax error?
class CalculatorBrain
     // base class, for now; could inherit from Objext
{
    fileprivate enum Op: CustomStringConvertible {
        case operand(Double)
        case unaryOperation(String, (Double) -> Double)
        case binaryOperation(String, (Double, Double) -> Double)
        case constantOperation(String, Double)
        case variable(String)

        // for printing
        var description: String {
            get {
                switch self {
                case .operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                case .constantOperation(let symbol, _):
                    return symbol
                case .variable(let symbol):
                    return symbol
                }
            }
        }
    }
    fileprivate var opStack = [Op]()
    fileprivate var variableValues: Dictionary<String,Double> = [:]

    //var knownOps = Dictionary<String, Op>() -- not preferred syntax
    fileprivate var knownOps = [String: Op]()

    init() {
        func learnOp(_ op: Op) {
            knownOps[op.description] = op
        }
        // shorthand for 
        //  knownOps("+") = Op.BinaryOperation("+", { $1 + $0 } )
        learnOp ( Op.binaryOperation("+", { $1 + $0 } ) )
        learnOp ( Op.binaryOperation("-", { $1 - $0 } ) )
        learnOp ( Op.binaryOperation("×", { $1 * $0 } ) )
        learnOp ( Op.binaryOperation("÷", { $1 / $0 } ) )
        learnOp ( Op.binaryOperation("^", { pow($1, $0) } ) )

        // knownOps["√"] = Op.UnaryOperation("√", { sqrt($0) } ) )
        learnOp ( Op.unaryOperation("√", sqrt ) )
        learnOp ( Op.unaryOperation("1/", { 1/$0 } ) )
        learnOp ( Op.unaryOperation("sin", { sin($0) } ) )
        learnOp ( Op.unaryOperation("cos", { cos($0) } ) )

        learnOp ( Op.constantOperation("π", Double.pi ) )
        learnOp ( Op.constantOperation("e", M_E ) )
    }

    // internal recursive function to evaluate the stack
    fileprivate func evaluate (_ ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            //print ("EVAL op: \(op)")

            switch op {
            case .operand(let operand):
                return (operand, remainingOps)
            case .unaryOperation(_, let operation):
                // pop (evaluate) the next thing off the stack; it better be an operand.
                // then use it and return whats left
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    //print ("\(opName) on \(operand)")
                    return (operation(operand), operandEvaluation.remainingOps)
                } else {
                    print ("Unary Op eval(\(remainingOps)) returned NIL")
                }
            case .binaryOperation(_, let operation):
                // pop TWO operands off the stack and use both
                let operandEval1 = evaluate(remainingOps)
                if let opOne = operandEval1.result {
                    let operand2Eval = evaluate(operandEval1.remainingOps)
                    if let opTwo = operand2Eval.result {
                        return (operation(opOne, opTwo), operand2Eval.remainingOps)
                    } else {
                        print ("Binary Op2 eval(\(operandEval1.remainingOps)) returned NIL")
                    }
                } else {
                    print ("Binary Op1 eval(\(remainingOps)) returned NIL")
                }
            case .constantOperation(_, let operation):
                //pushOperand(operation)
                return (operation, remainingOps)
            case .variable(let symbol):
                return (variableValues[symbol], remainingOps)
            }
        }
        print ("Evaluate error, returning (nil, \(ops))")
        return (nil,ops)
    }

    // "evaluates" the stack, but returns a description, not the result
    fileprivate func describe (_ ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            //print ("EVAL op: \(op)")
            
            switch op {
            case .operand(let operand):
                return ("\(operand)", remainingOps)
            case .unaryOperation(let opName, _):
                // pop the next thing off the stack; it better be an operand.
                let operandEvaluation = describe(remainingOps)
                if var operand = operandEvaluation.result {
                    if !operand.hasPrefix("(") {
                        // if not already parenthesized, add them
                        operand = "(" + operand + ")"
                    }
                    return ("\(opName)\(operand)", operandEvaluation.remainingOps)
                }
            case .binaryOperation(let opName, _):
                // pop TWO operands off the stack and
                // describe them as the left and right sides of the operand
                let operandEval1 = describe(remainingOps)
                if let opOne = operandEval1.result {
                    let operand2Eval = describe(operandEval1.remainingOps)
                    if let opTwo = operand2Eval.result {
                        return ("(\(opTwo) \(opName) \(opOne))", operand2Eval.remainingOps)
                    }
                }
            case .constantOperation(let opName, _):
                //pushOperand(operation)
                return ("\(opName)", remainingOps)
            case .variable(let symbol):
                if let theValue = variableValues[symbol] {
                    return ("\(symbol)=\(theValue)", remainingOps)
                } else {
                    return  ("\(symbol)=NIL", remainingOps)
                }
            }
        }
        return ("NIL",ops)

    }

    //////////
    // external API
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        // don't replace : opStack = remainingOps
        print ("API evaluate \(opStack) = \(result) leaving \(remainder)")
        return result
    }

    func pushOperand(_ operand: Double) -> Double? {
        opStack.append(Op.operand(operand))
        // print ("push STACK: \(opStack)")
        return evaluate()
    }
    
    func pushOperand(_ symbol: String) -> Double? {
        opStack.append(Op.variable(symbol))
        print ("push symbol: \(symbol)")
        return evaluate()
    }
 
    func setVariable(_ symbol: String, value: Double?) {
        if value == nil {
            variableValues.removeValue(forKey: symbol)
        } else {
            variableValues[symbol] = value
        }

        print ("Set variable '\(symbol)' = \(String(describing: value))")
    }

    func performOperation(_ symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        } else {
            print ("Unknown Operation: \(symbol)")
            return nil
        }
        return evaluate()
        
    }
    
    func popStack() {
        opStack.removeLast()
    }

    func clear() {
        opStack = [Op]()
    }

    var description: String {
        get {
            var result: String?
            var fullDescr = ""
            var remainder = opStack
            while !remainder.isEmpty {
                (result, remainder) = describe(remainder)
                //print ("describe \(result) = result leaving \(remainder)")
                if fullDescr == "" {
                    // first time, no ',' join
                    fullDescr = result!
                } else if let actResult = result {
                    fullDescr = actResult + ", " + fullDescr
                } else {
                    fullDescr = "nil, " + fullDescr
                }
            }
            if fullDescr.hasPrefix("(") {
                // surely there's a simpler way to get the substring[1...strlen-1]
                return String(fullDescr.characters.dropFirst().dropLast())
            } else {
                return fullDescr
            }
        }
    }
}

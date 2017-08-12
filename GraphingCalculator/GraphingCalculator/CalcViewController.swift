//
//  ViewController.swift
//  MyCalculator
//
//  Created by John Burgess on 1/30/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import Foundation

class CalcViewController: UIViewController {
    
    @IBOutlet weak var paperTape: UITextView!
    @IBOutlet weak var display: UILabel! // aka accumulator, as optional string
    @IBOutlet weak var formula: UILabel!
    var userIsTypingANumber = false

    var brain = CalculatorBrain()

    @IBAction func appendDigit(_ sender: UIButton) {
        // use ! to "unwrap Optional (?)"
        let digit = sender.currentTitle!
        if userIsTypingANumber {
            if digit == "." && (display.text!.range(of: ".") != nil) {
                print ("ERROR '.' entered twice")
                return
            } else {
                display.text = display.text! + digit
            }
        } else {
            userIsTypingANumber = true
            display.text = digit
        }
        
        //print ("digit = \(digit)")
    }
  
    @IBAction func EnterKey() {
        userIsTypingANumber = false
        if displayValue == nil {
            // do nothing if the display is empty
        } else if let result = brain.pushOperand(displayValue!) {
            displayValue = result
            addToHistory("Enter: \(display.text!)")
        } else {
            displayValue = nil
            addToHistory("pushOp returned NIL!?")
        }
    }

    @IBAction func pushVariable(_ sender: UIButton) {
        addToHistory("Push variable on stack")
        _ = brain.pushOperand(sender.currentTitle!)
        formula.text = brain.description
    }

    @IBAction func clearAll() {
        ClearDisplay()

        brain.clear()
        print ("stack cleared")
        addToHistory("-- clear brain --")
    }
    @IBAction func ClearDisplay() {
        displayValue = nil
        addToHistory("-- clear --")
    }
    
    
    @IBAction func PerformArithmetic(_ sender: UIButton) {
        let operation = sender.currentTitle!
        if (userIsTypingANumber) {
            EnterKey()
        }
        print ("perform \(operation) on \(String(describing: display.text ?? nil))")
        if let result = brain.performOperation(operation) {
            displayValue = result
            addToHistory("\(operation) result: \(display.text!)")
        } else {
            displayValue = nil
            addToHistory("evaluate \(operation) returned NIL!?")
            //brain.popStack()
        }
        print (brain.description)
    }

    @IBAction func setM(_ sender: UIButton) {
        if let theValue = displayValue {
            brain.setVariable("M", value: theValue)
            addToHistory("set M = \(String(describing: displayValue ?? nil))")
        } else {
            brain.setVariable("M", value: nil)
            addToHistory("set M = NIL")
        }
        if let result = brain.evaluate() {
            displayValue = result
            addToHistory("new result: \(display.text!)")
        } else {
            displayValue = nil
            addToHistory("evaluate returned NIL!?")
            //brain.popStack()
        }
        formula.text = brain.description
    }

    var displayValue : Double? {
        get {
            if let dispText = display.text {
                return NumberFormatter().number(from: dispText)!.doubleValue
            } else {
                return nil
            }
        }
        set {
            formula.text = brain.description
            if let newVal = newValue {
                display.text = "\(newVal)"
            } else {
                display.text = nil
            }
            userIsTypingANumber = false
        }
    }
    
    func addToHistory(_ theEntry : String) {
        print (theEntry)
        if paperTape.text == nil {
            paperTape.text! = theEntry+"\n"
        } else {
            paperTape.text! = theEntry+"\n" + paperTape.text!
        }
    }
}

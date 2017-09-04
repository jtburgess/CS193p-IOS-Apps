//
//  ViewController.swift
//  MyCalculator
//
//  Created by John Burgess on 1/30/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import Foundation

class CalcViewController: UIViewController,UISplitViewControllerDelegate {
    
    @IBOutlet weak var paperTape: UITextView!
    @IBOutlet weak var display: UILabel! // aka accumulator, as optional string
    @IBOutlet weak var formula: UILabel!
    var userIsTypingANumber = false

    var brain = CalculatorBrain()

    // MARK UI functions
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
        displayValue = nil

        brain.clear()
        print ("stack cleared")
        addToHistory("-- clear brain --")
        EnterKey()
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
        reDisplay()
    }

    @IBAction func UnDo(_ sender: UIButton) {
        if userIsTypingANumber {
            if let dispText = display.text {
                if strlen(dispText) <= 1 {
                    display.text = nil
                    userIsTypingANumber = false
                } else {
                    display.text = String(dispText.characters.dropLast())
                }
            } else {
                print ("HUH? display.text is not set while userIsTyping?")
            }
        } else {
            brain.popStack()
            reDisplay()
        }
    }

    // MARK internals
    fileprivate func reDisplay() {
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

    fileprivate var displayValue : Double? {
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
    
    fileprivate func addToHistory(_ theEntry : String) {
        print (theEntry)
        if paperTape.text == nil {
            paperTape.text! = theEntry+"\n"
        } else {
            paperTape.text! = theEntry+"\n" + paperTape.text!
        }
    }
    
    // MARK: - Navigation
    
    override func awakeFromNib() {
        // first make me the delegate, then see below
        // this makes THIS view the first one you see
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    // function passed to the grapher
    func evalMorZero (x: Double) -> Double {
        // print ("evalMOrZero (\(x))")
        brain.setVariable("M", value: x)
        if let eValue = brain.evaluate() {
            return eValue
        } else {
            return 0.0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print ("Calc-to-graph  VC segue; id=\(segue.identifier!)")
        if let graphVC = segue.destination.contents as? GraphViewController {
            graphVC.title = brain.description
            graphVC.myFunction = evalMorZero
            print ("set to graph: <\(brain.description)>")
        } else {
            print ("Segue Calc NOT to GraphViewController")
        }
    }
}

// clever way to automatically get the actual visible view controller when embedded in a Nav VC
extension UIViewController
{
    var contents: UIViewController {
        get {
            if let navCon = self as? UINavigationController {
                return navCon.visibleViewController ?? self
            } else {
                return self
            }
        }
    }
}

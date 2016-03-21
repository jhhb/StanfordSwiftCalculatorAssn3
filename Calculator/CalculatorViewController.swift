//
//  ViewController.swift
//  Calculator
//
//  Created by James Boyle on 1/28/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//

/*

The following code is working and follows all of the specifications, though I'm 
going to think of how I can make it more modular and so there is as little code as possible.
*/

import UIKit

class CalculatorViewController: UIViewController {
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        var destination = segue.destinationViewController as? UIViewController
        
        if let navCon = destination as? UINavigationController{
            destination = navCon.visibleViewController
        }
        if let destinationVC = destination as? CalculatorGraphViewController {
            destinationVC.programVarFromVC = brain.program as? NSArray
        }
    }


    
    
/*
Defines labels, global vars, Model
*/
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var display: UILabel!
    var userIsInTheMiddleOfTypingANumber = false
    var brain = CalculatorBrain()
    
/*
Parameters: sender from "C" UIButton

Description: Functions resets labels, clears brain.stack,
             resets calculator to original state
*/
    @IBAction func clearButton(sender: UIButton) {
        displayValue = 0
        brain.clearStack()
        brain.emptyVariableValuesDictionary()
        userIsInTheMiddleOfTypingANumber = false
        descriptionLabel.text = "="
    }
    
/*
Parameters: sender from any digit UIButton, 0-9 and .

Description: This function changes display.text and the historyLabel text depending
             upon the input.
    
             This function also handles special cases like entering multiple "."s, multiple "0"s,
             and treats entering "π" as a special case.
    
             This function handles different cases if the userIsInTheMiddleOfTypingANumber is true or false.
*/
    @IBAction func digitPressed(sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
//prevents IP addresses
                if digit == "." && display.text!.rangeOfString(".") != nil {
                    display.text = display.text!
                }
                else if digit == "0" && display.text! == "0" {
                    display.text = "0"
                }
                else if digit == "π"{
                    display.text = String(M_PI)
                    userIsInTheMiddleOfTypingANumber = false
                }
                else{
                    display.text = display.text! + digit
                }
        }
        else{
            switch digit{
                case "π":
                    display.text = String(M_PI)
                    userIsInTheMiddleOfTypingANumber = true

                default:
                    display.text = digit
                    userIsInTheMiddleOfTypingANumber = true
            }
        }
    }

/*
Description: this function assigns the displayValue to the m variable (if it is not nil)


*/
    @IBAction func setM(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        
        if let mValue = displayValue {
            brain.setVariable("M", value: mValue)
        }
        if let z = brain.evaluate(){
            displayValue = z
            descriptionLabel.text! = "= \(brain.description)"
        }
    }

    
/*Description: getM simply pushes an M variable onto the stack */
    @IBAction func getM(sender: UIButton) {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand("M"){
            displayValue = result
        }
    }

/*
Parameters: void / None, but gets called when pressing "⏎",
    
Description: This function is called when calling operate and also when
             typing pi. This function pushes the display value onto the stack,
             and evaluates the stack and changes the Label text.

*/
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        
        if let _ = displayValue {
            
            if let result = brain.pushOperand(displayValue!){
                displayValue = result
            }
        }
    }
    
/*
Parameters: sender: UIButton (+, -, division, multiplication, sqrt, cos, sin)
    
Description: This function is called when you click an operator button and also
             operates on the operand(s) from the stack with the given operator and
             changes the displayValue with the result.
            
            If there is nothing in the stick, displayValue is 0.
*/
    @IBAction func operate(sender: UIButton) {
                
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation){
                displayValue = result
                descriptionLabel.text! = "= \(brain.description)"
            }
            else{
                displayValue = nil
                descriptionLabel.text! = "= \(brain.description)"
            }
        }
    }
    
/*
Defines displayValue as an optional double; the get method return the string to double? of the display.text
    
The set sets the display.text to the newValue
*/
    var displayValue: Double? {
        get {
            if let _ = NSNumberFormatter().numberFromString(display.text!){
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
            else{
                return nil
            }
        }
        set{
            if let z = newValue{
                display.text = "\(z)"
            }
            else{
                display.text = " "
            }
        }
    }
}


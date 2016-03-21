//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by James Boyle on 2/2/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//
import Foundation

class CalculatorBrain
{
    
//Stack of operands and operations
    private var opStack = [Op]()
    
//Dictionary mapping String to type Op
    private var knownOps = [String:Op]()

//Dictionary mapping a variable to its value
    private var variableValues =  Dictionary<String,Double>()

//Dictionary mapping M_PI to pi string
    private var constantValues: Dictionary<String, String> = [
        "\(M_PI)": "π"
    ]
    
    var program: AnyObject { //guaranteed to be a PropertyList
        get {
            let z = opStack.map{ $0.description}
            print(description)
            return z  //gives an array of string
            
        }
        set{
            print("k")
            if let opSymbols = newValue as? Array<String> { // as? typecasts?
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                        print("new: \(newOpStack)")
                        //IF you want these to actually go on the stack (assn 3) then
                        //add them to stack, check if stack is empty, etc.
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                    else {
                        newOpStack.append(.Variable(opSymbol))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
/*
Defines Op to be an enumerated type and adopts CustomStringConvertible protocol for debugging

Defines an Operand, UnaryOperation, Variable, and BinaryOperation case for the enum Op.
*/
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Variable(String)
        
        var description: String {
            get {
                switch self{
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol,_):
                    return symbol
                case .Variable(let variable):
                    return variable
                }
            }
        }
    }
    
//Initializes the knownOps dictionary
    init(){
        func learnOp(op: Op){
            knownOps[op.description] = op
        }
       // learnOp(Op.BinaryOperation("x", *))
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin", sin)
        knownOps["cos"] = Op.UnaryOperation("cos", cos)
        //ALl these can be replaced by learnOp calls
    }
    
    
/*
Parameters: takes stack of Ops [Op]

Description: recursively evaluates the stack per postfix notation, depending upon the operands.
             Function has different cases for unary operations, binary operations, and operands,
             and returns a tuple of Double? and stack of Ops, remainingOps[]

             When there is nothing to evaluate it returns (nil, ops) as a tuple.
*/
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if let _ = variableValues[variable]{
                    return (variableValues[variable], remainingOps)
                }
                return (nil, ops)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result{
                    let operandEvaluation2 = evaluate(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        return (operation(operand, operand2), operandEvaluation2.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }

/*
Parameters: takes a stack of Ops and returns a tuple of string, remainingOps
    
Description: This function is basically like the above, except it never calls evaluate, and it returns strings to itself
             to build an expression while it evaluates.
*/
    private func describe(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                if constantValues[String(operand)] != nil{
                    return (constantValues[String(operand)]!, remainingOps)
                }
                return ("\(operand)", remainingOps)
            case .Variable(let variable):
                return(variable, remainingOps)
            case .UnaryOperation(let operatorStr, _):
                let operandEvaluation = describe(remainingOps)
                if var operand = operandEvaluation.result {
                    if constantValues[operand] != nil{
                        operand = constantValues[operand]!
                    }
                    return (operatorStr + "(" + operand + ")", operandEvaluation.remainingOps)
                }
            case .BinaryOperation(let operatorStr, _):
                let operandEvaluation = describe(remainingOps)
                if var operand = operandEvaluation.result{
                    if constantValues[operand] != nil{
                        operand = constantValues[operand]!
                    }
                    let operandEvaluation2 = describe(operandEvaluation.remainingOps)
                    if let operand2 = operandEvaluation2.result {
                        if constantValues[operand] != nil{
                            operand = constantValues[operand]!
                        }
                        return ("(" + operand2 + operatorStr + operand + ")", operandEvaluation2.remainingOps)
                    }
                }
            }
        }
        return ("?", ops)
    }

//Wrapper function that returns an optional double from evaluate(opStack)
    func evaluate() -> Double? {
        let (result,_) = evaluate(opStack)
        return result
    }

    
/*
Description: description var goes through the opStack, collects all expressions, and returns them in a string.
*/
    var description: String {
        get {
            var ops = opStack
            var desc = ""
            while !ops.isEmpty {
                let z = describe(ops)
                desc = z.result! + ", " + desc
                ops = z.remainingOps
            }
            return desc
        }
    }
    
/*
Parameters: takes an operand (Double)
    
Description: appends the operand into the opStack and returns the value of evaluate()
*/
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
/*
Description: pushes a variable onto the stack and returns evaluate
*/
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
/* Description: sets the value of the X variable in the variableValues dictionary */
    func setVariable(symbol: String, value: Double){
        variableValues[symbol] = value
    }

//Clears the stack and gets called in the viewController when the "C" button is pressed
    func clearStack(){
        opStack.removeAll()
    }
    
    
//Appends an operation to the stack and returns the evaluation of the stack
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
//used for debugging
    func printopStack(){
        print(opStack)
    }
    
/* Description: empties the variableValues dictionary when user press "C" */
    func emptyVariableValuesDictionary() {
        variableValues.removeAll()
    }
    
}
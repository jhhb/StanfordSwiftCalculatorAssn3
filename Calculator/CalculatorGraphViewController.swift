//
//  CalculatorGraph.swift
//  Calculator
//
//  Created by James Boyle on 3/6/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//

import UIKit
import Foundation

class CalculatorGraphViewController: UIViewController, GraphViewDataSource {
    
    var programVarFromVC : NSArray?
        {
        didSet
        {   print("\(programVarFromVC)")
            print(programVarFromVC)
        }
    }
    
    
    var stuff: Int = 75 {
        didSet {
            stuff = min(max(stuff, 0), 100)
            print("Stuff = \(stuff)")
            updateUI()
        }
        
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet{
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scale:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "pan:"))
            var twoTap: UITapGestureRecognizer = UITapGestureRecognizer(target: graphView, action: "tap:")
            graphView.addGestureRecognizer(twoTap)
            twoTap.numberOfTapsRequired = 2
            
            //action must be non private method in faceView
        }
    
    }
    
    
    
    private func updateUI(){
        graphView.setNeedsDisplay()
    }
    
    func stuffForGraphView(sender: GraphView) -> Double? {
        return Double(stuff-50)/50
    }
    
}
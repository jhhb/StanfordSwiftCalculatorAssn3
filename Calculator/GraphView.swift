//
//  GraphView.swift
//  Calculator
//
//  Created by James Boyle on 3/10/16.
//  Copyright © 2016 James Boyle. All rights reserved.
//

import UIKit

//could be Delegate but when the only purpose is for passing some data we use DataSource
protocol GraphViewDataSource: class {
    func stuffForGraphView(sender: GraphView) -> Double?
    
}

@IBDesignable
class GraphView: UIView
{

    
    weak var dataSource: GraphViewDataSource? //optional because we dont need it we can just have a normal axis
    
    var axesDrawer = AxesDrawer()
    
    var dx : CGFloat = 0
    var dy : CGFloat = 0
    
    var changed = false
    @IBInspectable var scale: CGFloat = 4 { didSet { setNeedsDisplay() } }

    var origin = CGPoint() { didSet {setNeedsDisplay() }  }
    
    override func drawRect(let rect: CGRect){
        let screenWidth = rect.size.width
        let screenHeight = rect.size.height
        
        if changed == false {
            origin = CGPoint(x:(screenWidth) / 2 + dx, y:screenHeight / 2 + dy)
        }
        else{
            origin = CGPoint(x: origin.x + dx, y: origin.y + dy)
            dx = 0
            dy = 0
        }
        
        let pointsPerUnit = CGFloat(10)
        
        let scaledPointsPerUnit = pointsPerUnit * scale
        
        axesDrawer.drawAxesInRect(rect, origin: origin, pointsPerUnit: scaledPointsPerUnit)
        
        //gets stuff from datasource by calling the method in the protocol
      //  let stuff = dataSource?.stuffForGraphView(self) ?? 0.0 //if nill use 0.0
    }
    
    func scale(gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    func tap(gesture: UITapGestureRecognizer){
        switch gesture.state {
        case .Ended:
            changed = true
            origin = gesture.locationInView(self)
        default:
            break
        }
    }

    func pan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
            case .Ended: fallthrough
            case .Changed:
                if let view = gesture.view{
                    let translation = gesture.translationInView(view)
                    //view.center = CGPoint(x:view.center.x + translation.x, y: view.center.y + translation.y)
                    dx += translation.x
                    dy += translation.y
                    gesture.setTranslation(CGPointZero, inView: view)
                    setNeedsDisplay()
                    
                }
            default: break
        }
    }
}

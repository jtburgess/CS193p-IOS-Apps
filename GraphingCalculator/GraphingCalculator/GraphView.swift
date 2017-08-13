//
//  GraphView.swift
//  GraphView
//
//  Created by John Burgess on 7/17/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit

// the protocol operates in the natural dimensions of the function
// the UIView converts to display coordinates

struct myXrange {
    var minX: CGFloat
    var maxX: CGFloat
}
func sampleFunction ( x:Double ) -> Double {
    return cos(x)
}

//@IBDesignable // this means Xocde will run this and show you the results in development
class graphView: UIView
{
    // MARK public API
    // note variables MUST have default values or you need a whole set if init() functions
    var theRange: myXrange = myXrange(minX: 0.0, maxX: 2.0)
    { didSet { print ("set theRange=\(theRange)"); setNeedsDisplay() } }
    var theFunction: (_ x: Double) -> Double = sampleFunction
        { didSet { setNeedsDisplay() } }
    //let pixelConversion: CGFloat = 50.0

    
    // MARK private

    // MARK: iOS Drawing Method
    
    // compute where the X = 0 goes
    // Y = 0 is always the middle
    override func draw(_ rect: CGRect)
    {
        var axes = AxesDrawer (color: UIColor.black, contentScaleFactor: 1)
        let xIncrement: CGFloat = (theRange.maxX - theRange.minX) /
            (self.bounds.width)
        let scaleToView: CGFloat = 1.0 / xIncrement
        // where across the X axis is "0.0"?
        let zeroXOffset = max(0.0, (-theRange.minX) * scaleToView)
        
        func convertToView (x: CGFloat, y: CGFloat) -> CGPoint {
            let drawX : CGFloat = zeroXOffset + x * scaleToView
            let drawY : CGFloat = bounds.midY - y * scaleToView
            // print ("draw x=\(x) @ \(drawX), y=\(y) @ \(drawY)")
            return (CGPoint (x: drawX, y: drawY))
        }

        print ("graphView Draw, xIncr=\(xIncrement), zeroXOffset=\(zeroXOffset), scaleToView=\(scaleToView)")
        UIColor.white.setFill()
        
        // coordinates in MY geometry
        print ("My bounds=\(self.bounds)")
        // coordinates in my superView's coordinates
        // (same, since the dimensions must be in pixels, which means I can't use bounds in the function space)
        //print ("My frame=\(self.frame)")
        
        axes.drawAxes(in: self.bounds,
                      origin: convertToView(x: 0.0, y: 0.0),
                      pointsPerUnit:  scaleToView)
        
        // now draw the function
        var x: CGFloat = theRange.minX
        var y: CGFloat = CGFloat( theFunction(Double(x)) )
        let path = UIBezierPath()
        path.lineWidth = 1.0
        UIColor.blue.setFill()
        path.move(to: convertToView (x:x, y:y))
        while x < theRange.maxX {
            x += xIncrement
            y = CGFloat( theFunction(Double(x)) )
            path.addLine(to: convertToView (x:x, y:y))
            path.stroke()
            
        }
    }
}

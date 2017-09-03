//
//  GraphView.swift
//  GraphView
//
//  Created by John Burgess on 7/17/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

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
    var theFunction: (_ x: Double) -> Double = sampleFunction
        { didSet { setNeedsDisplay() } }
    //let pixelConversion: CGFloat = 50.0

    // MARK private
    // note variables MUST have default values OR you need a whole set of init() functions
    private var theRange: myXrange = myXrange(minX: -5.0, maxX: 5.0)
    { didSet { print ("set theRange=\(theRange)"); setNeedsDisplay() } }
    private var theZeroPoint: CGPoint? = nil // initialize when first drawn
    { didSet { print ("set zeroPoint=\(String(describing: theZeroPoint))"); setNeedsDisplay() } }
    
    private let nearEnough: CGFloat = 50.0

    // MARK: iOS Drawing Method
    
    // compute where the X = 0 goes
    // Y = 0 is always the middle
    override func draw(_ rect: CGRect)
    {
        var axes = AxesDrawer (color: UIColor.black, contentScaleFactor: 1)
        let xIncrement: CGFloat = (theRange.maxX - theRange.minX) /
            (self.bounds.width)
        let scaleToView: CGFloat = 1.0 / xIncrement
        let zeroPoint = getZeroPoint()
        
        func convertToView (x: CGFloat, y: CGFloat) -> CGPoint {
            let drawX : CGFloat = zeroPoint.x + x * scaleToView
            let drawY : CGFloat = zeroPoint.y - y * scaleToView
            //print ("draw x=\(x) @ \(drawX), y=\(y) @ \(drawY)")
            return (CGPoint (x: drawX, y: drawY))
        }

        print ("graphView Draw, xIncr=\(xIncrement), zero @ \(zeroPoint), scaleToView=\(scaleToView)")
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
        print ("Draw starting @ (\(x), \(y))")
        path.lineWidth = 1.0
        UIColor.blue.setFill()
        path.move(to: convertToView (x:x, y:y))
        while x < theRange.maxX {
            x += xIncrement
            y = CGFloat( theFunction(Double(x)) )
            path.addLine(to: convertToView (x:x, y:y))
            path.stroke()
        }
        print ("Draw ending @ (\(x), \(y))")
    }
    
    // MARK Helper methods
    func getZeroPoint () -> CGPoint {
        if let zeroPoint = theZeroPoint {
            return zeroPoint
        } else {
            return CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
    }
    
    var aroundZero : CGRect {
        get {
            let zeroPoint = getZeroPoint()
            return CGRect(x: zeroPoint.x - nearEnough, y: zeroPoint.y - nearEnough, width: nearEnough*2.0, height: nearEnough*2.0 )
        }
    }

    // MARK: Gesture Handlers -- linked from definition in FaceViewController
    // PINCH gesture handler which scales the graph
    func changeScale(_ recognizer: UIPinchGestureRecognizer)
    {
        switch recognizer.state {
        case .changed,.ended:
            theRange.minX *= recognizer.scale
            theRange.maxX *= recognizer.scale
            // change theYzero??
            recognizer.scale = 1.0
        default:
            break
        }
    }
    
    // the pan gesture recognizer; moves the (0,0) point
    // you must click in close proximity to it.
    // Obviously, this will not allow Zero to me moved off screen
    // I have redundant code to set the ZeroPoint
    // but I can't initialize except as a '?'.  How can I get around this?
    
    func moveZero(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if aroundZero.contains (recognizer.location(in: self)) {
                // OK to continue
            } else {
                print ("PAN too far from Zero: \(recognizer.location(in: self)); zero @ \(getZeroPoint())")
                recognizer.state = .failed
            }
        case .changed,.ended:
            let scaleFromView = (theRange.maxX - theRange.minX) /
                (self.bounds.width)
            let newX = recognizer.location(in: self).x
            let xDelta = (getZeroPoint().x - newX) * scaleFromView
            print ("sFV=\(scaleFromView), newX=\(newX), xDelta=\(xDelta)")
            theZeroPoint = recognizer.location(in: self)
            theRange.minX += xDelta
            theRange.maxX += xDelta
        default:
            break
        }
    }
}

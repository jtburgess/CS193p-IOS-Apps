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
protocol GraphFunctionDelegate: class {
    var myRange: Range<Int> { get set }
    func theFunction (x: Double) -> Double
}

//@IBDesignable // this means Xocde will run this and show you the results in development
class graphView: UIView
{
    // MARK public API
    weak var delegate : GraphFunctionDelegate?

    // MARK private
    fileprivate var axes = AxesDrawer (color: UIColor.black, contentScaleFactor: 1.0)
    { didSet { setNeedsDisplay() } }

    // MARK: iOS Drawing Method
    override func draw(_ rect: CGRect)
    {
        let zeroPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        print ("graphView Draw, origin=\(zeroPoint)")
        UIColor.white.setFill()
        axes.drawAxes(in: self.bounds,
                      origin: zeroPoint,
                      pointsPerUnit: 50.0)
    }
}

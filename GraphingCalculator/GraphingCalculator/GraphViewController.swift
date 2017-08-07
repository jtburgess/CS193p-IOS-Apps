//
//  ViewController.swift
//  GraphView VIEWController
//
//  Created by John Burgess on 7/17/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController {

    var myRange = myXrange( minX: -2.0, maxX: CGFloat(3.0 * Double.pi)
    )
    func myFunction ( x:Double ) -> Double {
        return cos(x)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("GVC viewWillAppear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var graphView: graphView! {
        didSet {
            print ("GVC graphView didSet delegate")
            graphView.theRange = myRange
            graphView.theFunction = myFunction
        }
    }

}


//
//  ViewController.swift
//  GraphView VIEWController
//
//  Created by John Burgess on 7/17/17.
//  Copyright © 2017 JTBURGESS. All rights reserved.
//

import UIKit


class GraphViewController: UIViewController, GraphFunctionDelegate {

    var myRange = Range( 0...7 )
    func theFunction ( x:Double ) -> Double {
        return sin(x)
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
            graphView.delegate = self
        }
    }

}


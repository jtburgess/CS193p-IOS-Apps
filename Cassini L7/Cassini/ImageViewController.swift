//
//  ImageViewController.swift
//  Cassini
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate
{
    // MARK: Model
    var imageURL: URL? {
        didSet {
            image = nil
            print ("imageURL was set to \(String(describing: imageURL))")
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    // MARK: Implementation
    fileprivate func fetchImage() {
        if let url = imageURL {
            if let imageData = try? Data(contentsOf: url) {
                print ("fetchImage")
                image = UIImage(data: imageData)
            } else {
                print ("fetch image failed") //\(url)
            }
        } else {
            print ("attempt to fetch NIL image")
        }
    }
    
    fileprivate var imageView = UIImageView()
    
    fileprivate var image: UIImage? {
        get {
            print ("get image")
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            if self.image  == nil {
                print ("set image to nil")
            } else {
                print ("set image; size \(imageView.frame.size)")
            }
        }
    }
    
    // MARK: VC LifeCycle
    override func viewDidLoad() {
        print ("viewDidLoad")
        super.viewDidLoad()
        // (doesnt work) imageURL = URL(string: DemoURL.Stanford)
        imageURL = URL(string: DemoURL.SF)
        //imageURL = DemoURL.NASAImageNamed("Cassini")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print ("viewWillAppear")
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    
    // MARK: Scroll View
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            print ("didSet scrollView")
            // note need to set UIScrollViewDelegate protocol on class declaration
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.05
            scrollView.maximumZoomScale = 1.5
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

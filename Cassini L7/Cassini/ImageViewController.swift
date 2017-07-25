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
    var imageURL: String? {
        didSet {
            image = nil
            print ("imageURL was set to \(String(describing: imageURL))")
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: Implementation
    fileprivate func fetchImage() {
        if let url =  imageURL {
            // fetch the image in a separate thread, notify the main thread when done
            spinner.startAnimating()
            print ("fetch start")
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: URL(string:url)!)
                if let imageData = urlContents, url == self?.imageURL {
                    DispatchQueue.main.async {
                        print ("fetch complete")
                        self?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            print ("attempt to fetch NIL image")
        }
    }
    
    fileprivate var imageView = UIImageView()
    
    fileprivate var image: UIImage? {
        get {
            print ("get image")
            return imageView.image ?? nil
        }
        set {
            imageView.image = newValue
            if newValue == nil {
                print ("set image to nil")
            } else {
                imageView.sizeToFit()
                scrollView?.contentSize = imageView.frame.size
                print ("set image; size \(imageView.frame.size)")
                spinner?.stopAnimating()
            }
        }
    }
    
    // MARK: VC LifeCycle
    override func viewDidLoad() {
        print ("viewDidLoad")
        super.viewDidLoad()
        // (doesnt work) imageURL = URL(string: DemoURL.Stanford)
        // (Used before image selection) imageURL = URL(string: DemoURL.SF)
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

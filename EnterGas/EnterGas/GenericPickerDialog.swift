//
//  GenericPickerDialog.swift
//  EnterGas
//
//  Created by John Burgess on 2/11/18.
//  Copyright © 2018 JTBURGESS. All rights reserved.
//

/*
 creates a pop-up Generic picker dialog when the show() function is called.
 Set the text field value in the return { closure }
 */
import Foundation
import UIKit

private extension Selector {
    static let buttonTapped = #selector(GenericPickerDialog.buttonTapped)
}

open class GenericPickerDialog: UIView {
    public typealias GenericPickerCallback = ( Int? ) -> Void
    
    // MARK: - Constants
    private let kDefaultButtonHeight: CGFloat = 50
    private let kDefaultButtonSpacerHeight: CGFloat = 1
    private let kCornerRadius: CGFloat = 7
    private let kDoneButtonTag: Int     = 1
    
    // MARK: - Views
    private var dialogView: UIView!
    private var titleLabel: UILabel!
    open var pickerView: UIPickerView!
    private var cancelButton: UIButton!
    private var doneButton: UIButton!
    
    // MARK: - Variables
    private var value: String?
    private var callback: GenericPickerCallback?
    var locale: Locale?
    
    private var textColor: UIColor!
    private var buttonColor: UIColor!
    private var font: UIFont!
    
    // MARK: - Dialog initialization
    public convenience init ( pickerView: UIPickerView) {
        print ("convenience init called")
        self.init()
        self.pickerView = pickerView
        setupView()
    }
    public init(textColor: UIColor = UIColor.black,
                buttonColor: UIColor = UIColor.blue,
                font: UIFont = .boldSystemFont(ofSize: 15),
                locale: Locale? = nil,
                showCancelButton: Bool = true) {
        let size = UIScreen.main.bounds.size
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.textColor = textColor
        self.buttonColor = buttonColor
        self.font = font
        self.locale = locale
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupView() {
        print ("GenericPicker setupView called")
        self.dialogView = createContainerView()
        
        self.dialogView!.layer.shouldRasterize = true
        self.dialogView!.layer.rasterizationScale = UIScreen.main.scale
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self.dialogView!.layer.opacity = 0.5
        self.dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        self.addSubview(self.dialogView!)
    }
    
    
    /// Create the dialog view, and animate opening the dialog
    open func show( startValue: String,
                    title: String,
                    callback: @escaping GenericPickerCallback) {
        print ("Generic Picker called with start value \(startValue)")
        self.titleLabel.text = title
        self.doneButton.setTitle("Done", for: .normal)
        self.cancelButton.setTitle("Cancel", for: .normal)
        
        self.callback = callback
        self.value = startValue

        /* Add dialog to main window */
        guard let appDelegate = UIApplication.shared.delegate else { fatalError() }
        guard let window = appDelegate.window else { fatalError() }
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
        window?.endEditing(true)
        
        
        /* Anim */
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                self.dialogView!.layer.opacity = 1
                self.dialogView!.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }
        )
    }
    
    /// Dialog close animation then cleaning and removing the view from the parent
    private func close() {
        let currentTransform = self.dialogView.layer.transform
        
        let startRotation = (self.value(forKeyPath: "layer.transform.rotation.z") as? NSNumber) as? Double ?? 0.0
        let rotation = CATransform3DMakeRotation((CGFloat)(-startRotation + .pi * 270 / 180), 0, 0, 0)
        
        self.dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        self.dialogView.layer.opacity = 1
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [],
            animations: {
                self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
                let transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1))
                self.dialogView.layer.transform = transform
                self.dialogView.layer.opacity = 0
        }) { (_) in
            for v in self.subviews {
                v.removeFromSuperview()
            }
            
            self.removeFromSuperview()
            self.setupView()
        }
    }
    
    /// Creates the container view here: create the dialog, then add the custom content and buttons
    private func createContainerView() -> UIView {
        print("GenericPicker create Container View called")
        let screenSize = UIScreen.main.bounds.size
        let dialogSize = CGSize(width: 300, height: 230 + kDefaultButtonHeight + kDefaultButtonSpacerHeight)

        // For the black background
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let container = UIView(frame: CGRect(x: (screenSize.width - dialogSize.width) / 2,
                                             y: (screenSize.height - dialogSize.height) / 2,
                                             width: dialogSize.width,
                                             height: dialogSize.height))
        
        // First, we style the dialog to match the iOS8 UIAlertView >>>
        let gradient: CAGradientLayer = CAGradientLayer(layer: self.layer)
        gradient.frame = container.bounds
        gradient.colors = [UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor,
                           UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor,
                           UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1).cgColor]
        
        let cornerRadius = kCornerRadius
        gradient.cornerRadius = cornerRadius
        container.layer.insertSublayer(gradient, at: 0)
        
        container.layer.cornerRadius = cornerRadius
        container.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        container.layer.borderWidth = 1
        container.layer.shadowRadius = cornerRadius + 5
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0 - (cornerRadius + 5) / 2, height: 0 - (cornerRadius + 5) / 2)
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowPath = UIBezierPath(roundedRect: container.bounds,
                                                  cornerRadius: container.layer.cornerRadius).cgPath
        
        // There is a line above the button
        let yPosition = container.bounds.size.height - kDefaultButtonHeight - kDefaultButtonSpacerHeight
        let lineView = UIView(frame: CGRect(x: 0,
                                            y: yPosition,
                                            width: container.bounds.size.width,
                                            height: kDefaultButtonSpacerHeight))
        lineView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
        container.addSubview(lineView)
        
        //Title
        self.titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: dialogSize.width - 10, height: 30))
        self.titleLabel.textAlignment = .center
        self.titleLabel.textColor = self.textColor
        self.titleLabel.font = self.font.withSize(17)
        container.addSubview(self.titleLabel)
        // self.pickerView is now passed in pre-configured in init()

        print ("GenericPickerDialog add subview \(self.pickerView)")
        self.pickerView.setValue(self.textColor, forKeyPath: "textColor")
        self.pickerView.reloadAllComponents()
        container.addSubview(self.pickerView)
        
        // Add the buttons
        addButtonsToView(container: container)
        
        return container
    }
    
    /// Add buttons to container
    private func addButtonsToView(container: UIView) {
        let buttonWidth = container.bounds.size.width / 2
        
        let leftButtonFrame = CGRect(
            x: 0,
            y: container.bounds.size.height - kDefaultButtonHeight,
            width: buttonWidth,
            height: kDefaultButtonHeight
        )
        let rightButtonFrame = CGRect(
            x: buttonWidth,
            y: container.bounds.size.height - kDefaultButtonHeight,
            width: buttonWidth,
            height: kDefaultButtonHeight
        )
        
        let interfaceLayoutDirection = UIApplication.shared.userInterfaceLayoutDirection
        let isLeftToRightDirection = interfaceLayoutDirection == .leftToRight
        
        self.cancelButton = UIButton(type: .custom) as UIButton
        self.cancelButton.frame = isLeftToRightDirection ? leftButtonFrame : rightButtonFrame
        self.cancelButton.setTitleColor(self.buttonColor, for: .normal)
        self.cancelButton.setTitleColor(self.buttonColor, for: .highlighted)
        self.cancelButton.titleLabel!.font = self.font.withSize(14)
        self.cancelButton.layer.cornerRadius = kCornerRadius
        self.cancelButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.cancelButton)
        
        self.doneButton = UIButton(type: .custom) as UIButton
        self.doneButton.frame = isLeftToRightDirection ? rightButtonFrame : leftButtonFrame
        self.doneButton.tag = kDoneButtonTag
        self.doneButton.setTitleColor(self.buttonColor, for: .normal)
        self.doneButton.setTitleColor(self.buttonColor, for: .highlighted)
        self.doneButton.titleLabel!.font = self.font.withSize(14)
        self.doneButton.layer.cornerRadius = kCornerRadius
        self.doneButton.addTarget(self, action: .buttonTapped, for: .touchUpInside)
        container.addSubview(self.doneButton)
    }
    
    @objc func buttonTapped(sender: UIButton!) {
        if sender.tag == kDoneButtonTag {
            self.callback?( self.pickerView.selectedRow(inComponent: 0) )
        } else {
            self.callback?(nil)
        }
        
        close()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



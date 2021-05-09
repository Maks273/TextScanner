//
//  UIViewExtension.swift
//  TextScanner
//
//  Created by Maksym Paidych on 05.05.2021.
//

import UIKit

extension UIView {
    @IBInspectable var borderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        }
        get {
            return self.layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            self.layer.borderColor = newValue?.cgColor
        }
        get {
            return self.layer.borderColor?.uiColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        set {
            self.layer.shadowColor = newValue?.cgColor
        }
        get {
            return self.layer.shadowColor?.uiColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set {
            self.layer.shadowRadius = newValue
        }
        get {
            return self.layer.shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set {
            self.layer.shadowOpacity = newValue
        }
        get {
            return self.layer.shadowOpacity
        }
    }
    
    @IBInspectable var shadowPath: CGPath? {
        set {
            self.layer.shadowPath = newValue
        }
        get {
            return self.layer.shadowPath
        }
    }
    
    @IBInspectable var shadowOffset: CGSize {
        set {
            self.layer.shadowOffset = newValue
        }
        get {
            return self.layer.shadowOffset
        }
    }
    
}


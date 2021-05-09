//
//  UIViewControllerExtension.swift
//  TextScanner
//
//  Created by Maksym Paidych on 07.05.2021.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//
//  FullScreenViewController.swift
//  TextScanner
//
//  Created by Maksym Paidych on 06.05.2021.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    //MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: - Variables
    
    var image: UIImage?
    
    //MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
    //MARK: - IBActions
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

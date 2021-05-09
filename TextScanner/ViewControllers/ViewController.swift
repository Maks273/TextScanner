//
//  ViewController.swift
//  TextScanner
//
//  Created by Maksym Paidych on 05.05.2021.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    
    private var scanVC: ScanViewController?
    private var isContentViewExpanded: Bool = false {
        didSet {
            scanVC?.view.isHidden = !isContentViewExpanded
        }
    }
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        containerViewHeightConstraint.constant = 0
        setupContainerViewCorners()
    }
    
    //MARK: - Helper
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scanVC = segue.destination as? ScanViewController, segue.identifier == "scanContainer" {
            scanVC.delegate = self
            self.scanVC = scanVC
        }
    }

    //MARK: - IBActions
    
    @IBAction func showScanVCBtnPressed(_ sender: Any) {
        showScanVC()
    }
    
    
    //MARK: - Private methods
    
    private func showScanVC() {
        animateContainerView(hide: false)
    }
    
    private func animateContainerView(hide: Bool) {
        containerViewHeightConstraint.constant = hide ? 0 : self.view.frame.height - 80
        isContentViewExpanded = !hide
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        if !hide {
            scanVC?.scanVCHelper.setImage(nil)
            scanVC?.viewWillAppear(true)
        }
    }
    
    private func setupContainerViewCorners() {
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 25
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    
    private func setChildVC(_ viewController: UIViewController) {
        addChild(viewController)
        removeContainerViewSubviews()
        containerView.addSubview(viewController.view)
        viewController.viewWillAppear(true)
    }
    
    private func removeContainerViewSubviews() {
        for view in self.containerView.subviews {
            view.removeFromSuperview()
        }
    }
    

}

//MARK: - ScanViewDelegate

extension ViewController: ScanViewDelegate {
    
    func dismissContainer() {
        self.animateContainerView(hide: true)
    }
    
    func addChildVC(_ viewController: UIViewController) {
        if let viewController = viewController as? RecognizedTextViewController {
            viewController.delegate = self
            viewController.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        }
        setChildVC(viewController)
    }
}

extension ViewController: RecognizedTextViewDelegate {
    func dissmis() {
        if let scanVC = scanVC {
            setChildVC(scanVC)
        }else {
            if let scanVC = storyboard?.instantiateViewController(withIdentifier: "ScanViewController") as? ScanViewController {
                scanVC.delegate = self
                self.scanVC = scanVC
                setChildVC(scanVC)
            }
        }
    }
}


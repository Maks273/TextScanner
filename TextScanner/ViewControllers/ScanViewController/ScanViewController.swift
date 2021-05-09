//
//  ScanViewController.swift
//  TextScanner
//
//  Created by Maksym Paidych on 05.05.2021.
//

import UIKit
import AVFoundation
import ProgressHUD
import Photos

protocol ScanViewDelegate: AnyObject {
    func dismissContainer()
    func addChildVC(_ viewController: UIViewController)
}

class ScanViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var photoBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var nextBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoBtnCenterVerticaly: NSLayoutConstraint!
    
    @IBOutlet weak var takePhotoBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var takePhotoBtnWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var borderView: UIView!
    
    //MARK: - Variables
    
    weak var delegate: ScanViewDelegate?
    private var imageView: UIImageView?
    private let photoOutput = AVCapturePhotoOutput()
    private let captureSession = AVCaptureSession()
    var scanVCHelper: ScanVCHelper = ScanVCHelper()
    
    
    //MARK: - Life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageDidChange()
        recognizedTextDidChange()
        requestPhotoPermission()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: - IBActions
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        delegate?.dismissContainer()
        ProgressHUD.dismiss()
    }
    
    @IBAction func openPhotosBtnPressed(_ sender: Any) {
        ProgressHUD.dismiss()
        handleOpenPhotosBtnActions()
    }
    
    @IBAction func photoBtnPressed(_ sender: Any) {
        ProgressHUD.dismiss()
        handlePhotoBtnActions()
    }
    
    @IBAction func cropTextBtnPressed(_ sender: Any) {
        if scanVCHelper.getImage() != nil {
            ProgressHUD.show()
            scanVCHelper.performCropText()
        }
    }
    
    //MARK: - Private methods
    
    private func handleOpenPhotosBtnActions() {
        scanVCHelper.getImage() != nil ? presentFullScreenVC() : showImagePicker()
    }
    
    private func handlePhotoBtnActions() {
        scanVCHelper.getImage() != nil ? retakePhoto() : handleTakePhoto()
    }
    
    private func showImagePicker() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func setupCameraView() {
        #if !targetEnvironment(simulator)
        
        if let captureDevice = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device:captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch (let error) {
                print(error.localizedDescription)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraLayer.frame = self.containerView.bounds
            cameraLayer.videoGravity = .resizeAspectFill
            self.containerView.layer.addSublayer(cameraLayer)
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            captureSession.sessionPreset = .photo
            captureSession.startRunning()
        }
        #endif
    }
    
    private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    private func setupPreviewImageView() {
        captureSession.stopRunning()
        containerView.layer.sublayers?.removeAll()
        
        imageView = UIImageView()
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.image = scanVCHelper.getImage()
        self.view.addSubview(imageView!)
        
        self.view.addConstraints([
            imageView!.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 0),
            imageView!.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: 0),
            imageView!.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 0),
            imageView!.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0)
        ])
    }
    
    private func changeButtonsStyle() {
        photoBtn.setImage(UIImage(systemName: scanVCHelper.photoBtnImageName()), for: .normal)
        nextBtnWidthConstraint.constant = scanVCHelper.nextBtnWidth()
        borderView.isHidden = scanVCHelper.isBorderViewHidden()
        takePhotoBtnCenterVerticaly.constant = scanVCHelper.takePhotoBtnCenterVerticaly()
        takePhotoBtnWidthConstraint.constant = scanVCHelper.takePhotoBtnWidthConstraint()
        takePhotoBtnHeightConstraint.constant = scanVCHelper.takePhotoBtnHeightConstraint()
        scanVCHelper.configureNextBtn(nextBtn)
        scanVCHelper.configureTakePhotoBtn(takePhotoBtn)
    }
    
    private func retakePhoto() {
        scanVCHelper.setImage(nil)
    }
    
    private func presentFullScreenVC() {
        if let fullScreenVC = storyboard?.instantiateViewController(identifier: "FullScreenViewController") as? FullScreenViewController {
            fullScreenVC.image = scanVCHelper.getImage()
            self.present(fullScreenVC, animated: true, completion: nil)
        }
    }
    
    private func imageDidChange() {
        scanVCHelper.imageDidChange = { [weak self] isImage in
            guard let sSelf = self else {
                return
            }
            if isImage {
                sSelf.setupPreviewImageView()
            }else {
                sSelf.imageView?.removeFromSuperview()
                sSelf.setupCameraView()
            }
            sSelf.changeButtonsStyle()
        }
    }
    
    private func recognizedTextDidChange() {
        scanVCHelper.recoginzedTextDidChange = { [weak self] (recognizedStrings,errorText) in
            guard let sSelf = self else {
                return
            }
            
            if errorText == nil {
                if let recognizedTextVC = sSelf.storyboard?.instantiateViewController(withIdentifier: "RecognizedTextViewController") as? RecognizedTextViewController {
                    recognizedTextVC.recognizedVCHelper.setRecognizedStrings(recognizedStrings)
                    sSelf.delegate?.addChildVC(recognizedTextVC)
                }
               // present scan text using delegate
            }else {
                sSelf.presentAlert(title: "Error", message: errorText)
            }
        }
    }
    
    private func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization({status in })
    }
}

extension ScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            scanVCHelper.setImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ScanViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) else {
            return
        }
        scanVCHelper.setImage(image)
    }
}

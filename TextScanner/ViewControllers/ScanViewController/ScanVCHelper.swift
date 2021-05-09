//
//  ScanVCHelper.swift
//  TextScanner
//
//  Created by Maksym Paidych on 05.05.2021.
//

import UIKit
import Vision

class ScanVCHelper {
    
    //MARK: - Variables
    
    private var currentImage: UIImage? {
        didSet {
            imageDidChange?(currentImage != nil)
        }
    }
    
    
    var imageDidChange: ((_ isImage: Bool) -> Void)?
    var recoginzedTextDidChange: ((_ result: [String], _ errorText: String?) -> Void)?
    
    
    //MARK: - Helper
    
    func configureTakePhotoBtn(_ button: UIButton) {
        button.layer.cornerRadius = currentImage == nil ? 21 : 25
        button.layer.borderWidth = currentImage == nil ? 0 : 1
        button.backgroundColor = currentImage == nil ? UIColor(red: 87/255, green: 181/255, blue: 147/255, alpha: 1 ) : .white
        button.setImage(UIImage(systemName: currentImage == nil ? "" : "arrow.clockwise"), for: .normal)
    }
    
    func configureNextBtn(_ button: UIButton) {
        button.setTitle(currentImage == nil ? "" : "Crop text", for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: currentImage == nil ? 0 : 90, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
    }
    
    func isBorderViewHidden() -> Bool {
        return currentImage != nil
    }
    
    func photoBtnImageName() -> String {
        return  currentImage == nil ? "photo.fill" : "arrow.up.left.and.arrow.down.right"
    }
    
    func nextBtnWidth() -> CGFloat {
       return currentImage == nil ? 50 : 137
    }
    
    func takePhotoBtnCenterVerticaly() -> CGFloat {
        return currentImage == nil ? 0 : -45
    }
    
    func takePhotoBtnWidthConstraint() -> CGFloat {
        return currentImage == nil ? 42 : 50
    }
    
    func takePhotoBtnHeightConstraint() -> CGFloat {
        return currentImage == nil ? 42 : 50
    }
    
    
    func setImage(_ image: UIImage?) {
        self.currentImage = image
    }
    
    func getImage() -> UIImage? {
        return currentImage
    }
    
    func performCropText() {
        //global queue
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            
            guard let sSelf = self, let cgImage = sSelf.currentImage?.cgImage else {
                DispatchQueue.main.async {
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.recoginzedTextDidChange?([], "Can't get core graphics image")
                }
                return
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            let recognizedRequest = VNRecognizeTextRequest(completionHandler: sSelf.recognizeTextHandler(request:error:))
            
            do {
                try requestHandler.perform([recognizedRequest])
            } catch let error {
                DispatchQueue.main.async {
                    guard let sSelf = self else {
                        return
                    }
                    sSelf.recoginzedTextDidChange?([], error.localizedDescription)
                }
            }
        }
    }
    
  
    //MARK: - Private methods
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations =
                request.results as? [VNRecognizedTextObservation] else {
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else {
                return
            }
            sSelf.recoginzedTextDidChange?(recognizedStrings, nil)
        }
    }
}

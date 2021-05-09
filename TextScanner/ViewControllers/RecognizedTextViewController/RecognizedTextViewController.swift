
//
//  RecognizedTextViewController.swift
//  TextScanner
//
//  Created by Maksym Paidych on 06.05.2021.
//

import UIKit
import ProgressHUD

protocol RecognizedTextViewDelegate: AnyObject {
    func dissmis()
}

class RecognizedTextViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var wordsCountLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var audioView: AudioView!
    @IBOutlet weak var settingsBtn: UIButton!
    
    //MARK: - Variables
    
    weak var delegate: RecognizedTextViewDelegate?
    var recognizedVCHelper = RecognizedTextVCHelper()
    
    //MARK: - Life cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.delegate = self
        audioView.delegate = self
        ProgressHUD.dismiss()
        addDeleteMenuItem()
        setupHideKeyboardTapGesture()
        fillUI()
        playModeDidChange()
        audioErrorDidChange()
    }

   //MARK: - IBActions
    
    @IBAction func closeBtnPressed(_ sender: Any) {
        delegate?.dissmis()
        didTapOnView()
        recognizedVCHelper.stop()
        recognizedVCHelper.setPlayMode(true)
    }
    
    @IBAction func activityBtnPressed(_ sender: Any) {
        showActivityVC(with: [recognizedVCHelper.joinedText])
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        recognizedVCHelper.setPlayMode(true)
        recognizedVCHelper.getAudioFromUtterance { audioFile, errorString in
            if let audioFile = audioFile {
                
                //self.recognizedVCHelper.play()
            }
            DispatchQueue.main.async {
                self.audioView.configure(with: self.recognizedVCHelper.getDurationTime())
            }
        }
        
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any) {
        recognizedVCHelper.setPlayMode(false)
        recognizedVCHelper.pause()
    }
    //MARK: - Helper

    
    //MARK: - Private methods
    
    private func setupHideKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.view.addGestureRecognizer(tap)
    }

    @objc private func didTapOnView() {
        self.view.endEditing(true)
    }
    
    private func fillUI() {
        let joinedText = recognizedVCHelper.joinedText
        textView.text = joinedText
        wordsCountLabel.text = "\(joinedText.split(separator: " ").count) words"
    }
    
    private func showActivityVC(with objects: [Any]) {
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    private func addDeleteMenuItem() {
        let deleteItem = UIMenuItem(title: "Delete", action: #selector(deleteBtnPressed))
        UIMenuController.shared.menuItems = [deleteItem]
    }
    
    @objc private func deleteBtnPressed() {
        if let range = textView.selectedTextRange {
            textView.replace(range, withText: "")
        }
    }
    
    private func playModeDidChange() {
        recognizedVCHelper.playModeDidChange = { [weak self] isOn in
            guard let sSelf = self else {
                return
            }
            sSelf.menuView.isHidden = isOn
            sSelf.audioView.isHidden = !isOn
            sSelf.settingsBtn.isHidden = !isOn
            sSelf.textView.isEditable = !isOn
            if isOn {
               
            }
        }
    }
    
    private func audioErrorDidChange() {
        recognizedVCHelper.audioErrorDidChange = { [weak self] errorMessage in
            guard let sSelf = self, let errorMessage = errorMessage else {
                return
            }
            DispatchQueue.main.async {
                sSelf.presentAlert(title: "Error", message: errorMessage)
            }
           
        }
    }
    
}

extension RecognizedTextViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.recognizedVCHelper.currentText = textView.text
        self.wordsCountLabel.text = "\(recognizedVCHelper.currentText.split(separator: " ").count) words"
    }
}

extension RecognizedTextViewController: AudioViewDelegate {
    
    func getCurrentSeconds() -> Float {
        return recognizedVCHelper.getCurrentSeconds()
    }
    
    func getCurrentTimeString() -> String {
        recognizedVCHelper.getCurrentTimeString()
    }
    
    func resume(for value: Float) {
        recognizedVCHelper.resume(at: value)
    }
    
    func previouse15Secounds() {
        recognizedVCHelper.playPreviuose15Seconds()
    }
    
    func next15Secounds() {
        recognizedVCHelper.playNext15Seconds()
    }
    
    func pause() {
        recognizedVCHelper.pause()
    }
    
    func continueSpeaking() {
        recognizedVCHelper.continueSpeaking()
    }
    
    func isSpeaking() -> Bool {
        return recognizedVCHelper.isSpeaking()
    }
    
    func showActivityView() {
        if let audioFile = recognizedVCHelper.getAudioFile() {
            showActivityVC(with: [audioFile.url])
        }
  
    }
    
    func play() {
        recognizedVCHelper.play()
    }
    
    func stop() {
        recognizedVCHelper.stop()
    }
    
    func getDuration() -> Float {
        return recognizedVCHelper.getDurationTime()
    }
    
    
    
}

//
//  AudioView.swift
//  TextScanner
//
//  Created by Maksym Paidych on 06.05.2021.
//

import UIKit

protocol AudioViewDelegate: AnyObject {
    func showActivityView()
    func play()
    func pause()
    func continueSpeaking()
    func isSpeaking() -> Bool
   // func isPaused() -> Bool
    func previouse15Secounds()
    func next15Secounds()
    func stop()
    func resume(for value: Float)
    func getCurrentTimeString() -> String
    func getCurrentSeconds() -> Float
    func getDuration() -> Float
}

class AudioView: UIView {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    
    //MARK: - Variables
    
    weak var delegate: AudioViewDelegate?
    private var isPlaying: Bool = false
    private var updateTimer: Timer?
    private var duration: Float = 0
    private var finishedPlaying = true
    
    //MARK: - Initalizers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        invalidateTimer()
    }
    
    //MARK: - IBActions
    
    @IBAction func activityBtnPressed(_ sender: UIButton) {
        delegate?.showActivityView()
        
    }
    
    @IBAction func playBtnPressed(_ sender: Any) {
        resetSlider()
        guard let delegate = delegate else {
            return
        }
        isPlaying = delegate.isSpeaking()
        
        if isPlaying {
            delegate.pause()
        }else if finishedPlaying && !isPlaying {
            delegate.play()
            finishedPlaying = false
        }else {
            delegate.continueSpeaking()
        }
        isPlaying = delegate.isSpeaking()

        if isPlaying {
            createUpdateProgressTimer()
        }else {
            invalidateTimer()
        }
        
        changePlayBtnStyle(isPlaying)
    }
    
    @IBAction func next15SecBtnPressed(_ sender: Any) {
        invalidateTimer()
        createUpdateProgressTimer()
        delegate?.next15Secounds()
        changePlayBtnStyle(true)
    }
    
    @IBAction func previous15SecBtnPressed(_ sender: Any) {
        invalidateTimer()
        createUpdateProgressTimer()
        delegate?.previouse15Secounds()
        changePlayBtnStyle(true)
    }
    
    @IBAction func sliderDragExit(_ sender: UISlider) {
        invalidateTimer()
        delegate?.resume(for: sender.value)
        createUpdateProgressTimer()
        changePlayBtnStyle(true)
        print("sliderDragExit")
    }
    
    //MARK: - Helper
    
    func configure(with duration: Float) {
        addAudioPlayerDidFinishObserver()
        progressSlider.isContinuous = false
    }
    
    
    //MARK: - Private methods
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AudioView", owner: self, options: [:])
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func changePlayBtnStyle(_ isPlay: Bool) {
        playBtn.setImage(UIImage(systemName: isPlay ? "pause.fill" : "play.fill"), for: .normal)
    }
    
    
    private func resetSlider() {
        if finishedPlaying {
            //finishedPlaying = false
            progressSlider.value = 0
            invalidateTimer()
        }
    }
    
    @objc private func progressDidChange() {
        guard let delegate = delegate else {
            return
        }
        let floatDuration = delegate.getDuration()
        let currentSecondsFloat = delegate.getCurrentSeconds()
        
        progressSlider.value = currentSecondsFloat
        currentTimeLabel.text = delegate.getCurrentTimeString()
        self.duration = floatDuration
        progressSlider.maximumValue = floatDuration
        let currentSeconds = Int(currentSecondsFloat)
        let duration = Int(floatDuration)
        
        let minutes = (duration - currentSeconds)/60
        let seconds = duration - currentSeconds
        let durationString = NSString(format: "%02d:%02d", minutes,seconds) as String
        durationLabel.text = "-\(durationString)"
        leftLabel.text = "\(durationString)m left"
        
    }
    
    private func createUpdateProgressTimer() {
        updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(progressDidChange), userInfo: nil, repeats: true)
    }
    
    private func invalidateTimer() {
        if let timer = updateTimer {
            timer.invalidate()
        }
    }
    
    private func addAudioPlayerDidFinishObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying), name: .audioPlayerDidFinishPlaying, object: nil)
    }
    
    @objc private func audioPlayerDidFinishPlaying() {
        changePlayBtnStyle(false)
        finishedPlaying = true
        progressSlider.value = duration
        invalidateTimer()
        leftLabel.text = "00:00m left"
        durationLabel.text = "-00:00"
    }
    
}

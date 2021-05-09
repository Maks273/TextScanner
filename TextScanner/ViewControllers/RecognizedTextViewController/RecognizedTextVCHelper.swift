//
//  RecognizedTextVCHelper.swift
//  TextScanner
//
//  Created by Maksym Paidych on 06.05.2021.
//

import UIKit
import AVFoundation

class RecognizedTextVCHelper: NSObject {
    
    //MARK: - Variables
    
    var joinedText: String = "" {
        didSet {
            currentText = recognizedStrings.joined(separator: " ")
        }
    }
    
    var currentText: String = "" {
        didSet {
            if !currentText.isEmpty {
                self.utterance = createUtterance(currentText)
            }
        }
    }
    
    var playModeDidChange: ((_ isOn: Bool) -> Void)?
    var audioErrorDidChange: ((_ errorMessage: String?) -> Void)?
    
    private var recognizedStrings = [String]() {
        didSet {
            joinedText = recognizedStrings.joined(separator: " ")
        }
    }
    
    private var isPlayModeOn: Bool = false {
        didSet {
            playModeDidChange?(isPlayModeOn)
        }
    }
   
    private var utterance: AVSpeechUtterance? {
        didSet {
           // getAudioFromUtterance()
        }
    }
    
    private var audioErrorMessage: String? {
        didSet {
            audioErrorDidChange?(audioErrorMessage)
        }
    }
    
    private var audioOutputFile: AVAudioFile? {
        didSet {
            //createAudioPlayer()
        }
    }
    private let audioFileName = "audio.caf"
    private var synthesizerv = AVSpeechSynthesizer()
    private var utteranceCopy: AVSpeechUtterance?
    private var audioPlayer: AVAudioPlayer?
    
    
    //MARK: - Initalizer
    
    override init() {
        super.init()
       // synthesizerv.delegate = self
    }
    
    
    //MARK: - Helper
    
    func setRecognizedStrings(_ strings: [String]) {
        self.recognizedStrings = strings
    }
    
    func getRecognizedStrings() -> [String] {
        return recognizedStrings
    }
    
    func setPlayMode(_ isOn: Bool) {
        self.isPlayModeOn = isOn
    }
    
    func play() {
//        print(utterance?.pitchMultiplier )
//        if let utterance = utterance {
//            self.synthesizerv.speak(utterance)
//        }
        if let audioFile = audioOutputFile {
        createAudioPlayer(with: audioFile.url)
        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func continueSpeaking() {
        let time = Double(audioPlayer?.currentTime ?? 0)
        playSound(with: time, isSlider: true)
    }
    
    func isSpeaking() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
    
    func getAudioFile() -> AVAudioFile? {
        return audioOutputFile
    }
    
    func stop() {
        audioPlayer?.stop()
    }
    
    func playPreviuose15Seconds() {
        playSound(with: -15, isSlider: false)
    }
    
    func playNext15Seconds() {
        playSound(with: +15, isSlider: false)
    }
    
    func getCurrentTimeString() -> String {
        guard let audioPlayer = audioPlayer else {
            return "00:00"
        }
        let currentTime = Int(audioPlayer.currentTime)
        print("currentTime", audioPlayer.currentTime)
        print(audioPlayer.duration)
        let minutes = currentTime/60
        let seconds = currentTime - minutes * 60
        return NSString(format: "%02d:%02d", minutes,seconds) as String
    }
    
    func getAudioFromUtterance(completion: @escaping (_ audioFile: AVAudioFile?, _ errorText: String?) -> Void) {
//        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//            guard let sSelf = self else {
//                return
//            }
//
            let utterance = createUtterance(currentText)

            let synthesizerv = AVSpeechSynthesizer()
            synthesizerv.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    fatalError("unknown buffer type: \(buffer)")
                }
                if pcmBuffer.frameLength == 0 {
                }else {
                    if self.audioOutputFile == nil {
                        do {
                            var mainURL = self.getDocumentsDirectory()
                            mainURL.appendPathComponent(self.audioFileName)
                            self.removeAudioFromFiles()
                            self.audioOutputFile = try AVAudioFile(forWriting: mainURL, settings: pcmBuffer.format.settings, commonFormat: .pcmFormatInt16, interleaved: false)
                            //try self.audioOutputFile?.write(from: pcmBuffer)
                        }catch let error {
                            self.audioErrorMessage = error.localizedDescription
                        }
                    }
                    do {
                        try self.audioOutputFile?.write(from: pcmBuffer)
                       
                    }catch let error {
                        self.audioErrorMessage = error.localizedDescription
                    }
                    completion(self.audioOutputFile, nil)
                    return
                    
                }
            }
       // }
    }
    
    func getDurationTime() -> Float {
        return Float(audioPlayer?.duration ?? 0)
    }
    
    func getCurrentSeconds() -> Float {
        return Float(audioPlayer?.currentTime ?? 0.0)
    }
    
    func resume(at time: Float) {
        playSound(with: Double(time), isSlider: true)
    }
    
    //MARK: - Private methods
    
    private func playSound(with timeDelay: Double, isSlider: Bool) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        audioPlayer.pause()

        let time: TimeInterval = !isSlider ? audioPlayer.currentTime + timeDelay : timeDelay
        if audioPlayer.play(atTime: time) {
            audioPlayer.currentTime = time
            audioPlayer.play()
        }
        
    }
    
    private func createUtterance(_ source: String) -> AVSpeechUtterance {
        let utterance = AVSpeechUtterance(string: source)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.volume = 1
        utterance.rate = 0.4
       
        return utterance
    }
    
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func removeAudioFromFiles() {
        do {
            var mainURL = getDocumentsDirectory()
            mainURL.appendPathComponent(audioFileName)
            try FileManager.default.removeItem(at: mainURL)
        }catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    private func createAudioPlayer(with url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
        }catch (let error) {
            print(error.localizedDescription)
            audioPlayer = nil
        }
        audioPlayer?.rate = 1
        audioPlayer?.delegate = self
        audioPlayer?.numberOfLoops = 0
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    private func notifyPlayerDidFinishPlaying() {
        NotificationCenter.default.post(name: .audioPlayerDidFinishPlaying, object: nil)
    }
    
}


extension RecognizedTextVCHelper: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            audioPlayer?.stop()
            notifyPlayerDidFinishPlaying()
        }
    }
    
}

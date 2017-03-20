//
//  AudioPlayerViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

typealias SuccessCompletion = (Bool) -> Void

// MARK: - Constants
private struct Constants {
    struct Rate {
        static let Default: Float = 1.0
        static let Rabbit: Float = 2.0
        static let Snail: Float = 0.5
    }
    struct Pitch {
        static let Default: Float = 1.0
        static let Chipmunk: Float = 1000
        static let Vader: Float = -700
    }
    struct Color {
        static let Cyan: UIColor = UIColor(red: 26/255, green: 57/255, blue: 92/255, alpha: 1.0)
    }
    struct AudioFile {
        static let FileName: String = "VoiceChanger.wav"
        static let Settings: [String : Any] =
            [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0]
    }
}

class AudioPlayerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedSlider: UISlider!
    @IBOutlet var shareButton: UIButton! {
        didSet {
            shareButton.layer.cornerRadius = 8
            shareButton.layer.masksToBounds = true
            shareButton.layer.borderWidth = 1.5
            shareButton.layer.borderColor = Constants.Color.Cyan.cgColor
        }
    }
    
    // MARK: - Properties
    var recordedURL: URL?
    private var audioFile: AVAudioFile?
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var changePitchEffect: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    
    private lazy var shareURL: URL = {
        let path = NSTemporaryDirectory().appending(Constants.AudioFile.FileName)
        let url = URL(fileURLWithPath: path)
        return url
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = recordedURL {
            do {
                audioFile = try AVAudioFile(forReading: url)
            } catch {
                print("Error creating audioFile:\n\(error)")
            }
        }
    }
    
    // MARK: - Private
    private func setPitch(_ pitch: Float) {
        pitchSlider.value = pitch
        pitchLabel.text = "Pitch: \(Int(pitch))"
        changePitchEffect.pitch = pitch
    }
    
    private func setRate(_ rate: Float) {
        speedSlider.value = rate
        speedLabel.text = "Speed: \(Int(rate))"
        changePitchEffect.rate = rate
    }
    
    private func playAudio(){
        stopPlaying()
        
        guard let audioFile = self.audioFile else { return }
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audioEngine:\n\(error)")
            return
        }
        
        audioPlayerNode.play()
    }
    
    private func playAudio(rate: Float, pitch: Float) {
        setRate(rate)
        setPitch(pitch)
        playAudio()
    }
    
    private func stopPlaying() {
        audioEngine.stop()
        audioEngine.reset()
    }
    
    private func exportAndShare() {
        stopPlaying()
        exportAudio { success in
            if success {
                self.displayActivityViewController()
            } else {
                // TODO - display error
                print("\n\n\nERROR EXPORTING AUDIO\n")
            }
        }
    }
    
    private func exportAudio(completion: @escaping SuccessCompletion) {
//        guard let recordedAudioFile = audioFile else { completion(false); return }
//        
//        FileManager.removeFileAtURLIfNeeded(url: shareURL)
//        let asset = AVAsset(url: url)
//        
//        do {
//            let audioFile = try AVAudioFile(forWriting: shareURL, settings: audioEngine.mainMixerNode.outputFormat(forBus: 0).settings)
//            let audioFrameCount = AVAudioFrameCount(recordedAudioFile.length)
//            let buffer = AVAudioPCMBuffer(pcmFormat: recordedAudioFile.processingFormat, frameCapacity: audioFrameCount)
//            try recordedAudioFile.read(into: buffer, frameCount: audioFrameCount)
//            try audioFile.write(from: buffer)
//            audioFile.framePosition = audioFile.length
//        } catch {
//            print("ERROR EXPORTING: \(error)")
//        }
//        
//        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
//            exportSession.outputFileType = AVFileTypeAppleM4A
//            exportSession.outputURL = shareURL
//            
//            exportSession.exportAsynchronously(completionHandler: {
//                if exportSession.status == .completed {
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            })
//        }
    }
    
    private func displayActivityViewController() {
        let activityItems = [shareURL]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func snailButtonTapped(_ sender: UIButton) {
        playAudio(rate:Constants.Rate.Snail, pitch: Constants.Pitch.Default)
    }
    
    @IBAction func rabbitButtonTapped(_ sender: UIButton) {
        playAudio(rate:Constants.Rate.Rabbit, pitch: Constants.Pitch.Default)
    }
    
    @IBAction func chipmunkButtonTapped(_ sender: UIButton) {
        playAudio(rate:Constants.Rate.Default, pitch: Constants.Pitch.Chipmunk)
    }
    
    @IBAction func vaderButtonTapped(_ sender: UIButton) {
        playAudio(rate:Constants.Rate.Default, pitch: Constants.Pitch.Vader)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playAudio()
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopPlaying()
        setPitch(Constants.Pitch.Default)
        setRate(Constants.Rate.Default)
    }
    
    @IBAction func pitchSliderChanged(_ sender: UISlider) {
        setPitch(sender.value)
    }
    
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        setRate(sender.value)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        exportAndShare()
    }
}

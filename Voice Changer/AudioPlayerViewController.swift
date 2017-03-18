//
//  AudioPlayerViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

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
}

class AudioPlayerViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedSlider: UISlider!
    
    // MARK: - Properties
    var receivedAudio: RecordedAudio!
    private var audioFile: AVAudioFile?
    private var audioEngine: AVAudioEngine = AVAudioEngine()
    private var changePitchEffect: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl)
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
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
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
    }
    
    @IBAction func pitchSliderChanged(_ sender: UISlider) {
        setPitch(sender.value)
    }
    
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        setRate(sender.value)
    }
}

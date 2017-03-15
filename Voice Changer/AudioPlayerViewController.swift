//
//  AudioPlayerViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

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
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine!
    var changePitchEffect: AVAudioUnitTimePitch!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
        audioEngine = AVAudioEngine()
        changePitchEffect = AVAudioUnitTimePitch()
    }
    
    // MARK: - Private
    private func setPitch(_ pitch: Float) {
        pitchLabel.text = "Pitch: \(Int(pitch))"
        changePitchEffect.pitch = pitch
    }
    
    private func setRate(_ rate: Float) {
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
    
    private func stopPlaying() {
        audioEngine.stop()
        audioEngine.reset()
    }
    
    // MARK: - Actions
    @IBAction func snailButtonTapped(_ sender: UIButton) {
        pitchSlider.value = Constants.Pitch.Default
        setPitch(Constants.Pitch.Default)
        speedSlider.value = Constants.Rate.Snail
        setRate(Constants.Rate.Snail)
        playAudio()
    }
    
    @IBAction func rabbitButtonTapped(_ sender: UIButton) {
        pitchSlider.value = Constants.Pitch.Default
        setPitch(Constants.Pitch.Default)
        speedSlider.value = Constants.Rate.Rabbit
        setRate(Constants.Rate.Rabbit)
        playAudio()
    }
    
    @IBAction func chipmunkButtonTapped(_ sender: UIButton) {
        pitchSlider.value = Constants.Pitch.Chipmunk
        setPitch(Constants.Pitch.Chipmunk)
        speedSlider.value = Constants.Rate.Default
        setRate(Constants.Rate.Default)
        playAudio()
    }
    
    @IBAction func vaderButtonTapped(_ sender: UIButton) {
        pitchSlider.value = Constants.Pitch.Vader
        setPitch(Constants.Pitch.Vader)
        speedSlider.value = Constants.Rate.Default
        setRate(Constants.Rate.Default)
        playAudio()
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

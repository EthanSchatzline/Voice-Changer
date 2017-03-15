//
//  AudioPlayerViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    private func playAudio(rate: Float){
        audioEngine.stop()
        audioEngine.reset()
        
        guard let audioFile = self.audioFile else { return }
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 1.0
        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)
        changePitchEffect.rate = rate
        audioEngine.attach(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
        }
        
        audioPlayerNode.play()
        speedSlider.isEnabled = false
    }
    
    private func stopPlaying() {
        audioEngine.stop()
        audioEngine.reset()
        pitchSlider.value = 1.0
        setPitch(1.0)
        speedSlider.isEnabled = true
    }
    
    // MARK: - Actions
    @IBAction func snailButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1.0
        setPitch(1.0)
        playAudio(rate: 0.5)
    }
    
    @IBAction func rabbitButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1.0
        setPitch(1.0)
        playAudio(rate: 2.0)
    }
    
    @IBAction func chipmunkButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1000
        setPitch(1000.0)
        playAudio(rate: 1.0)
    }
    
    @IBAction func vaderButtonTapped(_ sender: UIButton) {
        pitchSlider.value = -700
        setPitch(-700.0)
        playAudio(rate: 1.0)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playAudio(rate: changePitchEffect.rate)
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

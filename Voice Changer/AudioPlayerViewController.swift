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
    
    // MARK: - Actions
    @IBAction func snailButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(pitchSlider.value)")
        changePitchEffect.pitch = 1
        playAudioWithVariablePitch(0.5)
    }
    
    @IBAction func rabbitButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(pitchSlider.value)")
        changePitchEffect.pitch = 1
        playAudioWithVariablePitch(2.0)
    }
    
    @IBAction func chipmunkButtonTapped(_ sender: UIButton) {
        pitchSlider.value = 1000
        pitchLabel.text = ("Pitch: \(1000)")
        changePitchEffect.pitch = 1000
        playAudioWithVariablePitch(1.0)
    }
    
    @IBAction func vaderButtonTapped(_ sender: UIButton) {
        pitchSlider.value = -700
        pitchLabel.text = ("Pitch: \(-700)")
        changePitchEffect.pitch = -700
        playAudioWithVariablePitch(1.0)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playAudioWithVariablePitch(1.0)
    }

    @IBAction func stopButtonTapped(_ sender: UIButton) {
        audioEngine.stop()
        audioEngine.reset()
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(1.0)")
        changePitchEffect.pitch = 1.0
    }
    
    @IBAction func pitchSliderChanged(_ sender: UISlider) {
        changePitchEffect.pitch = sender.value
        pitchLabel.text = "Pitch: \(sender.value)"
    }
    
    @IBAction func speedSliderChanged(_ sender: UISlider) {
        // TODO - set speed
        speedLabel.text = "Speed: \(sender.value)"
    }
    
    // MARK: - Private
    private func playAudioWithVariablePitch(_ rate: Float){
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
    }
}

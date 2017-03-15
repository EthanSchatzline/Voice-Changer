//
//  PlaySoundsViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var receivedAudio: RecordedAudio!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    var changePitchEffect: AVAudioUnitTimePitch!
    
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var speedSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathUrl as URL)
        changePitchEffect = AVAudioUnitTimePitch()
    }
    
    @IBAction func slowPlay(_ sender: UIButton) {
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(pitchSlider.value)")
        changePitchEffect.pitch = 1
        playAudioWithVariablePitch(0.5)
    }
    
    @IBAction func fastPlay(_ sender: UIButton) {
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(pitchSlider.value)")
        changePitchEffect.pitch = 1
        playAudioWithVariablePitch(2.0)
    }
    
    @IBAction func pitchSliderChanged(_ sender: UISlider) {
        changePitchEffect.pitch = sender.value
        pitchLabel.text = ("Pitch: \(sender.value)")
    }
    
    @IBAction func speedSliderChanged(_ sender: Any) {
        
    }
    
    @IBAction func playChipmunkAudio(_ sender: UIButton) {
        pitchSlider.value = 1000
        pitchLabel.text = ("Pitch: \(1000)")
        changePitchEffect.pitch = 1000
        playAudioWithVariablePitch(1.0)
    }
    
    @IBAction func playDarthVaderAudio(_ sender: UIButton) {
        pitchSlider.value = -700
        pitchLabel.text = ("Pitch: \(-700)")
        changePitchEffect.pitch = -700
        playAudioWithVariablePitch(1.0)
    }
    
    func playAudioWithVariablePitch(_ rate:Float){
        audioEngine.stop()
        audioEngine.reset()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 1.0;
        audioEngine = AVAudioEngine()
        audioEngine.attach(audioPlayerNode)
        changePitchEffect.rate = rate;
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
        };
        audioPlayerNode.play()
    }
    
    @IBAction func playAudio(_ sender: UIButton) {
        playAudioWithVariablePitch(1.0)
    }

    @IBAction func stopPlay(_ sender: UIButton) {
        audioEngine.stop()
        audioEngine.reset()
        pitchSlider.value = 1.0
        pitchLabel.text = ("Pitch: \(1.0)")
        changePitchEffect.pitch = 1.0
    }
}

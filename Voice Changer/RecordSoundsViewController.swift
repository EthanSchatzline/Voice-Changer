//
//  RecordSoundsViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet var recordingInProgress: UILabel!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stopButton.isHidden = true
    }

    @IBAction func recordAudio(_ sender: UIButton) {
        recordingInProgress.isHidden = false
        stopButton.isHidden = false
        recordButton.isEnabled = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let recordingName = "my_audio.wav"
        let filePath = URL(fileURLWithPath: dirPath).appendingPathComponent(recordingName)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch _ {
        }
       
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0] as [String : Any]
        audioRecorder = try? AVAudioRecorder(url: filePath, settings:recordSettings as [String : AnyObject])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "stopRecording"){
            let playSoundsVC: PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            self.performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        } else{
            recordButton.isEnabled = true
            stopButton.isHidden = true
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        recordingInProgress.isHidden = true
        stopButton.isHidden = true
        recordButton.isEnabled = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
    }
}

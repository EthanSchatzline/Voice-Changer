//
//  RecordingViewController.swift
//  Voice Changer
//
//  Created by Ethan Schatzline on 7/14/15.
//  Copyright (c) 2015 ES Interactive. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Constants
private struct Constants {
    struct SegueID {
        static let StopRecording: String = "stopRecording"
    }
    struct AudioFile {
        static let FileName: String = "my_audio.wav"
    }
}

class RecordingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder?
    fileprivate var recordedAudio: RecordedAudio?
    private let recordSettings: [String : Any] =
        [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
         AVEncoderBitRateKey: 16,
         AVNumberOfChannelsKey: 2,
         AVSampleRateKey: 44100.0]
    private lazy var filePathURL: URL = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = Constants.AudioFile.FileName
        let fileURL = URL(fileURLWithPath: path).appendingPathComponent(fileName)
        return fileURL
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
    }

    // MARK: - Actions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        toggleRecording()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        toggleRecording()
    }
    
    // MARK: - Private
    private func toggleRecording() {
        let isRecording = audioRecorder?.isRecording ?? false
        
        statusLabel.isHidden = isRecording
        stopButton.isHidden = isRecording
        recordButton.isEnabled = isRecording
        
        if isRecording {
            audioRecorder?.stop()
        } else {
            startRecording()
        }
    }
    
    private func startRecording() {
        audioRecorder = try? AVAudioRecorder(url: filePathURL, settings: recordSettings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewcontroller = segue.destination as? AudioPlayerViewController {
            viewcontroller.receivedAudio = recordedAudio
        }
    }
}

extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            self.performSegue(withIdentifier: Constants.SegueID.StopRecording, sender: nil)
        } else{
            recordButton.isEnabled = true
            stopButton.isHidden = true
        }
    }
}

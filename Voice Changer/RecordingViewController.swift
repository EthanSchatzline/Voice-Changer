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
        static let FileName: String = "kVoiceChangerRecordedAudio.wav"
        static let Settings: [String : Any] =
            [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0]
    }
}

class RecordingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var recordButton: UIButton!
    
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder?
    private lazy var fileURL: URL = {
        let path = NSTemporaryDirectory().appending(Constants.AudioFile.FileName)
        let url = URL(fileURLWithPath: path)
        return url
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.isHidden = true
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
        FileManager.removeFileAtURLIfNeeded(url: fileURL)
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: Constants.AudioFile.Settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
        } catch {
            print("Error creating audio recording with file url:\n\(error)")
            toggleRecording()
        }
    }

    // MARK: - Actions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        toggleRecording()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        toggleRecording()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewcontroller = segue.destination as? AudioPlayerViewController {
            viewcontroller.recordedURL = audioRecorder?.url
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension RecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            self.performSegue(withIdentifier: Constants.SegueID.StopRecording, sender: nil)
        } else{
            recordButton.isEnabled = true
            stopButton.isHidden = true
        }
    }
}

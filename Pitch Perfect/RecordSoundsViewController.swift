//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Christopher Barger on 12/8/15.
//  Copyright © 2015 State Farm. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.stopButton.hidden = true
        self.recordButton.enabled = true
        self.recordingLabel.text = "Tap to Record"
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        // TODO: Record users voice
        self.recordButton.enabled = false
        self.recordingLabel.text = "Recording in Progress"
        self.stopButton.hidden = false
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        print(filePath)
        
        let session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
        }
        catch {
            print("unable to set audio session category or activate session")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        }
        catch {
            print("unable to create audio recorder")
        }
        
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecordingAudio(sender: UIButton) {
        self.recordingLabel.text = "Tap to Record"
        self.recordButton.enabled = true
        self.stopButton.hidden = true
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        }
        catch {
            print("Unable to set audioSession to false")
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            guard let audioTitle:String = recorder.url.lastPathComponent else {
                print("Could not get a string value for audio title")
                return
            }
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: audioTitle)
            
            performSegueWithIdentifier("StopRecording", sender: recordedAudio)
        }
        else {
            print("Error recording")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "StopRecording" {
            guard let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as? PlaySoundsViewController else {
                return
            }
            guard let data = sender as? RecordedAudio else {
                return
            }
            playSoundsVC.receivedAudio = data
        }
    }
    
}


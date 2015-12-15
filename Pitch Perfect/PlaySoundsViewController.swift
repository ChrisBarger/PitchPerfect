//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Christopher Barger on 12/8/15.
//  Copyright © 2015 State Farm. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    var receivedAudio:RecordedAudio!
    var playbackManager:PlaybackManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playbackManager = PlaybackManager(myAudio: receivedAudio)
    }
    
    override func viewWillDisappear(animated: Bool) {
        playbackManager = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func slowButtonTapped(sender: UIButton) {
        playbackManager.playAudioAtVariableRate(0.5)
    }

    @IBAction func fastButtonTapped(sender: UIButton) {
        playbackManager.playAudioAtVariableRate(2.0)
    }
    
    @IBAction func chipmunkButtonTapped(sender: UIButton) {
        playbackManager.playAudioWithVariablePitch(1000.00)
    }
    
    @IBAction func vaderButtonTapped(sender: UIButton) {
        playbackManager.playAudioWithVariablePitch(-1000.00)
    }
    
    @IBAction func eagleButtonTapped(sender: UIButton) {
        playbackManager.playAudioWithEcho()
    }
    
    @IBAction func reverbButtonTapped(sender: UIButton) {
        playbackManager.playAudioWithReverb()
    }
    
    @IBAction func stopButtonTapped(sender: UIButton) {
        playbackManager.stopAllPlayback()
    }
}

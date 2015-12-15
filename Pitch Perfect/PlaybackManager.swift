//
//  AudioManager.swift
//  Pitch Perfect
//
//  Created by Christopher Barger on 12/11/15.
//  Copyright © 2015 State Farm. All rights reserved.
//

import Foundation
import AVFoundation

class PlaybackManager:NSObject {
    
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var audioPlayer:AVAudioPlayer!
    var audioPlayerNode:AVAudioPlayerNode!
    var reverb:AVAudioUnitReverb!
    var echo:AVAudioUnitDelay!
    var unitTimePitch:AVAudioUnitTimePitch!
    var engineState:EngineState!
    
    struct EngineState {
        //this struct will keep track of which nodes have been added to the engine so that we may remove them later on.
        var playerNodeAttached:Bool = false
        var echoNodeAttached:Bool = false
        var pitchNodeAttached:Bool = false
        var reverbNodeAttached:Bool = false
        
        mutating func resetNodesAttached () {
            playerNodeAttached = false
            echoNodeAttached = false
            pitchNodeAttached = false
            reverbNodeAttached = false
        }
    }
    
    init(myAudio:RecordedAudio){
        super.init()
        
        if (audioEngine == nil) {
            audioEngine = AVAudioEngine()
        }
        engineState = EngineState()
        
        startAudioSession()
        
        //Audio Player
        do{
            audioPlayer = try AVAudioPlayer(contentsOfURL: myAudio.filePathUrl)
            audioPlayer.enableRate = true
            audioPlayer.volume = 1.00
        }
        catch{
            print("could not create audioPlayer")
        }
        
        //Audio File
        do {
            audioFile = try AVAudioFile(forReading: myAudio.filePathUrl)
        }
        catch {
            print("could not create audio file")
        }
        
        //engine effects... instantiate once and only once
        audioPlayerNode = AVAudioPlayerNode()
        reverb = AVAudioUnitReverb()
        echo = AVAudioUnitDelay()
        unitTimePitch = AVAudioUnitTimePitch()
    }
    
    func startAudioSession () {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(true)
        }
        catch {
            print("Unable to set audioSession to false")
        }
    }
    
    func playAudioAtVariableRate(rate:Float){
        audioPlayer.rate = rate
        stopAllPlayback()
        audioPlayer.currentTime = 0
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    
    func playAudioWithReverb() {
        stopAllPlayback()
        
        audioPlayerNode.volume = 1.00
        audioEngine.attachNode(audioPlayerNode)
        engineState.playerNodeAttached = true
        
        reverb.wetDryMix = 75.0
        audioEngine.attachNode(reverb)
        engineState.reverbNodeAttached = true
        
        audioEngine.connect(audioPlayerNode, to: reverb, format: nil)
        audioEngine.connect(reverb, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        tryStartAudioEngine()
        audioPlayerNode.volume = 1.00
        audioPlayerNode.play()
    }
    
    func playAudioWithEcho () {
        stopAllPlayback()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioPlayerNode.volume = 1.00
        audioEngine.attachNode(audioPlayerNode)
        engineState.playerNodeAttached = true
        
        echo = AVAudioUnitDelay()
        echo.delayTime = 0.5
        echo.wetDryMix = 75.0
        audioEngine.attachNode(echo)
        engineState.echoNodeAttached = true
        
        audioEngine.connect(audioPlayerNode, to: echo, format: nil)
        audioEngine.connect(echo, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        tryStartAudioEngine()
        audioPlayerNode.volume = 1.00
        audioPlayerNode.play()
    }
    
    func playAudioWithVariablePitch(pitch:Float) {
        stopAllPlayback()
        audioPlayerNode.volume = 1.00
        audioEngine.attachNode(audioPlayerNode)
        engineState.playerNodeAttached = true
        
        unitTimePitch.pitch = pitch
        audioEngine.attachNode(unitTimePitch)
        engineState.pitchNodeAttached = true
        
        audioEngine.connect(audioPlayerNode, to: unitTimePitch, format: nil)
        audioEngine.connect(unitTimePitch, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        
        tryStartAudioEngine()
        audioPlayerNode.volume = 1.00
        audioPlayerNode.play()
    }
    
    func tryStartAudioEngine(){
        do{
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch {
            print("Unable to start audio engine")
        }
    }
    
    func getNewAudioEffects() {
        //here we will detach all in use engine nodes so we can easily reuse them. We also must stop the playback of the player node or we will run into PCM Audio Buffer memory leak problems.
        //detatch nodes
        if engineState.playerNodeAttached == true {
            audioPlayerNode.stop()//this actually ended up fixing a memory leak
            audioEngine.detachNode(audioPlayerNode)
            audioPlayerNode.reset()
        }
        if engineState.reverbNodeAttached == true {
            audioEngine.detachNode(reverb)
            reverb.reset()
        }
        if engineState.echoNodeAttached == true {
            audioEngine.detachNode(echo)
            echo.reset()
        }
        if engineState.pitchNodeAttached == true {
            audioEngine.detachNode(unitTimePitch)
            unitTimePitch.reset()
        }
        
        //reset engineState to make sure we don't try to reset a node that is not attached.
        engineState.resetNodesAttached()
    }
    
    func stopAllPlayback () {
        //called on every button press (sounds and stop), this function stops audio output from all sources and prepares for playback from any audio source.
        audioEngine.stop()
        getNewAudioEffects()
        audioEngine.reset()
        audioPlayer.stop()
    }
}
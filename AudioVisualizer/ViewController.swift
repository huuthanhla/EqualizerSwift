//
//  ViewController.swift
//  AudioVisualizer
//
//  Created by Thành Lã on 11/27/18.
//  Copyright © 2018 MonstarLab. All rights reserved.
//

import UIKit
import EZAudioiOS
import DisPlayers_Audio_Visualizers

class ViewController: UIViewController {
    @IBOutlet weak var equalizerView: EqualizerView!
    @IBOutlet weak var audioTimeLabel: UILabel!
    @IBOutlet weak var microphoneSwitch: UISwitch!
    
    @IBOutlet weak var audioPlot: AudioPlot!
    
    var audioFile: EZAudioFile!
    
    var microphone: EZMicrophone!
    var recorder: EZRecorder!
    var player: EZAudioPlayer!
    
    var timer: Timer!
    
    lazy var testAudioRecordUrl: URL? = {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let audioPath = String(format: "%@/%@", documentsPath, "AudioTest.m4a")
        return URL(string: audioPath)
    }()
    
    lazy var testAudioUrl: URL? = {
        if let audioPath = Bundle.main.path(forResource: "Con_duyen_intro", ofType: "m4a") {
            return URL(string: audioPath)
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let setting = DPEqualizerSettings.create(by: .rolling)
        setting?.numOfBins = 80
        equalizerView.equalizerSettings = setting
        
        if let image = UIImage(named: "pattern-grey") {
            view.backgroundColor = UIColor(patternImage: image)
        }
        
        waveFromAudioFile()
    }
    
    func waveFromAudioFile() {
        
        audioPlot.shouldOptimizeForRealtimePlot = false
        audioPlot.backgroundColor = UIColor.clear
        audioPlot.color = .orange
        
        audioPlot.plotType = .buffer
        audioPlot.shouldFill = true
        audioPlot.shouldMirror = true
        
        audioPlot.gain = 2
        
        guard let testAudioUrl = testAudioUrl, let file = EZAudioFile(url: testAudioUrl) else { return }
        
        audioFile = file
        
        audioFile.getWaveformData(completionBlock: { [weak self] (waveformData, length) in
            guard let waveformData = waveformData else { return }
            self?.audioPlot.updateBuffer(waveformData[0], withBufferSize: UInt32(length))
        })
        
    }
    
    func startTimer() {
        timer = nil
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in self.updateTimeLabel() })
    }
    
    func updateTimeLabel() {
        guard let player = self.player, player.isPlaying else { return }
        let time = Int(player.currentTime)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        audioTimeLabel.text = String(format: "%0.2d:%0.2d", minutes, seconds)
    }
    
    @IBAction func playAction(_ sender: Any) {
        if self.player == nil {
            guard let audioUrl = testAudioUrl else { return }
            
            player = EZAudioPlayer(audioFile: EZAudioFile(url: audioUrl))
            player.delegate = self
            player.shouldLoop = true
            player.volume = 1
        }
        
        guard let player = player else { return }
        
        player.play()
        
        if timer == nil {
            startTimer()
        }
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        guard let player = player else { return }
        player.pause()
    }
    
    @IBAction func recordAction(_ sender: Any) {
//        guard let recordUrl = testAudioRecordUrl else { return }
//        recorder = EZRecorder(url: recordUrl, clientFormat: self.microphone.audioStreamBasicDescription(), fileType: .M4A)
    }
    
    @IBAction func stopAction(_ sender: Any) {
        guard let player = player else { return }
        player.pause()
        
        self.player = nil
        timer.invalidate()
        timer = nil
        audioTimeLabel.text = "00:00"
    }
    
    @IBAction func switchAction(_ sender: Any) {
        
    }
}

extension ViewController: EZMicrophoneDelegate {
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
    }
    
    func microphone(_ microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
    }
}

extension ViewController: EZAudioPlayerDelegate {
    func audioPlayer(_ audioPlayer: EZAudioPlayer!, playedAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, in audioFile: EZAudioFile!) {
        
        DispatchQueue.main.async {
            if let player = self.player, player.isPlaying {
                self.equalizerView.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
        
    }
}

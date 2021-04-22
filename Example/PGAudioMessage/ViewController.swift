//
//  ViewController.swift
//  PGAudioMessage
//
//  Created by ipagong on 04/13/2021.
//  Copyright (c) 2021 ipagong. All rights reserved.
//

import UIKit
import PGAudioMessage
import AVFoundation

class ViewController: UIViewController {
    
    var url: URL?
    
    @IBOutlet weak var hiddenButton: UIButton!
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = 50
            actionButton.layer.masksToBounds = true
        }
    }
    
    var status: Status = .initialized { didSet { self.updateUI() } }
    
    @IBOutlet weak var waveView: AudioVisualizationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    /*
    // Check the commented code to confirm permission and session before user takes audio action.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AudioService.shared.permission { [weak self] (error) in
            self?.status = error == nil ? .initialized : .unavailbale
        }
        
        AudioService.shared.activation { [weak self] (error) in
            self?.status = error == nil ? .initialized : .unavailbale
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AudioService.shared.deactivation()
    }
    */

    @IBAction func onClicked(_ sender: Any) {
        switch self.status {
        case .initialized:
            AudioService.shared.startRecord(with: nil) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let url):
                    self.url = url
                    self.status = .recorded
                    
                case .failure(let error):
                    debugPrint(error)
                    self.status = .initialized
                }
            }
            self.status = .recording
            
        case .recording:
            AudioService.shared.stopRecord()
            
        case .recorded:
            guard let url = self.url else { return }
            AudioService.shared.startPlay(with: .url(url)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success:
                    self.status = .initialized
                    
                case .failure(let error):
                    debugPrint(error)
                    self.status = .initialized
                }
            }
            self.status = .playing
            
        case .playing:
            self.status = .initialized
            AudioService.shared.stopPlay()
            
        case .unavailbale:
            debugPrint("unavailbale...!!!")
        }
        
    }
    
    func updateUI() {
        self.actionButton.setTitle(self.status.actionTitle, for: .normal)
        self.actionButton.backgroundColor = self.status.actionColor
        
        switch self.status {
        case .recording:
            self.waveView.reset()
            self.waveView.audioVisualizationMode = .write
            self.recordTick()
        case .playing:
            self.waveView.reset()
            self.waveView.audioVisualizationMode = .read

            AudioContext.load(fromAudioURL: self.url!) { [weak self] (context) in
                guard let self = self, let context = context else { return }
                self.waveView.meteringLevels = context.render(targetSamples: 500)?.compactMap{ $0.sampleFilter }
                self.waveView.play(for: context.asset.duration.seconds)
            }

            self.playTick()
        default:
            self.cancel()
        }
    }
    
    @objc func recordTick() {
        self.actionButton.setTitle("\(AudioService.shared.recorder.currentTime.stringValue)", for: .normal)
        self.transformButtonScale(with: AudioService.shared.recorder.averagePowerRate)
        if let level = AudioService.shared.recorder.averagePowerRate { self.waveView.add(meteringLevel: Float(level * 1.5)) }
        self.perform(#selector(self.recordTick), with: nil, afterDelay: 0.1)
    }
    
    @objc func playTick() {
        self.actionButton.setTitle("\(AudioService.shared.player.currentTime.stringValue) / \(AudioService.shared.player.duration.stringValue)", for: .normal)
        self.transformButtonScale(with: AudioService.shared.player.averagePowerRate)
        
        self.perform(#selector(self.playTick), with: nil, afterDelay: 0.1)
    }
    
    func cancel() {
        self.transformButtonScale()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
    }
    
    func transformButtonScale(with rate: CGFloat? = nil) {
        UIView.animate(withDuration: 0.05) { [weak self] in
            guard let self = self else { return }
            
            if let rate = rate {
                let value = (rate * 3) + 1.0
                self.actionButton.transform = .init(scaleX: value, y: value)
            } else {
                self.actionButton.transform = .identity
            }
        }
    }
}

extension ViewController {
    enum Status {
        case initialized
        case recording
        case recorded
        case playing
        
        case unavailbale
        
        var actionTitle: String {
            switch self {
            case .initialized: return "RECORD"
            case .recording: return "STOP"
            case .recorded: return "PLAY"
            case .playing: return "STOP"
                
            case .unavailbale: return "ERROR"
            }
        }
        
        var actionColor: UIColor {
            switch self {
            case .initialized: return UIColor.red.withAlphaComponent(0.8)
            case .recording: return UIColor.red.withAlphaComponent(1.0)
            case .recorded: return UIColor.systemBlue.withAlphaComponent(0.8)
            case .playing: return UIColor.systemBlue.withAlphaComponent(1.0)
                
            case .unavailbale: return .gray
            }
        }
    }
}

extension ViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
}

extension TimeInterval {
    var stringValue: String { String(format: "%0.1f", self) }
}

extension Float {
    var sampleFilter: Float {
        switch self {
        case 0..<0.1: return self * 0.1
        case 0..<0.2: return self * 0.2
        case 0..<0.3: return self * 0.5
        case 0..<0.4: return self * 0.7
        default: return self * 0.9
        }
    }
}

//
//  ViewController.swift
//  PGAudioMessage
//
//  Created by ipagong on 04/13/2021.
//  Copyright (c) 2021 ipagong. All rights reserved.
//

import UIKit
import PGAudioMessage

class ViewController: UIViewController {
    
    var url: URL?
    
    @IBOutlet weak var actionButton: UIButton! {
        didSet {
            actionButton.layer.cornerRadius = 50
            actionButton.layer.masksToBounds = true
        }
    }
    
    var status: Status = .initialized { didSet { self.updateUI() } }
    
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
            self.status = .recording
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
            
        case .recording:
            AudioService.shared.stopRecord()
            
        case .recorded:
            guard let url = self.url else { return }
            self.status = .playing
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
            self.perform(#selector(self.recordTick), with: nil, afterDelay: 0.1)
        case .playing:
            self.perform(#selector(self.playTick), with: nil, afterDelay: 0.1)
        default:
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    @objc func recordTick() {
        self.actionButton.setTitle("\(AudioService.shared.recorder.currentTime.stringValue)", for: .normal)
        self.perform(#selector(self.recordTick), with: nil, afterDelay: 0.1)
    }
    
    @objc func playTick() {
        self.actionButton.setTitle("\(AudioService.shared.player.currentTime.stringValue) / \(AudioService.shared.player.duration.stringValue)", for: .normal)
        self.perform(#selector(self.playTick), with: nil, afterDelay: 0.1)
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

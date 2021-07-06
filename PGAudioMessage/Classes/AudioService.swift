//
//  AudioService.swift
//
//  Created by ipagong on 2021/04/14.
//

import UIKit
import AVFoundation

public class AudioService: NSObject {
    
    public static var shared = AudioService()
    
    public typealias ErrorCompletion = ((ErrorType?) -> ())
    
    public var session: AVAudioSession?
    
    public let recorder = Recorder()
    
    public let player = Player()
    
    public var options = Option(numberOfChannels: 1, sampleRate: 44100, qualityType: .high, format: .MPEGAAC)
}

extension AudioService {
    /// Indicates if the session is active.
    public var active: Bool { self.session != .none }
    
    /// Indicates whether recording is in progress.
    public var isRecording: Bool { self.recorder.isRecording }
    
    /// Indicates whether audio playing is in progress.
    public var isPlaying: Bool { self.player.isPlaying }
    
    public func permission(completion: ErrorCompletion? = nil) {
        if AVAudioSession.sharedInstance().recordPermission == .granted {
            completion?(nil)
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            completion?(allowed == true ? nil : .invalidPermission)
        }
    }
}
    
extension AudioService {
    public func activation(completion: ErrorCompletion? = nil) {
        guard self.session == nil else {
            completion?(nil)
            return
        }
        
        self.session = AVAudioSession.sharedInstance()
        
        do {
            try self.session?.setCategory(.playAndRecord, mode: .default)
            try self.session?.overrideOutputAudioPort(.speaker)
            try self.session?.setActive(true)
        } catch {
            completion?(.invalidSession)
        }
        
        completion?(nil)
    }
    
    public func deactivation() {
        guard let session = self.session else { return }
        try? session.setActive(false)
        self.session = nil
    }
}

extension AudioService {
    public func confirm(completion: ErrorCompletion? = nil) {
        self.permission { [weak self] (error) in
            if let error = error {
                completion?(error)
                return
            }
            
            self?.activation { error in
                if let error = error {
                    completion?(error)
                    return
                }
                
                completion?(nil)
            }
        }
    }
    
    public func startRecord(with fileURL: URL? = nil, completion: AudioService.Recorder.Completion? = nil) {
        self.confirm{ [weak self] error in
            if let error = error {
                completion?(.init(value: nil, error: error))
                return
            }
            self?.recorder.start(with: fileURL, completion: completion)
        }
    }
    
    public func stopRecord() {
        self.recorder.stop()
    }
}

extension AudioService {
    public func startPlay(with sound: SoundType, completion: AudioService.Player.Completion? = nil) {
        self.activation{ [weak self] error in
            if let error = error {
                completion?(.init(value: nil, error: error))
                return
            }
            
            self?.player.start(with: sound, completion: completion)
        }
    }
    
    public func stopPlay() {
        self.player.stop()
    }
}

extension CGFloat {
    func transformToRate() -> CGFloat { pow(10, (0.05 * self)) }
}

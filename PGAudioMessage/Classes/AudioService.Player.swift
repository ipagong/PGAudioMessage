//
//  AudioService.Player.swift
//  PGAudioMessage_Example
//
//  Created by ipagong on 2021/04/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

extension AudioService {
    public class Player: NSObject {
        public typealias Completion = ((Swift.Result<SoundType, ErrorType>) -> ())
        
        public var player: AVAudioPlayer?
        
        public var preferVolume: Float? = 1.0
        
        private var completion: Completion?
    }
}

extension AudioService.Player {
    public var isPlaying: Bool { self.player?.isPlaying ?? false }
    
    public var duration: TimeInterval { self.player?.duration ?? 0 }
    
    public var currentTime: TimeInterval { self.player?.currentTime ?? 0 }
    
    public var averagePower: CGFloat? {
        guard let player = self.player, player.isPlaying == true else { return nil }
        guard let count = self.player?.numberOfChannels, count > 0 else { return nil }
        player.updateMeters()
        return Array(0..<count).compactMap{ CGFloat(player.averagePower(forChannel: $0)) }.reduce(0,+) / CGFloat(count)
    }
    
    public var averagePowerRate: CGFloat? { self.averagePower?.transformToRate() }
    
    func start(with soundType: SoundType, completion: AudioService.Player.Completion? = nil) {
        self.completion = completion
        do {
            self.player = try soundType.createPlayer()
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.player?.isMeteringEnabled = true
            if let value = self.preferVolume { self.player?.volume = value }
            self.player?.play()
        } catch {
            debugPrint("player internal error ---> \(error)")
            self.stopped(with: self.player, error: .internalError(error))
        }
    }
    
    func stop() {
        guard let player = self.player, player.isPlaying == true else { return }
            
        self.stopped(with: player, error: nil)
    }
     
    private func stopped(with player: AVAudioPlayer?, error: ErrorType?) {
        self.completion?(.init(sound: SoundType(player: player), error: error))
        self.completion = nil
        
        self.player?.stop()
        self.player = nil
    }
}

extension AudioService.Player: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        debugPrint("\(#function) flag: \(flag)")
        var error: ErrorType? { flag ? nil : .interruptedPlay }
        self.stopped(with: player, error: error)
    }

    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        debugPrint("\(#function) error: \(String(describing: error))")
        var errorValue: ErrorType { (error == nil ? .unknown : .internalError(error!)) }
        self.stopped(with: player, error: errorValue)
    }
}

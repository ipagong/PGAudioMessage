//
//  SoundType.swift
//  PGAudioMessage
//
//  Created by ipagong on 2021/04/16.
//

import Foundation
import AVFoundation

public enum SoundType {
    case url(URL)
    case data(Data)
    
    init?(player: AVAudioPlayer?) {
        if let url = player?.url {
            self = .url(url)
            return
        }
        
        if let data = player?.data {
            self = .data(data)
            return
        }
        
        return nil
    }
    
    func createPlayer() throws -> AVAudioPlayer? {
        switch self {
        case .url(let url): return try AVAudioPlayer(contentsOf: url)
        case .data(let data): return try AVAudioPlayer(data: data)
        }
    }
    
    var invalidError: ErrorType {
        switch self {
        case .url: return .invalidURL
        case .data: return .invalidData
        }
    }
}


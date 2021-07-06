//
//  AudioService.Recorder.Option.swift
//  PGAudioMessage
//
//  Created by damon.p on 2021/04/19.
//

import Foundation
import AVFoundation

extension AudioService {
    public struct Option {
        public let numberOfChannels: Int
        public let sampleRate: Int
        public let qualityType: AudioQuality
        public let format: AudioFormat
        public var bufferSize: AVAudioFrameCount = 1024
        
        public var setting: [String: Any] {
            [
                AVFormatIDKey: self.format.intValue,
                AVSampleRateKey: self.sampleRate,
                AVNumberOfChannelsKey: self.numberOfChannels,
                AVEncoderAudioQualityKey: self.qualityType.intValue
            ]
        }
    }
    
    public enum AudioQuality {
        case min
        case low
        case medium
        case high
        case max
        
        var intValue: Int {
            switch self {
            case .min:    return AVAudioQuality.min.rawValue
            case .low:    return AVAudioQuality.low.rawValue
            case .medium: return AVAudioQuality.medium.rawValue
            case .high:   return AVAudioQuality.high.rawValue
            case .max:    return AVAudioQuality.max.rawValue
            }
        }
    }
    
    public enum AudioFormat {
        case MPEGAAC
        
        public var value: UInt32 {
            switch self {
            case .MPEGAAC: return kAudioFormatMPEG4AAC
            }
        }
        
        public var intValue: Int { Int(self.value) }
        
        public var ext: String {
            switch self {
            case .MPEGAAC: return "aac"
            }
        }
    }
}

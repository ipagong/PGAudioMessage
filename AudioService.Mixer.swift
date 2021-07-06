//
//  AudioService.Mixer.swift
//  PGAudioMessage
//
//  Created by damon.p on 2021/07/06.
//

import Foundation
import AVFoundation

extension AudioService {
    final public class Mixer: NSObject {
        public static var options: AudioService.Option {
            get { AudioService.shared.options }
            set { AudioService.shared.options = newValue }
        }
        
        static var temporaryURL: URL? {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording-mixer.\(Self.options.format.ext)")
        }
    }
}

extension AudioService.Mixer {
    public class Result {
        let file: AVAudioFile
        var isFailed: Bool = false
        
        public init(file: AVAudioFile) { self.file = file }
    }
}

extension AudioService.Mixer {
    public static func fileFromMixer(with engine: AVAudioEngine?,
                                     url: URL? = nil,
                                     options: AudioService.Option = AudioService.Mixer.options) -> AudioService.Mixer.Result? {
        
        guard let engine = engine else { return nil }
        
        guard let url = url ?? Self.temporaryURL else { return nil }
        
        guard let output = try? AVAudioFile(forWriting: url, settings: options.setting) else { return nil }
        
        let result = Result(file: output)
        
        let mixer = engine.mainMixerNode
        let format = mixer.outputFormat(forBus: 0)
        
        mixer.installTap(onBus: 0, bufferSize: options.bufferSize, format: format) { buffer, time in
            do {
                try result.file.write(from: buffer)
            } catch {
                result.isFailed = true
                print(error)
            }
        }
        
        return result
    }
}

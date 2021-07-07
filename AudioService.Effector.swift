//
//  AudioService.Mixer.swift
//  PGAudioMessage
//
//  Created by damon.p on 2021/07/06.
//

import Foundation
import AVFoundation

extension AudioService {
    final public class Effector: NSObject {
        public typealias Completion = ((URL?) -> Void)
        
        private let engine: AVAudioEngine
        private let player: AVAudioPlayerNode?
        
        let effects: [AVAudioUnit]
        
        public var completion: Completion?
        
        public var result: AudioService.Effector.Result?
        
        public init(engine: AVAudioEngine = .init(),
                    player: AVAudioPlayerNode? = nil,
                    effects: [AVAudioUnit],
                    completion: Completion?) {
            self.engine = engine
            self.player = player
            self.effects = effects
            self.completion = completion
        }
    }
}

extension AudioService.Effector {
    public func clear() {
        if self.engine.isRunning == false { return }
        self.engine.stop() 
    }
    
    public static var options: AudioService.Option {
        get { AudioService.shared.options }
        set { AudioService.shared.options = newValue }
    }
    
    public var resultUrl: URL? { self.result?.validUrl }
    
    static var temporaryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording-mixer.\(Self.options.format.ext)")
    }
}

extension AudioService.Effector {
    public func prepare() {
        // make connections
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        let effects = self.effects.compactMap{ $0 as? AVAudioUnitEffect }
        
        effects.forEach{engine.attach($0)}
        
        let connects: [AVAudioNode] = [inputNode] + effects + [self.engine.mainMixerNode]
        
        _ = connects.reduce(into: [AVAudioNode]()) { result, node in
            defer { result.append(node) }

            guard let last = result.last else { return }

            debugPrint("connected from \(last) to \(node)")

            engine.connect(last, to: node, format: format)
        }
        
        engine.prepare()
    }
    
    public func start(url: URL? = nil, options: AudioService.Option = AudioService.Effector.options) {
        guard let url = url ?? Self.temporaryURL else { return }
        
        guard let output = try? AVAudioFile(forWriting: url, settings: [AVFormatIDKey: Self.options.format.value]) else { return }
        
        self.result = Result(file: output, url: url)
        
        let mixer = engine.mainMixerNode
        let format = mixer.outputFormat(forBus: 0)
        
        mixer.installTap(onBus: 0, bufferSize: options.bufferSize, format: format) { [weak self] buffer, time in
            debugPrint(buffer)
            
            guard let self = self else { return }
            do {
                debugPrint("write: \(buffer)")
                try self.result?.file.write(from: buffer)
            } catch {
                self.result?.isFailed = true
                debugPrint(error.localizedDescription)
            }
        }
        
        try? engine.start()
    }
    
    public func pause() {
        self.engine.pause()
    }
    
    public func resume() {
        try? self.engine.start()
    }
    
    public func end() {
        self.completion?(self.result?.validUrl)
        self.clear()
    }
}

extension AudioService.Effector {
    public class Result {
        public let file: AVAudioFile
        public let url: URL
        public var isFailed: Bool = false
        
        public init(file: AVAudioFile, url: URL) {
            self.file = file
            self.url = url
        }
        
        public var validUrl: URL? {
            if isFailed == true { return nil }
            return self.url
        }
    }
}

//
//  AudioService.Recorder.swift
//  PGAudioMessage_Example
//
//  Created by ipagong on 2021/04/15.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import AVFoundation

extension AudioService {
    final public class Recorder: NSObject {
        public typealias Completion = ((Swift.Result<URL, ErrorType>) -> ())
        
        public var recorder: AVAudioRecorder?
        
        private var completion: Completion?
        
        public static var options: AudioService.Option {
            get { AudioService.shared.options }
            set { AudioService.shared.options = newValue }
        }
    }
}

extension AudioService.Recorder {
    public var isRecording: Bool { self.recorder?.isRecording ?? false }
    
    public var currentTime: TimeInterval { self.recorder?.currentTime ?? 0 }
    
    var temporaryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.\(Self.options.format.ext)")
    }
    
    public var averagePower: CGFloat? {
        guard let recorder = self.recorder, recorder.isRecording else { return nil }
        guard Self.options.numberOfChannels > 0 else { return nil }
        recorder.updateMeters()
        return Array(0..<Self.options.numberOfChannels).compactMap{ CGFloat(recorder.averagePower(forChannel: $0)) }.reduce(0,+) / CGFloat(Self.options.numberOfChannels)
    }
    
    public var averagePowerRate: CGFloat? { self.averagePower?.transformToRate() }
    
    func start(with fileURL: URL? = nil, completion: AudioService.Recorder.Completion? = nil) {
        guard let url = fileURL ?? self.temporaryURL else {
            completion?(Swift.Result.init(value: nil, error: ErrorType.invalidURL))
            return
        }
        
        self.completion = completion
        
        do {
            self.recorder = try AVAudioRecorder(url: url, settings: Self.options.setting)
            self.recorder?.isMeteringEnabled = true
            self.recorder?.delegate = self
            self.recorder?.record()
        } catch {
            debugPrint("recorder internal error ---> \(error)")
            self.stopped(with: self.recorder, error: .internalError(error))
        }
    }
    
    public func pause() {
        guard let recorder = self.recorder else { return }
        guard recorder.isRecording == true else { return }
        recorder.pause()
    }
    
    public func resume() {
        guard let recorder = self.recorder else { return }
        guard recorder.currentTime != 0 else { return }
        recorder.record()
    }
    
    func stop() {
        guard let recorder = self.recorder, recorder.isRecording == true else { return }
            
        self.stopped(with: recorder, error: nil)
    }
     
    private func stopped(with recorder: AVAudioRecorder?, error: ErrorType?) {
        let url = recorder?.url
        
        self.completion?(Swift.Result.init(value: url, error: error))
        self.completion = nil
        
        self.recorder?.stop()
        self.recorder = nil
    }
}

extension AudioService.Recorder: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        debugPrint("\(#function) flag: \(flag)")
        var error: ErrorType? { flag ? nil : .interruptedRecord }
        self.stopped(with: recorder, error: error)
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        debugPrint("\(#function) error: \(String(describing: error))")
        var errorValue: ErrorType { (error == nil ? .unknown : .internalError(error!)) }
        self.stopped(with: recorder, error: errorValue)
    }
}

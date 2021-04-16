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
    public class Recorder: NSObject {
        public typealias Completion = ((Swift.Result<URL, ErrorType>) -> ())
        
        public var recorder: AVAudioRecorder?
        
        private var completion: Completion?
    }
}

extension AudioService.Recorder {
    public var isRecording: Bool { self.recorder?.isRecording ?? false }
    
    public var currentTime: TimeInterval { self.recorder?.currentTime ?? 0 }
    
    var temporaryURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("recording.m4a")
    }
    
    func start(with fileURL: URL? = nil, completion: AudioService.Recorder.Completion? = nil) {
        guard let url = fileURL ?? self.temporaryURL else {
            completion?(Swift.Result.init(url: nil, error: .invalidURL))
            return
        }
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        self.completion = completion
        
        do {
            self.recorder = try AVAudioRecorder(url: url, settings: settings)
            self.recorder?.delegate = self
            self.recorder?.record()
        } catch {
            debugPrint("recorder internal error ---> \(error)")
            self.stopped(with: self.recorder, error: .internalError(error))
        }
    }
    
    func stop() {
        guard let recorder = self.recorder, recorder.isRecording == true else { return }
            
        self.stopped(with: recorder, error: nil)
    }
     
    private func stopped(with recorder: AVAudioRecorder?, error: ErrorType?) {
        let url = recorder?.url
        
        self.completion?(Swift.Result.init(url: url, error: error))
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

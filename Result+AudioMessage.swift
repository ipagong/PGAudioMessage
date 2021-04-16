//
//  Result+AudioMessage.swift
//  PGAudioMessage
//
//  Created by ipagong on 2021/04/16.
//

import Foundation

extension Swift.Result where Success == URL, Failure == ErrorType {
    init(url: URL?, error: ErrorType?) {
        if let error = error {
            self = .failure(error)
            return
        }
        
        if let value = url {
            self = .success(value)
        } else {
            self = .failure(.invalidData)
        }
    }
}

extension Swift.Result where Success == SoundType, Failure == ErrorType {
    init(sound: SoundType?, error: ErrorType?) {
        if let error = error {
            self = .failure(error)
            return
        }
        
        if let value = sound {
            self = .success(value)
        } else {
            self = .failure(.invalidData)
        }
    }
}

//
//  Result+AudioMessage.swift
//  PGAudioMessage
//
//  Created by ipagong on 2021/04/16.
//

import Foundation

extension Swift.Result where Failure == ErrorType {
    init(value: Success?, error: ErrorType?) {
        if let error = error {
            self = .failure(error)
            return
        }
        
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(.invalidData)
        }
    }
}

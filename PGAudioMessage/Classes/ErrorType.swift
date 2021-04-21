//
//  ErrorType.swift
//  PGAudioMessage
//
//  Created by ipagong on 2021/04/16.
//

import Foundation
import AVFoundation

public enum ErrorType: Error {
    case invalidData
    case invalidURL
    case invalidPermission
    case invalidSession
    
    case interruptedRecord
    case interruptedPlay
    
    case internalError(Error?)
    case unknown
}

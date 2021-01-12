//
//  errors.swift
//  
//
//  Created by ned on 12/01/21.
//

import Foundation

enum ArgumentError: Error, LocalizedError {
    
    case missingIpa
    case wrongFormat
    case missingDotApp
    case missingInfoPlist
    case missingName
    
    var errorDescription: String? {
        switch self {
        case .missingIpa:
            return "Input file doesn't exist at given path"
        case .wrongFormat:
            return "Input file is not a .ipa or a .app"
        case .missingDotApp:
            return "Unzipped .ipa is missing .app folder"
        case .missingInfoPlist:
            return "Missing Info.plist file"
        case .missingName:
            return "Missing app name in Info.plist"
        }
    }
}

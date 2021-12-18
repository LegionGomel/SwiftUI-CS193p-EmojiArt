//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import Foundation

extension EmojiArtModel {
    
    // Enum with associated data
    enum Background: Equatable {
        case blank
        case url(URL)
        case imageData(Data)
        
        // If enum contains value, return value. In
        // other case return nil
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}

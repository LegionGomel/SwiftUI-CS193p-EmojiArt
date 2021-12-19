//
//  EmojiArtModel.Background.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import Foundation

extension EmojiArtModel {
    
    // Enum with associated data
    // Current implementation (ios 15.2) doesn't required Codable protocol stubs
    // but in the stanford 2021 course it was (maybe 14.5 version)
    enum Background: Equatable, Codable {
        case blank
        case url(URL)
        case imageData(Data)
        
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: .url) {
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        
        // Adding a type String allow us to associate a data to enum.
        enum CodingKeys: String, CodingKey {
            case url = "theURL"
            case imageData
        }
        
        func encode(to encoder: Encoder) throws {
            // CodingKeys.self means that we pass into a Type of enum
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case .blank: break
            }
        }
        
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

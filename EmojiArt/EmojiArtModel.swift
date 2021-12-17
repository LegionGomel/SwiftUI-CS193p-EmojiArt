//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    // Hashable need if we want to use it in a set
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int // Offset from the center
        var y: Int // Offset from the center
        var size: Int
        let id: Int
        
        // fileprivate means anyone in this file can use this but no one else
        // Free init was replaced by this, and now nobody can create init except us in this file
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}

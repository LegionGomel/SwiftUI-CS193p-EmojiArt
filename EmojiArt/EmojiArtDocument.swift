//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject
{
    // Private(set) to access emojiArt but not to change it fom here.
    // Only through a special methods that provided.
    @Published private(set) var emojiArt: EmojiArtModel
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("😀", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🥋", at: (50, 100), size: 80)
    }
    
    // This is made only for cleaner look when accessing emojis via computed property
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index =  emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmooji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) *
                                               scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}

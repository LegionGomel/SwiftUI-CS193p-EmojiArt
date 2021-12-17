//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}

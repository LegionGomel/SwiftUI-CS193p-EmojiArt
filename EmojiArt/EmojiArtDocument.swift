//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 17.12.21.
//

import SwiftUI

// Persistance mostly done in viewModel.
// So, we need to save emojiartDocument somehow
class EmojiArtDocument: ObservableObject
{
    // Private(set) to access emojiArt but not to change it fom here.
    // Only through a special methods that provided.
    // To know when background image is changes, we use
    // property observers
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    private var autosaveTimer: Timer?
    
    // if something change, timer will starts, and at the end will be autosave. But if there
    // another change, and another, timer will cancelled until there is no other changes.
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    // Here we use a file URL to save locally. We take emojiArt model,
    // turn it in a JSON, and store in a bag of bits as Data, and write to URL
    private func save(to url: URL) {
        // with this construction we can have a name for struct and function to print with
        // errors
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? nil)")
            try data.write(to: url)
            print("\(thisFunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error = \(error)")
        }
    }
    
    // For now when a saved document is exists, it will load, else we create a new one,
    // also fetch background image if it exists.
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        } else {
        emojiArt = EmojiArtModel()
//        emojiArt.addEmoji("😀", at: (-200, -100), size: 80)
//        emojiArt.addEmoji("🥋", at: (50, 100), size: 80)
        }
    }
    
    // This is made only for cleaner look when accessing emojis via computed property
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    // This function is happen always when something is changes our background
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage =  nil
        switch emojiArt.background {
        case .url(let url):
            // fetch the url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                // Weak self - redefine self in closure as weak (not to force self to do
                // function, and turning self to optional
                DispatchQueue.main.async { [weak self] in
                    // If URL is current one  that we look for, then to a thing
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
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

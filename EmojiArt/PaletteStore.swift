//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 19.12.21.
//

import SwiftUI

struct Palette: Identifiable, Codable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}

class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }
    
    private func storeInUserDefaults() {
        // palettes.map { [$0.name,$0.emojis,String($0.id)] } creates an array of arrays of strings (PropertyList that we need)
//        UserDefaults.standard.set(palettes.map { [$0.name, $0.emojis, String($0.id)] }, forKey: userDefaultsKey)
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    // Example of bad code with magic numbers and etc, and must be in sync with storeInUserDefauts function
    private func restoreInUserDefaults() {
//        if let palettesAsPropertyList = UserDefaults.standard.array(forKey: userDefaultsKey) as? [[String]] {
//            for paletteAsArray in palettesAsPropertyList {
//                if paletteAsArray.count == 3, let id = Int(paletteAsArray[2]), !palettes.contains(where: { $0.id == id }) {
//                    let palette = Palette(name: paletteAsArray[0], emojis: paletteAsArray[1], id: id)
//                    palettes.append(palette)
//                }
//            }
//        }
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
            let decodedPalettes = try? JSONDecoder().decode(Array<Palette>.self, from: jsonData) {
                palettes = decodedPalettes
            }
    }
    
    init(named name: String) {
        self.name = name
        restoreInUserDefaults()
        if palettes.isEmpty {
            insertPalette(named: "Vehicles", emojis: "🚗🚨🚁⛵️🚅🏍")
            insertPalette(named: "Faces", emojis: "😀🤓😏😎🤬")
        }
    }
    
    // MARK: - Intent

    // if idex is out of bounds it return some palette that is in bounds
    func palette(at index: Int) -> Palette {
        let safeIndex = min(max(index,0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    // function  not allows to remove last palette
    @discardableResult
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    // make sure that inserted palette is unique
    func insertPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(name: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
    
}

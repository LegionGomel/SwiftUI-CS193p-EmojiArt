//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Yuri Ershov on 21.12.21.
//

import SwiftUI

struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font { .system(size: emojiFontSize) }
    
    @EnvironmentObject var store: PaletteStore
    
    // Permanent storage for each scene @SceneStorage
    @SceneStorage("PaletteChooser.chosenPaletteIndex")
    private var choosenPaletteIndex = 0
    
    var body: some View {
        HStack{
            paletteControlButton
            body(for: store.palette(at: choosenPaletteIndex))
        }
        .clipped()
    }
    
    var paletteControlButton: some View {
        Button {
            withAnimation {
                choosenPaletteIndex = (choosenPaletteIndex + 1) % store.palettes.count
            }
            
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
//           editing = true
            paletteToEdit = store.palette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: choosenPaletteIndex)
//            editing = true
            paletteToEdit = store.palette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            choosenPaletteIndex = store.removePalette(at: choosenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        choosenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        // When we change id of hstack it replace a view with a new one, so
        // the transition will work ( because views will be changing instead of
        // draw emojis in that view
        .id(palette.name)
        .transition(rollTransition)
//        .popover(isPresented: $editing) {
//            PaletteEditor(palette: $store.palettes[choosenPaletteIndex])
//        }
        .popover(item: $paletteToEdit) { palette in
            PaletteEditor(palette: $store.palettes[palette])
        }
        .sheet(isPresented: $managing) {
            PaletteManager()
        }
    }
    
    
    @State private var managing = false
//    @State private var editing = false
    // For second method to do popover
    @State private var paletteToEdit: Palette?
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                    // When we drag our emoji then this function is called
                    // It seems to be as prepareForSegue analog and async
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}


struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
    }
}

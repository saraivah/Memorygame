import Foundation

/// A single card in the memory game.
struct Card: Identifiable, Equatable {
    let id = UUID()
    let content: String      // the emoji shown on the front
    var isFaceUp = false     // is the front currently showing?
    var isMatched = false    // has this card been matched (and removed)?
}

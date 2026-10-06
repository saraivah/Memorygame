import SwiftUI
import SwiftUI
import Combine
/// Holds all game state and rules. The views just read from this and call `choose` / `newGame`.
@MainActor
final class MemoryGame: ObservableObject {
    @Published private(set) var cards: [Card] = []

    /// Number of pairs in play. Changing it (via the Picker) starts a new game.
    @Published var numberOfPairs: Int = 6 {
        didSet { newGame() }
    }

    /// Options shown in the "Choose Size" picker (stretch feature).
    let pairOptions = [2, 4, 6, 8, 10]

    private let emojis = ["🔥", "⭐️", "🍕", "🚀", "🐶", "🎸", "🌈", "⚽️", "🍩", "👾", "🦄", "🌵"]

    /// Index of the first card flipped in the current turn (nil if none).
    private var firstFaceUpIndex: Int?
    /// True while two cards are face up and we're waiting to resolve them.
    private var isResolving = false
    /// The pending "check for match" task, so Reset can cancel it.
    private var resolveTask: Task<Void, Never>?

    var isComplete: Bool {
        !cards.isEmpty && cards.allSatisfy(\.isMatched)
    }

    init() {
        newGame()
    }

    /// Shuffles a fresh deck and clears all game-related state.
    func newGame() {
        resolveTask?.cancel()
        resolveTask = nil
        firstFaceUpIndex = nil
        isResolving = false

        let chosenEmojis = emojis.shuffled().prefix(numberOfPairs)
        var newCards: [Card] = []
        for emoji in chosenEmojis {
            newCards.append(Card(content: emoji))
            newCards.append(Card(content: emoji))
        }
        cards = newCards.shuffled()
    }

    /// Called when the user taps a card.
    func choose(_ card: Card) {
        guard !isResolving,
              let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isFaceUp,
              !cards[index].isMatched
        else { return }

        cards[index].isFaceUp = true

        guard let first = firstFaceUpIndex else {
            // This is the first card of the turn.
            firstFaceUpIndex = index
            return
        }

        // This is the second card of the turn: check for a match.
        firstFaceUpIndex = nil
        isResolving = true
        let isMatch = cards[first].content == cards[index].content

        resolveTask = Task { [weak self] in
            // Give the player a moment to see both cards.
            try? await Task.sleep(nanoseconds: isMatch ? 600_000_000 : 1_000_000_000)
            guard let self, !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.3)) {
                if isMatch {
                    self.cards[first].isMatched = true
                    self.cards[index].isMatched = true
                } else {
                    self.cards[first].isFaceUp = false
                    self.cards[index].isFaceUp = false
                }
            }
            self.isResolving = false
        }
    }
}

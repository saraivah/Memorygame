import SwiftUI

struct ContentView: View {
    @StateObject private var game = MemoryGame()

    // 3 columns like the example screenshot
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        VStack(spacing: 16) {
            header

            if game.isComplete {
                Text("🎉 You found all the pairs!")
                    .font(.title3.bold())
                    .transition(.scale.combined(with: .opacity))
            }

            // ScrollView lets the user see cards that don't fit on screen (stretch feature)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(game.cards) { card in
                        CardView(card: card)
                            .onTapGesture { game.choose(card) }
                            .allowsHitTesting(!card.isMatched)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding(.top)
        .animation(.spring(), value: game.isComplete)
    }

    private var header: some View {
        HStack {
            // "Choose Size" menu containing a Picker (stretch feature)
            Menu {
                Picker("Number of pairs", selection: $game.numberOfPairs) {
                    ForEach(game.pairOptions, id: \.self) { count in
                        Text("\(count) pairs").tag(count)
                    }
                }
            } label: {
                Text("Choose Size")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.orange))
            }

            Spacer()

            // Reset button: reshuffles and clears state (required feature)
            Button {
                withAnimation { game.newGame() }
            } label: {
                Text("Reset Game")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.green))
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

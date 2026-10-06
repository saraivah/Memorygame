import SwiftUI

/// Draws one card: blue back when face down, emoji front when face up.
struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            // Front
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black, lineWidth: 3)
                )
                .overlay(
                    Text(card.content)
                        .font(.system(size: 44))
                )
                .opacity(card.isFaceUp ? 1 : 0)

            // Back
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue)
                .opacity(card.isFaceUp ? 0 : 1)
        }
        .aspectRatio(2/3, contentMode: .fit)
        // Flip animation around the vertical axis
        .rotation3DEffect(.degrees(card.isFaceUp ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 0.35), value: card.isFaceUp)
        // Matched cards fade/shrink away but keep their spot in the grid
        .opacity(card.isMatched ? 0 : 1)
        .scaleEffect(card.isMatched ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.3), value: card.isMatched)
    }
}

#Preview {
    HStack {
        CardView(card: Card(content: "🔥"))
        CardView(card: Card(content: "🔥", isFaceUp: true))
    }
    .padding()
}

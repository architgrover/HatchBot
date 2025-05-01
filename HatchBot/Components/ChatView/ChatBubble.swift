//
//  ChatBubble.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct ChatBubble: View {
    var message: Message
    var onDelete: (Message) -> Void
        
    private var bubbleAlignment: Alignment {
        message.isUser ? .trailing : .leading
    }

    private var bubbleColor: Color {
        message.isUser ? .accentColor : .secondary.opacity(0.5)
    }
    
    private let maxBubbleWidth = UIScreen.main.bounds.width * 0.70

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            VStack(alignment: bubbleAlignment.horizontal) {
                Text(message.text)
                    .padding(10)
                    .background(bubbleColor)
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .frame(maxWidth: maxBubbleWidth, alignment: bubbleAlignment)
                if !message.images.isEmpty {
                    let computedWidth = CGFloat(message.images.count * 80 + (message.images.count - 1) * 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(message.images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .frame(width: min(computedWidth, UIScreen.main.bounds.width))
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: maxBubbleWidth, alignment: bubbleAlignment)
            if !message.isUser {
                Spacer()
            }
        }
        .padding(.vertical, 5)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(message)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

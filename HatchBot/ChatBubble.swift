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

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            VStack(alignment: message.isUser ? .trailing : .leading) {
                Text(message.text)
                    .padding(10)
                    .background(message.isUser ? Color.blue : Color.gray)
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .frame(maxWidth: 250, alignment: message.isUser ? .trailing : .leading)

                if !message.images.isEmpty {
                    if message.isUser {
                        Spacer()
                    }

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
                    .frame(width: computedWidth)

                    if !message.isUser {
                        Spacer()
                    }
                }

            }
            .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
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

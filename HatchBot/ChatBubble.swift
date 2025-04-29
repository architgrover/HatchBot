//
//  ChatBubble.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct ChatBubble: View {
    var message: Message
    var onDelete: (Message) -> Void // Closure to delete the message

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

                if !message.images.isEmpty {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(message.images, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }

            if !message.isUser {
                Spacer()
            }
        }
        .padding(.vertical, 5)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(message) // Call the delete function passed from the parent
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

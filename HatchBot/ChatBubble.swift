//
//  ChatBubble.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct ChatBubble: View {
    let message: Message

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading) {
            if !message.images.isEmpty {
                HStack {
                    ForEach(message.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

//
//  ChatMessageList.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-30.
//

import SwiftUI

struct ChatMessageList: View {
    @Binding var messages: [Message]
    @Binding var keyboardHeight: CGFloat
    @Binding var bottomSheetHeight: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if messages.isEmpty {
                    emptyChatView
                } else {
                    messageList
                        .padding(.bottom, bottomSheetHeight + keyboardHeight)
                }
            }
        }
    }
    
    private var emptyChatView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Nothing here yet. Let’s hatch a conversation! 🐣")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            Spacer()
        }
    }
    
    private var messageList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(messages) { msg in
                    ChatBubble(message: msg, onDelete: deleteMessage)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .id(msg.id)
                }
            }
            .scrollContentBackground(.hidden)
            .onChange(of: messages.count) { _,_ in scrollToLastMessage(proxy: proxy) }
            .onChange(of: keyboardHeight) { _,_ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToLastMessage(proxy: proxy)
                }
            }
        }
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        guard let last = messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.35)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
    
    private func deleteMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
    }
}

//
//  ContentView.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import Combine
import PhotosUI

struct ChatView: View {
    @State private var message = ""
    @State private var messages: [Message] = []
    @State private var sheetState: SheetState = .compact
    @State private var fontSize: CGFloat = DynamicFontSettings.large
    @State private var selectedImages: [UIImage] = []
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(messages) { msg in
                                ChatBubble(message: msg)
                            }
                        }
                        .padding()
                    }
                }
            }
            .blur(radius: sheetState == .expanded ? 5 : 0)
            .disabled(sheetState == .expanded)
            .onTapGesture {
                withAnimation {
                    sheetState = .expanded // Open sheet when tapping anywhere in the chat
                }
            }
            
            if sheetState == .expanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            sheetState = .compact // Close sheet when tapping the overlay
                            isFocused = false
                        }
                    }
            }
            
            BottomSheet(
                message: $message,
                selectedImages: $selectedImages,
                onSend: sendMessage,
                sheetState: $sheetState,
                fontSize: $fontSize
            )
            .focused($isFocused)
        }
        .navigationTitle("Chat with AI")
    }

    func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = Message(id: UUID(), images: selectedImages, text: message, isUser: true)
        messages.append(userMessage)
        message = ""
    }
}

struct HorizontalImageScroll: View {
    @Binding var selectedImages: [UIImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(selectedImages, id: \.self) { image in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 5))

                        Button(action: {
                            selectedImages.removeAll { $0 == image }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .offset(x: -8, y: -8)
                        }
                    }
                }
            }
        }
    }
}

struct Message: Identifiable, Equatable {
    var id: UUID
    let images: [UIImage]?
    var text: String
    var isUser: Bool
}

#Preview {
    ChatView()
}

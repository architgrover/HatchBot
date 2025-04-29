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
    @State private var messages: [Message] = [] // List of messages
    @State private var sheetState: SheetState = .compact
    @State private var fontSize: CGFloat = DynamicFontSettings.large
    @State private var selectedImages: [UIImage] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showPicker = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                List {
                    ForEach(messages) { msg in
                        ChatBubble(message: msg, onDelete: deleteMessage)
                            .listRowSeparator(.hidden) // Hides separator for smoother UI
                            .listRowBackground(Color.clear) // Keeps background transparent
                    }
                }
                .scrollContentBackground(.hidden) // Removes default list background
            }
            .blur(radius: sheetState == .expanded ? 5 : 0)
            .disabled(sheetState == .expanded)

            if sheetState == .expanded {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation {
                            sheetState = .compact
                            isFocused = false
                            showPicker = false
                        }
                    }
            }

            BottomSheet(
                message: $message,
                selectedImages: $selectedImages,
                onSend: sendMessage,
                sheetState: $sheetState,
                fontSize: $fontSize,
                showPicker: $showPicker,
                selectedPhotoItems: $selectedPhotoItems
            )
            .focused($isFocused)
        }
        .navigationTitle("Chat with AI")
        .onAppear {
            PHPhotoLibrary.requestAuthorization { status in
                print("Photo Library Access: \(status)")
            }
        }
    }

    func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let userMessage = Message(id: UUID(), images: selectedImages, text: message, isUser: true)
        messages.append(userMessage)
        message = ""
        selectedImages.removeAll() // Clear selected images after sending
    }

    func deleteMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            withAnimation {
                messages.remove(at: index) // Delete the message from the array
            }
        }
    }
}

struct Message: Identifiable, Equatable {
    var id: UUID
    let images: [UIImage]
    var text: String
    var isUser: Bool
}

#Preview {
    ChatView()
}

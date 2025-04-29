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
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showPicker = false
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
                    sheetState = .expanded
                }
            }
            
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

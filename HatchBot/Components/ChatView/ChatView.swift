//
//  ContentView.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

struct ChatView: View {
    @State private var message = ""
    @State private var showPicker = false
    @State private var messages: [Message] = []
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0
    @State private var selectedImages: [UIImage] = []
    @State private var sheetState: SheetState = .compact
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var fontSize: CGFloat = DynamicFontSettings.large
    
    @FocusState private var isFocused: Bool
    
    let aiIsTyping = Message(
        id: UUID(), images: [],
        text: "Hatch bot is typing...",
        isUser: false
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ChatMessageList(
                messages: $messages,
                keyboardHeight: $keyboardHeight,
                bottomSheetHeight: $bottomSheetHeight
            )
            if sheetState == .expanded {
                Color.black.opacity(0.3).ignoresSafeArea().transition(.opacity).onTapGesture {
                    withAnimation { sheetState = .compact; isFocused = false; showPicker = false }
                }
            }
            BottomSheet(
                message: $message,
                fontSize: $fontSize,
                showImagePicker: $showPicker,
                sheetState: $sheetState,
                selectedImages: $selectedImages,
                onSend: sendMessage
            )
            .background(GeometryReader { geo in
                Color.clear
                    .onAppear { bottomSheetHeight = geo.size.height }
                    .onChange(of: geo.size.height) { _, newHeight in bottomSheetHeight = newHeight }
            })
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            .focused($isFocused)
            .ignoresSafeArea(.keyboard)
        }
        .onAppear { setupKeyboardObservers() }
        .onDisappear { removeKeyboardObservers() }
        .navigationTitle("Chat with Hatch!")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
        .overlay(Spacer().frame(height: 1).foregroundColor(.gray), alignment: .top)
    }
    
    // MARK: - Functions
    private func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let userMessage = Message(id: UUID(), images: selectedImages, text: message, isUser: true)
        messages.append(userMessage)
        message = ""
        selectedImages.removeAll()
        mockAIResponse(text: userMessage.text, images: userMessage.images)
    }
    
    private func mockAIResponse(text: String, images: [UIImage]) {
        messages.append(aiIsTyping)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            messages.removeLast()
            let aiResponse = Message(id: UUID(), images: images, text: text, isUser: false)
            messages.append(aiResponse)
        }
    }
    
    private func deleteMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = frame.height
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

#Preview {
    ChatView()
}

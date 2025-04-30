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
    @State private var selectedImages: [UIImage] = []
    @State private var sheetState: SheetState = .compact
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var fontSize: CGFloat = DynamicFontSettings.large

    @FocusState private var isFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @State private var bottomSheetHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                GeometryReader { geometry in
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
                        .padding(.top, 46)
                        .padding(.bottom, bottomSheetHeight + keyboardHeight)
                        .onChange(of: messages.count) { _ in
                            scrollToLastMessage(proxy: proxy)
                        }
                        .onChange(of: keyboardHeight) { _ in
                            // Scroll on keyboard show
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                scrollToLastMessage(proxy: proxy)
                            }
                        }
                    }
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
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            bottomSheetHeight = geo.size.height
                        }
                        .onChange(of: geo.size.height) { newHeight in
                            bottomSheetHeight = newHeight
                        }
                }
            )
            .offset(y: -keyboardHeight) // 👈 this moves the sheet up with keyboard
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            .focused($isFocused)

        }
        .ignoresSafeArea()
        .navigationTitle("Chat with AI")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.white, for: .navigationBar)
        .toolbar(.visible, for: .navigationBar)
        .overlay(
            VStack {
                Divider()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                Spacer()
            },
            alignment: .top
        )
        .onAppear {
            PHPhotoLibrary.requestAuthorization { status in
                print("Photo Library Access: \(status)")
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notif in
                if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardHeight = frame.height
                    }
                }
            }

            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }

    func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let userMessage = Message(id: UUID(), images: selectedImages, text: message, isUser: true)
        messages.append(userMessage)

        message = ""
        selectedImages.removeAll()

        mockAIResponse(text: userMessage.text, images: userMessage.images)
    }

    func mockAIResponse(text: String, images: [UIImage]) {
        let aiIsTyping = Message(id: UUID(), images: [], text: "AI is typing...", isUser: false)
        messages.append(aiIsTyping)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            messages.removeLast()
            let aiResponse = Message(id: UUID(), images: images, text: "AI: \(text)", isUser: false)
            messages.append(aiResponse)
        }
    }

    func deleteMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.id == message.id }) {
            messages.remove(at: index)
        }
    }

    func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let last = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
}

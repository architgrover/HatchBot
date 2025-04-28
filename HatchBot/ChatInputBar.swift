//
//  ChatInputBar.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var isSending: Bool
    var onSend: () -> Void

    @State private var isExpanded = false
    @State private var textHeight: CGFloat = 40
    @State private var keyboardHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var fontSize: CGFloat = 16
    @State private var isKeyboardVisible = false
    @State private var debounceFontSize: CGFloat = 18
    @FocusState private var isTextEditorFocused: Bool

    private let minHeight: CGFloat = 40
    private let containerPadding: CGFloat = 16
    private let maxTextLines: Int = 10
    private let lineHeight: CGFloat = 24
    private let dismissalThreshold: CGFloat = 100
    private let chips = ["Hello", "Quick question", "Summarize", "Explain", "Translate"]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            ZStack(alignment: .bottom) {
                backgroundDimmingView
                mainContentView
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { notification in
            handleKeyboard(notification: notification)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.spring()) {
                keyboardHeight = 0
                isKeyboardVisible = false
            }
        }
    }

    private var backgroundDimmingView: some View {
        Color.black.opacity(isExpanded ? 0.3 : 0)
            .ignoresSafeArea()
            .onTapGesture {
                if isExpanded {
                    withAnimation(.spring()) {
                        isExpanded = false
                        isTextEditorFocused = false
                    }
                }
            }
    }

    private var mainContentView: some View {
        VStack(spacing: 0) {
            chipsView
            bottomSheetView()
        }
    }

    private var chipsView: some View {
        Group {
            if !isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(chips, id: \.self) { chip in
                            Button(action: { text += chip + " " }) {
                                Text(chip)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .clipShape(Capsule())
                            }
                            .accessibilityLabel("Insert \(chip)")
                        }
                    }
                    .padding(.horizontal, containerPadding)
                    .padding(.vertical, 8)
                }
                .transition(.opacity)
            }
        }
    }

    private func bottomSheetView() -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.vertical, 8)

            expandButton
            textInputView
            sendButton
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding(.bottom, keyboardHeight)
        .animation(.spring(), value: keyboardHeight)
    }

    private var expandButton: some View {
        HStack {
            Button(action: toggleExpansion) {
                Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .accessibilityLabel(isExpanded ? "Minimize" : "Expand")
            Spacer()
        }
        .padding(.horizontal, containerPadding)
        .padding(.bottom, 8)
    }

    private var textInputView: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Start Typing...")
                    .font(.system(size: fontSize))
                    .foregroundColor(.gray)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            }

            TextEditor(text: $text)
                .font(.system(size: fontSize))
                .frame(minHeight: minHeight, maxHeight: isExpanded ? UIScreen.main.bounds.height * 0.5 : textHeight)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3))
                )
                .focused($isTextEditorFocused)
                .onChange(of: text) { _ in
                    updateTextHeight()
                }
                .accessibilityLabel("Chat input")
        }
        .padding(.horizontal, containerPadding)
        .padding(.vertical, 8)
    }

    private var sendButton: some View {
        HStack {
            Spacer()
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(isSending ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(isSending || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, containerPadding)
        .padding(.bottom, containerPadding)
    }

    private func toggleExpansion() {
        withAnimation(.spring()) {
            isExpanded.toggle()
            isTextEditorFocused = isExpanded
            fontSize = isExpanded ? 18 : 16
        }
    }

    private func updateTextHeight() {
        let screenWidth = UIScreen.main.bounds.width
        let textAreaWidth = screenWidth - (containerPadding * 2 + 12 * 2)
        let attributedText = NSAttributedString(string: text.isEmpty ? " " : text, attributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        let textRect = attributedText.boundingRect(with: CGSize(width: textAreaWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)

        let lineCount = Int(ceil(textRect.height / lineHeight))
        let wrappedLineCount = min(lineCount, maxTextLines)

        let newFontSize: CGFloat
        if wrappedLineCount > (maxTextLines * 2 / 3) {
            newFontSize = max(14, fontSize - 2)
        } else if wrappedLineCount <= maxTextLines / 2 {
            newFontSize = min(18, fontSize + 2)
        } else {
            newFontSize = fontSize
        }

        // Debouncing font size changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            debounceFontSize = newFontSize
        }
    }


    private func handleKeyboard(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        let screenHeight = UIScreen.main.bounds.height
        let keyboardTop = keyboardFrame.origin.y
        let newKeyboardHeight = max(0, screenHeight - keyboardTop)

        withAnimation(.spring()) {
            keyboardHeight = newKeyboardHeight
            isKeyboardVisible = newKeyboardHeight > 0
        }
    }
}

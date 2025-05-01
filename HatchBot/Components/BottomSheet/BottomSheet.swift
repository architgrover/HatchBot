//
//  BottomSheet.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct BottomSheet: View {
    @Binding var message: String
    @Binding var fontSize: CGFloat
    @Binding var showImagePicker: Bool
    @Binding var sheetState: SheetState
    @Binding var selectedImages: [UIImage]
    
    @FocusState private var isTextFieldFocused: Bool
    @GestureState private var dragOffset: CGFloat = 0
    @State private var wasPickerOpenInExpanded = false
    
    var onSend: () -> Void
    
    private let chips = ["🚀 Let's go!", "🔥 Lit!", "💡 Genius!", "🎉 Party time!", "😂 LOL", "❤️ Love it!"]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            if showImagePicker && sheetState == .expanded {
                expandedPickerView
            } else {
                compactContent
            }
            if !(showImagePicker && sheetState == .expanded) {
                footerControls
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
        .offset(y: dragOffset)
        .gesture(dragGesture)
        .transaction { transaction in
            transaction.animation = .easeInOut(duration: 0.3)
        }
    }
}

// MARK: - Components
private extension BottomSheet {
    var header: some View {
        ZStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 12)
            
            HStack {
                Spacer()
                Button(action: toggleSheetState) {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.trailing, 12)
                }
            }
        }
    }
    
    var compactContent: some View {
        VStack(spacing: 0) {
            chipSuggestions
            DynamicTextEditor(
                text: $message,
                fontSize: $fontSize,
                sheetState: $sheetState
            )
            .frame(maxHeight: sheetState.height)
            .padding(.horizontal)
            .padding(.bottom, 8)
            .focused($isTextFieldFocused)
            .onChange(of: isTextFieldFocused) { _, focused in
                if focused {
                    showImagePicker = false
                    wasPickerOpenInExpanded = false
                }
            }
            if !selectedImages.isEmpty {
                HorizontalImageScrollView(selectedImages: $selectedImages)
            }
            if showImagePicker && sheetState == .compact {
                ImagePickerGrid(selectedImages: $selectedImages)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }
        }
    }
    
    var chipSuggestions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(chips, id: \.self) { chip in
                    Text(chip)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                        .onTapGesture {
                            message += " \(chip)"
                        }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
    
    var expandedPickerView: some View {
        VStack(spacing: 0) {
            if !selectedImages.isEmpty {
                HorizontalImageScrollView(selectedImages: $selectedImages)
                    .transition(.opacity)
            }
            ImagePickerGrid(selectedImages: $selectedImages)
            .frame(maxHeight: 650)
            .transition(.move(edge: .bottom))
        }
        .padding(.top, 44)
    }
    
    var footerControls: some View {
        HStack {
            BottomControls(
                onSend: onSend,
                showImagePicker: Binding(
                    get: { showImagePicker },
                    set: { newValue in
                        withAnimation {
                            if newValue && sheetState == .expanded {
                                sheetState = .compact
                                wasPickerOpenInExpanded = false
                            }
                            isTextFieldFocused = false
                            showImagePicker = newValue
                        }
                    }
                )
            )
        }
        .padding(.horizontal)
    }
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.height
            }
            .onEnded { value in
                withAnimation {
                    if value.translation.height < -100 {
                        sheetState = .expanded
                        isTextFieldFocused = false
                        if showImagePicker {
                            wasPickerOpenInExpanded = true
                        }
                    } else if value.translation.height > 100 {
                        sheetState = .compact
                        isTextFieldFocused = false
                        showImagePicker = wasPickerOpenInExpanded
                        wasPickerOpenInExpanded = false
                    }
                }
            }
    }
    
    func toggleSheetState() {
        withAnimation {
            isTextFieldFocused = false
            sheetState.toggle()
            if sheetState == .compact && !wasPickerOpenInExpanded {
                showImagePicker = false
            }
        }
    }
}


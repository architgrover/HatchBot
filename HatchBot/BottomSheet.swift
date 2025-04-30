//
//  BottomSheet.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

struct BottomSheet: View {
    @Binding var message: String
    @Binding var selectedImages: [UIImage]
    var onSend: () -> Void
    @Binding var sheetState: SheetState
    @Binding var fontSize: CGFloat
    @Binding var showPicker: Bool
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    @GestureState private var dragOffset: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var wasPickerOpenInExpanded: Bool = false
    
    let chips: [String] = ["🚀 Let's go!", "🔥 Lit!", "💡 Genius!", "🎉 Party time!", "😂 LOL", "❤️ Love it!"]

    var body: some View {
        VStack(spacing: 0) {
            // Header with toggle button
            ZStack {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 12)
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isTextFieldFocused = false
                            if sheetState == .expanded && showPicker {
                                sheetState = .compact
                                wasPickerOpenInExpanded = false
                            } else {
                                sheetState = sheetState == .expanded ? .compact : .expanded
                                if sheetState == .compact && !wasPickerOpenInExpanded {
                                    showPicker = false
                                }
                            }
                        }
                    }) {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                            .padding(.trailing, 12)
                    }
                }
            }

            // Content based on state
            if showPicker && sheetState == .expanded {
                // Photo grid in expanded state, anchored to top of content with extra padding
                VStack(spacing: 0) {
                    if !selectedImages.isEmpty {
                        HorizontalImageScrollView(selectedImages: $selectedImages)
                            .transition(.opacity)
                    }
                    ImagePickerGrid(selectedImages: $selectedImages, selectedPhotoItems: $selectedPhotoItems)
                        .frame(maxHeight: 650)
                        .transition(.move(edge: .bottom))
                }
                .padding(.top, 44) // Increased padding to avoid overlap with nav bar
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(chips, id: \.self) { suggestion in
                                        Text(suggestion)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(20)
                                            .onTapGesture {
                                                message += " \(suggestion)"
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                .padding([.top, .bottom], 8)
                
                // Show text field in compact or when picker is not open in expanded
                DynamicTextEditor(text: $message, fontSize: $fontSize)
                    .frame(minHeight: 80, maxHeight: sheetState == .expanded ? 300 : 120)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { focused in
                        if focused {
                            showPicker = false
                            wasPickerOpenInExpanded = false
                        }
                    }
                    .transition(.opacity)

                if !selectedImages.isEmpty {
                    HorizontalImageScrollView(selectedImages: $selectedImages)
                        .transition(.opacity)
                }

                if showPicker && sheetState == .compact {
                    ImagePickerGrid(selectedImages: $selectedImages, selectedPhotoItems: $selectedPhotoItems)
                        .frame(height: 300)
                        .transition(.move(edge: .bottom))
                }
            }

            // Bottom controls, hidden in expanded picker mode
            if !(showPicker && sheetState == .expanded) {
                HStack {
                    BottomControls(
                        onSend: onSend,
                        showPicker: Binding(
                            get: { showPicker },
                            set: { newValue in
                                withAnimation {
                                    if newValue {
                                        if sheetState == .expanded {
                                            // If expanded, go to compact before showing picker
                                            sheetState = .compact
                                            wasPickerOpenInExpanded = false
                                        }
                                        isTextFieldFocused = false
                                    }
                                    showPicker = newValue
                                }
                            }
                        ),
                        safeBottom: 0
                    )
                }
                .padding(.horizontal)
                .transition(.opacity)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 10)
        )
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.height < -100 {
                            sheetState = .expanded
                            isTextFieldFocused = false
                            if showPicker {
                                wasPickerOpenInExpanded = true
                            }
                        } else if value.translation.height > 100 {
                            sheetState = .compact
                            isTextFieldFocused = false
                            if wasPickerOpenInExpanded {
                                showPicker = true
                            } else {
                                showPicker = false
                            }
                            wasPickerOpenInExpanded = false
                        }
                    }
                }
        )
        .animation(.easeInOut(duration: 0.3), value: sheetState)
        .animation(.easeInOut(duration: 0.3), value: showPicker)
    }
}

extension PhotosPickerItem {
    func loadUIImage() async -> UIImage? {
        do {
            if let imageData = try await self.loadTransferable(type: Data.self),
               let image = UIImage(data: imageData) {
                return image
            }
        } catch {
            print("Failed to load image:", error)
        }
        return nil
    }
}

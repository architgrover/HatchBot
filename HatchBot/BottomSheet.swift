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

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray.opacity(0.5))
                    .padding(.top, 12)

                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            sheetState = sheetState == .expanded ? .compact : .expanded
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

            DynamicTextEditor(text: $message, fontSize: $fontSize)
                .frame(minHeight: 80, maxHeight: sheetState == .expanded ? 300 : 120)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { focused in
                    if focused {
                        showPicker = false
                    }
                }

            if !selectedImages.isEmpty {
                HorizontalImageScrollView(selectedImages: $selectedImages)
                    .transition(.opacity)
            }

            if showPicker {
                ImagePickerGrid(selectedImages: $selectedImages, selectedPhotoItems: $selectedPhotoItems)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }

            HStack {
                BottomControls(
                    onSend: onSend,
                    showPicker: Binding(
                        get: { showPicker },
                        set: { newValue in
                            withAnimation {
                                showPicker = newValue
                                if newValue {
                                    isTextFieldFocused = false // hide keyboard
                                }
                            }
                        }
                    ),
                    safeBottom: 0
                )
            }
            .padding(.horizontal)
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
                    if value.translation.height < -100 {
                        withAnimation {
                            sheetState = .expanded
                        }
                    } else if value.translation.height > 100 {
                        withAnimation {
                            sheetState = .compact
                            showPicker = false
                        }
                    }
                }
        )
        .animation(.easeInOut(duration: 0.3), value: sheetState)
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

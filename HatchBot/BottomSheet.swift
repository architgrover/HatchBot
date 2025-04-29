//
//  BottomSheet.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

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

    var body: some View {
        VStack(spacing: 10) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            DynamicTextEditor(text: $message, fontSize: $fontSize)
                .frame(minHeight: 80, maxHeight: sheetState == .expanded ? 300 : 120)
                .padding(.horizontal)
                .padding(.bottom, 8)

            if !selectedImages.isEmpty {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 5) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(10)
                }
                .transition(.opacity)
            }

            // INLINE IMAGE PICKER (Keyboard-sized)
            if showPicker {
                ImagePickerGrid(selectedImages: $selectedImages, selectedPhotoItems: $selectedPhotoItems)
                    .frame(height: 300) // Mimic keyboard height
                    .transition(.move(edge: .bottom))
            }

            HStack {
                Button(action: {
                    showPicker.toggle() // Show picker inline
                }) {
                    Image(systemName: "photo.on.rectangle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                Spacer()
                SendMessageButton(action: onSend)
            }
            .padding([.leading, .trailing, .bottom], 16)
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
                        sheetState = .expanded
                    } else if value.translation.height > 100 {
                        sheetState = .compact
                        showPicker = false
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

struct ImageSelectionButton: View {
    @Binding var sheetState: SheetState
    @Binding var selectedImages: [UIImage]
    @State private var showImagePicker = false

    var body: some View {
        Button(action: { showImagePicker.toggle() }) {
            Image(systemName: "photo.on.rectangle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerSheet(sheetState: $sheetState, selectedImages: $selectedImages)
        }
    }
}

struct SendMessageButton: View {
    var action : () -> Void
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: "paperplane.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
}

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

    @State private var dragOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0
    @GestureState private var isDragging = false

    let compactHeight: CGFloat = 150
    let expandedHeight: CGFloat = 500

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
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(4)

                                Button(action: {
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .padding(4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            if showPicker {
                ImagePickerGrid(selectedImages: $selectedImages, selectedPhotoItems: $selectedPhotoItems)
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }

            HStack {
                Button(action: {
                    if selectedImages.count < 10 {
                        showPicker.toggle()
                    }
                }) {
                    Image(systemName: "photo.on.rectangle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(selectedImages.count >= 10)

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
        .frame(height: sheetHeight)
        .offset(y: dragOffset)
        .gesture(
            DragGesture()
                .updating($isDragging) { _, state, _ in
                    state = true
                }
                .onChanged { value in
                    dragOffset = value.translation.height + currentOffset
                }
                .onEnded { value in
                    let velocity = value.predictedEndTranslation.height

                    if dragOffset + velocity < -100 {
                        expandSheet()
                    } else if dragOffset + velocity > 100 {
                        collapseSheet()
                    } else {
                        resetSheet()
                    }
                }
        )
        .animation(.interactiveSpring(), value: dragOffset)
        .onChange(of: sheetState) { _ in
            updateOffset()
        }
        .onAppear {
            updateOffset()
        }
    }

    private var sheetHeight: CGFloat {
        sheetState == .expanded ? expandedHeight : compactHeight
    }

    private func expandSheet() {
        withAnimation(.spring()) {
            sheetState = .expanded
            dragOffset = 0
            currentOffset = 0
            triggerHaptic()
        }
    }

    private func collapseSheet() {
        withAnimation(.spring()) {
            sheetState = .compact
            dragOffset = 0
            currentOffset = 0
            showPicker = false
            triggerHaptic()
        }
    }

    private func resetSheet() {
        withAnimation(.spring()) {
            dragOffset = 0
        }
    }

    private func updateOffset() {
        currentOffset = 0
        dragOffset = 0
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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

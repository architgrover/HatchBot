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

    var body: some View {
        VStack(spacing: 10) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        sheetState = sheetState == .compact ? .expanded : .compact
                        if sheetState == .compact {
                            showPicker = false
                        }
                    }
                }) {
                    Image(systemName: sheetState == .compact ? "chevron.up" : "chevron.down")
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .padding(.trailing)
            }

            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: selectedImages[index])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))

                                Button(action: {
                                    selectedImages.remove(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .offset(x: 5, y: -5)
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

            DynamicTextEditor(text: $message, fontSize: $fontSize)
                .frame(minHeight: 80, maxHeight: sheetState == .expanded && !showPicker ? 300 : 120)
                .padding(.horizontal)

            HStack {
                Button(action: {
                    withAnimation {
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
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -100 {
                        withAnimation { sheetState = .expanded }
                    } else if value.translation.height > 100 {
                        withAnimation {
                            sheetState = .compact
                            showPicker = false
                        }
                    }
                }
        )
        .offset(y: dragOffset)
        .animation(.easeInOut(duration: 0.3), value: sheetState)
        .ignoresSafeArea(edges: .bottom)
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

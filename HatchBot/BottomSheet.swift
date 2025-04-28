//
//  BottomSheet.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct BottomSheet: View {
    @Binding var message: String
    @Binding var selectedImages: [UIImage]
    var onSend: () -> Void
    @Binding var sheetState: SheetState
    @Binding var fontSize: CGFloat
    
    @GestureState private var dragOffset = CGSize.zero
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 10) {
            // Drag Handle
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            // Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(["Hello", "Quick question", "Summarize", "Explain"], id: \.self) { chip in
                        Text(chip)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }

            if !selectedImages.isEmpty {
                HorizontalImageScroll(selectedImages: $selectedImages)
            }

            // Text Editor
            DynamicTextEditor(text: $message, fontSize: $fontSize)
                .frame(minHeight: 80, maxHeight: sheetState == .expanded ? 300 : 120)
                .padding(.horizontal)
                .padding(.bottom, 8)

            HStack {
                ImageSelectionButton(sheetState: $sheetState, selectedImages: $selectedImages)
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
        .offset(y: offsetY)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onChanged { value in
                    offsetY = max(0, value.translation.height)
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.4)) {
                        sheetState = value.translation.height > 100 ? .compact : .expanded
                    }
                    offsetY = 0
                }
        )
        .animation(.easeInOut(duration: 0.3), value: sheetState)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.4)) {
                sheetState = .expanded
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

//
//  BottomSheet.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct BottomSheet: View {
    @Binding var message: String
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
            
            // Text Editor
            DynamicTextEditor(text: $message, fontSize: $fontSize)
                .frame(minHeight: 80, maxHeight: sheetState == .expanded ? 300 : 120)
                .padding(.horizontal)
                .padding(.bottom, 8)
            
            // Send Button
            Button(action: {
                onSend()
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .padding(.bottom, 16)
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
                    if value.translation.height > 100 {
                        withAnimation {
                            sheetState = .compact
                        }
                    }
                    offsetY = 0
                }
        )
        .animation(.easeInOut, value: offsetY)
        .onTapGesture {
            withAnimation {
                sheetState = .expanded
            }
        }
    }
}

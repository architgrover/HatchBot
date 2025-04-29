//
//  BottomControls.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct BottomControls: View {
    var onSend: () -> Void
    @Binding var showPicker: Bool
    var safeBottom: CGFloat

    var body: some View {
        HStack {
            // Photo Picker Button
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

            // Send Message Button
            SendMessageButton(action: onSend)
        }
        .padding(.horizontal)
        .padding(.bottom, max(safeBottom, 16)) // Adjusted bottom padding
    }
}


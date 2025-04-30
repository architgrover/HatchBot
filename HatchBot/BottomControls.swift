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

    var body: some View {
        HStack {
            PhotoPickerButton(showPicker: $showPicker)
            Spacer()
            SendMessageButton(action: onSend)
        }
        .padding(.horizontal)
        .padding(.bottom, 16)
    }
}

struct PhotoPickerButton: View {
    @Binding var showPicker: Bool

    var body: some View {
        Button(action: {
                showPicker.toggle()
        }) {
            Image(systemName: "photo.on.rectangle.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
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

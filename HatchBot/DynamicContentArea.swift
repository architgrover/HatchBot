//
//  DynamicContentArea.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

struct DynamicContentArea: View {
    @Binding var message: String
    @Binding var fontSize: CGFloat
    @Binding var sheetState: SheetState
    var showPicker: Bool
    @Binding var selectedImages: [UIImage]

    var body: some View {
        VStack(spacing: 0) {
            // Text editor area
            DynamicTextEditor(text: $message, fontSize: $fontSize, sheetState: $sheetState)
                .frame(minHeight: 80, maxHeight: showPicker ? 100 : 200)
                .padding(.horizontal)
                .padding(.top, 8)

            // Image picker grid
            if showPicker {
                ImagePickerGrid(selectedImages: .constant(selectedImages))
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}


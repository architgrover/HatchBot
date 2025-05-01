//
//  DynamicContentArea.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct DynamicContentArea: View {
    var showPicker: Bool
    
    @Binding var message: String
    @Binding var fontSize: CGFloat
    @Binding var sheetState: SheetState
    @Binding var selectedImages: [UIImage]
    
    var body: some View {
        VStack(spacing: 0) {
            DynamicTextEditor(
                text: $message,
                fontSize: $fontSize,
                sheetState: $sheetState
            )
            .frame(minHeight: 80, maxHeight: showPicker ? 100 : 200)
            .padding(.horizontal)
            .padding(.top, 8)
            if showPicker {
                ImagePickerGrid(selectedImages: .constant(selectedImages))
                    .frame(height: 300)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}

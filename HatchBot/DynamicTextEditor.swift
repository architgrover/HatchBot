//
//  DynamicTextEditor.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct DynamicTextEditor: View {
    @Binding var text: String
    @Binding var fontSize: CGFloat
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: fontSize))
            .frame(minHeight: 80)
            .scrollContentBackground(.hidden)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
            .onChange(of: text) { _, _ in
                adjustFontSize()
            }
    }
    
    private func adjustFontSize() {
        let characterCount = text.count
        if characterCount > 200 {
            fontSize = DynamicFontSettings.small
        } else if characterCount > 100 {
            fontSize = DynamicFontSettings.medium
        } else {
            fontSize = DynamicFontSettings.large
        }
    }
}

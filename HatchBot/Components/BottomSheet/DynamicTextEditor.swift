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
    @Binding var sheetState: SheetState

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.system(size: fontSize))
                .frame(minHeight: 80)
                .scrollContentBackground(.hidden)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)

            if text.isEmpty {
                Text("Start Typing...")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 12)
            }
        }
        .onChange(of: text) { _, _ in
            fontSize = sheetState == .expanded ? DynamicFontSettings.large : text.dynamicFontSize()
        }
        .onChange(of: sheetState) { _, newState in
            withAnimation(.easeInOut(duration: 0.3)) {
                fontSize = newState == .expanded ? DynamicFontSettings.large : text.dynamicFontSize()
            }
        }
    }
}

// MARK: - Font Size Logic
private extension String {
    func dynamicFontSize() -> CGFloat {
        switch count {
        case 0...100:
            return DynamicFontSettings.large
        case 101...200:
            return DynamicFontSettings.medium
        default:
            return DynamicFontSettings.small
        }
    }
}

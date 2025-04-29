//
//  HorizontalImageScroll.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

import SwiftUI

struct HorizontalImageScroll: View {
    @Binding var selectedImages: [UIImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(selectedImages.indices, id: \.self) { index in
                    ZStack {
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        // Delete button to unselect image
                        Button(action: {
                            // Remove the image at the current index
                            selectedImages.remove(at: index)
                        }) {
                            Image(systemName: "x.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                                .padding(4)
                        }
                        .position(x: 70, y: 10)  // Position the "delete" button at the top-right corner of the image
                    }
                }
            }
            .padding(10)
        }
    }
}

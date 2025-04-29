//
//  HorizontalImageScroll.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI

struct HorizontalImageScrollView: View {
    @Binding var selectedImages: [UIImage]

    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(selectedImages, id: \.self) { image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button(action: {
                            removeImage(image)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .offset(x: 0, y: 0)
                    }
                }
            }
        }
    }

    func removeImage(_ image: UIImage) {
        selectedImages.removeAll { $0 == image }
    }
}

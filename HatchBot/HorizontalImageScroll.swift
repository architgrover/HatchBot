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
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            if let index = selectedImages.firstIndex(of: image) {
                                selectedImages.remove(at: index)
                            }
                        }
                }
            }
        }
    }
}


//
//  ImagePicker.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

struct ImagePickerSheet: View {
    @Binding var sheetState: SheetState
    @Binding var selectedImages: [UIImage]
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            Text("Select Photos")
                .font(.headline)
                .padding(.top, 8)

            // Image grid displays selections
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 5) {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        Image(uiImage: selectedImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(10)
            }

            // Hidden PhotosPicker to handle selection
            PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                Text("Tap to Choose")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .onChange(of: selectedPhotoItems) { newItems in
                Task {
                    await loadImages(from: newItems)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .frame(maxHeight: 300)
        .animation(.easeInOut, value: sheetState)
    }

    func loadImages(from items: [PhotosPickerItem]) async {
        for item in items {
            if let image = await item.loadUIImage() {
                DispatchQueue.main.async {
                    selectedImages.append(image)
                }
            }
        }
    }
}


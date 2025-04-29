//
//  ImagePickerGrid.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import SwiftUI
import PhotosUI

struct ImagePickerGrid: View {
    @Binding var selectedImages: [UIImage]
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    @State private var libraryImages: [UIImage] = []

    var body: some View {
        VStack {
            Text("Select Photos")
                .font(.headline)
                .padding(.top, 8)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 5) {
                    ForEach(libraryImages.indices, id: \.self) { index in
                        Image(uiImage: libraryImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                if selectedImages.count < 10 {
                                    selectedImages.append(libraryImages[index])
                                }
                            }
                    }
                }
                .padding(10)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .frame(maxHeight: 300)
        .onAppear {
            fetchLibraryImages()
        }
    }

    private func fetchLibraryImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 30
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let manager = PHCachingImageManager()

        DispatchQueue.global(qos: .userInitiated).async {
            assets.enumerateObjects { asset, _, _ in
                manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
                    if let image = image {
                        DispatchQueue.main.async {
                            libraryImages.append(image)
                        }
                    }
                }
            }
        }
    }
}


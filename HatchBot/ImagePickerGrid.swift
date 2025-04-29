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
    
    let tileSize: CGFloat = UIScreen.main.bounds.width / 3 - 5

    var body: some View {
        VStack {
            Text("Select Photos")
                .font(.headline)
                .padding(.top, 8)

            // Show fetched library images directly
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 5) {
                    ForEach(libraryImages.indices, id: \.self) { index in
                        Image(uiImage: libraryImages[index])
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: tileSize, height: tileSize)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture {
                                print("Tapped on image at index \(index)")
                                selectedImages.append(libraryImages[index])
                                print("Selected images count: \(selectedImages.count)")
                            }
                    }
                }
                .padding(10)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .frame(maxHeight: 300) // Mimic keyboard height
        .onAppear {
            fetchLibraryImages()
        }
    }

    func fetchLibraryImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 15

        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let manager = PHImageManager.default()

        assets.enumerateObjects { asset, _, _ in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        libraryImages.append(image)
                    }
                }
            }
        }
    }
}


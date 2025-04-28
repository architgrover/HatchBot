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
    @State private var showFullGallery = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []

    var body: some View {
        VStack {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            if !showFullGallery {
                // Semi-expanded image grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 5) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    sheetState = .compact
                                }
                        }
                    }
                    .padding(10)
                }
            }

            PhotosPicker(selection: $selectedPhotoItems, matching: .images) {
                Text("Select Photos")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .onChange(of: selectedPhotoItems) { newItems in
                loadImages(from: newItems)
                sheetState = .expanded // Expand after selecting
            }

            Button("Expand Gallery") {
                showFullGallery.toggle()
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .frame(maxHeight: showFullGallery ? 500 : 250)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.height < -50 {
                        showFullGallery = true
                    } else if value.translation.height > 50 {
                        showFullGallery = false
                    }
                }
        )
        .animation(.easeInOut, value: showFullGallery)
    }

    func loadImages(from items: [PhotosPickerItem]) {
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                if let imageData = try? result.get(), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
}

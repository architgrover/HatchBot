//
//  ImagePickerGrid 2.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-30.
//

import SwiftUI
import PhotosUI

// MARK: - ImagePickerGrid
struct ImagePickerGrid: View {
    @Binding var selectedImages: [UIImage]
    @State private var libraryImages: [UIImage] = []
    @State private var isLoading = true
    @State private var permissionDenied = false
    
    private let tileSize: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Select Photos")
                .font(.headline)
                .padding(.top, 8)
                .padding(.bottom, 4)
            
            if isLoading {
                ProgressView("Loading photos...")
                    .padding()
            } else if permissionDenied {
                Text("Photo library access denied. Please enable in Settings.")
                    .foregroundColor(.red)
                    .padding()
            } else if libraryImages.isEmpty {
                Text("No photos available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: tileSize, maximum: tileSize), spacing: 8)
                    ], spacing: 8) {
                        ForEach(libraryImages.indices, id: \.self) { index in
                            ZStack {
                                Image(uiImage: libraryImages[index])
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: tileSize, height: tileSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .contentShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(
                                        selectedImages.contains(where: { $0.cgImage == libraryImages[index].cgImage }) ?
                                        Color.blue.opacity(0.3).clipShape(RoundedRectangle(cornerRadius: 8)) : nil
                                    ) // Highlight selected images
                                    .border(selectedImages.contains(where: { $0.cgImage == libraryImages[index].cgImage }) ? Color.blue : Color.clear, width: 4)
                                    .onTapGesture {
                                        if let selectedIndex = selectedImages.firstIndex(where: { $0.cgImage == libraryImages[index].cgImage }) {
                                            // Deselect image
                                            selectedImages.remove(at: selectedIndex)
                                        } else {
                                            // Select image
                                            selectedImages.append(libraryImages[index])
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .onAppear {
            checkPhotoLibraryPermission()
        }
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            fetchLibraryImages()
        case .denied, .restricted:
            permissionDenied = true
            isLoading = false
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.fetchLibraryImages()
                    } else {
                        self.permissionDenied = true
                        self.isLoading = false
                    }
                }
            }
        @unknown default:
            permissionDenied = true
            isLoading = false
        }
    }
    
    func fetchLibraryImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 15
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        
        var loadedImages: [UIImage] = []
        
        assets.enumerateObjects { asset, _, _ in
            manager.requestImage(for: asset, targetSize: CGSize(width: tileSize * 2, height: tileSize * 2), contentMode: .aspectFill, options: requestOptions) { image, info in
                if let image = image, let degraded = info?[PHImageResultIsDegradedKey] as? Bool, !degraded {
                    DispatchQueue.main.async {
                        loadedImages.append(image)
                        self.libraryImages = loadedImages
                        self.isLoading = false
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.libraryImages.isEmpty && !self.permissionDenied {
                self.isLoading = false
            }
        }
    }
}


//
//  PhotosPickerItemExtension.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-30.
//

import SwiftUI
import PhotosUI

// MARK: - Async UIImage Loader Extension
extension PhotosPickerItem {
    func loadUIImage() async -> UIImage? {
        do {
            if let data = try await self.loadTransferable(type: Data.self) {
                return UIImage(data: data)
            }
        } catch {
            print("Image loading failed: \(error)")
        }
        return nil
    }
}

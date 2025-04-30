//
//  Message.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-29.
//

import SwiftUI

struct Message: Identifiable, Equatable {
    var id: UUID
    let images: [UIImage]
    var text: String
    var isUser: Bool
}

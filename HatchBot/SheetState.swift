//
//  SheetState.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import Foundation

enum SheetState {
    case compact
    case expanded
    
    mutating func toggle() {
        self = self == .compact ? .expanded : .compact
    }
}

struct DynamicFontSettings {
    static let large: CGFloat = 18
    static let medium: CGFloat = 16
    static let small: CGFloat = 14
}

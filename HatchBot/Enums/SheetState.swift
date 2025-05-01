//
//  SheetState.swift
//  HatchBot
//
//  Created by Archit Grover on 2025-04-28.
//

import UIKit

enum SheetState {
    case compact
    case expanded
    
    mutating func toggle() {
        self = self == .compact ? .expanded : .compact
    }
    
    var height: CGFloat {
        switch self {
        case .compact:
            return UIScreen.main.bounds.height / 6
        case .expanded:
            return UIScreen.main.bounds.height / 3
        }
    }
}

struct DynamicFontSettings {
    static let large: CGFloat = 18
    static let medium: CGFloat = 16
    static let small: CGFloat = 14
}

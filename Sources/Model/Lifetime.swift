//
//  Lifetime.swift
//  
//
//  Created by Stefan Blos on 30.03.22.
//
import Foundation

/// The Lifetime is controlling the longevity of elements on the screen. That means if the lifetime is shorter, the elements will disappear earlier, while for longer lifetimes they will stay on the screen for longer time.
public enum Lifetime: Hashable, CaseIterable {
    /// the shortest lifetime (very brief)
    case brief
    /// Elements only stay for the screen for a short amount of time
    case short
    /// Elements will stay on the screen for a longer time and will then disappear.
    case medium
    /// Elements will stay on the screen for a long time and only then disappear.
    case long
    var duration: TimeInterval {
        switch self {
        case .brief:
            return 0.2
        case .short:
            return 1
        case .medium:
            return 2
        case .long:
            return 4
        }
    }
}

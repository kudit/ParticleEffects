//
//  FadeOut.swift
//  
//
//  Created by Stefan Blos on 30.03.22.
//
import Foundation

/// The FadeOut describes how fast elements will fade into translucency.
///
/// This control is applied to each particle of the effect and not the effect itself. It is somewhat related to the `lifetime` (see ``Lifetime``) but wheres the `lifetime` will apruptly remove the particle entirely from the screen the fadeout will slowly reduce the opacity of each particle and has a way more subtle effect.
///
/// The 4 possible values are:
/// - `.none`: The particles will never fade out. Default
/// - `.quick`: The particles will fade out and disappear quickly.
/// - `.moderate`: The particles will face out over a medium time period.
/// - `.lengthy`: The particles will only slowly fade out.
public enum FadeOut: Hashable, CaseIterable, Sendable {
    case none, quick, moderate, lengthy
    var multiplier: TimeInterval {
        switch self {
        case .none:
            return 0
        case .quick:
            return 0.1
        case .moderate:
            return 0.5
        case .lengthy:
            return 1
        }
    }
}

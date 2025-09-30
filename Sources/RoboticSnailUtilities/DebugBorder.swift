//
//  DebugBorder.swift
//  
//
//  Created by Joe Beaudoin on 8/2/22.
//

import Foundation
import SwiftUI

public struct DebugBorder: ViewModifier {
    let color: Color
    
    public init(color: Color) { self.color = color }
    
    public func body(content: Content) -> some View {
        content.overlay(Rectangle().stroke(color))
    }
}

public extension View {
    func debugBorder(color: Color = .blue) -> some View {
        #if DEBUG
        return self.overlay(Rectangle().stroke(color))
        #else
        return self
        #endif
    }
}


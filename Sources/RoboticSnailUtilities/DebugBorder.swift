//
//  DebugBorder.swift
//  
//
//  Created by Joe Beaudoin on 8/2/22.
//

import Foundation
import SwiftUI

struct DebugBorder: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content.overlay(Rectangle().stroke(color))
    }
}

extension View {
    func debugBorder(color: Color = .blue) -> some View {
        #if DEBUG
        return self.overlay(Rectangle().stroke(color))
        #else
        return self
        #endif
    }
}

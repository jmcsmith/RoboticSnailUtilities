//
//  Extensions.swift
//  
//
//  Created by Joe Beaudoin on 8/2/22.
//

import Foundation
import SwiftUI
import CoreData

extension TextField {
    @ViewBuilder
    func editingStyle(if flag: Bool) -> some View {
        if flag {
            self.textFieldStyle(RoundedBorderTextFieldStyle())
        } else {
            self.textFieldStyle(PlainTextFieldStyle())
        }
    }
}

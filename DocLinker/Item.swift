//
//  Item.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

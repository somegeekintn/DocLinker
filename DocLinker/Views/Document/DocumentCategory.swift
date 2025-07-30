//
//  DocumentCategory.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/30/25.
//

import SwiftUI

struct DocumentCategory: View {
    let category: Document.Category

    var body: some View {
        Image(systemName: category.symbol)
    }
}

extension Document.Category {
    var symbol: String {
        switch self {
        case .general:      "document"          // "g.square"
        case .thumbnail:    "person"            // "t.square"
        case .photo:        "photo"             // "p.square"
        case .census:       "text.document"     // "c.square"
        case .birth:        "birthday.cake"     // "b.square"
        case .death:        "sunset"            // "d.square"
        case .marriage:     "heart"             // "m.square"
        case .military:     "figure.hunting"    // "multiply.square"
        }
    }
}

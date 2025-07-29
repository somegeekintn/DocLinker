//
//  DocumentRow.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct DocumentRow: View {
    let doc: Document

    init(_ doc: Document) {
        self.doc = doc
    }

    var body: some View {
        HStack {
            if let thumbnail = doc.thumbnailImage {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32)
            }
            Text(doc.filename)
        }
    }
}

#Preview {
    if let doc = try? Document(fileURL: URL(fileURLWithPath: "/Users/casey")) {
        DocumentRow(doc)
    }
    else {
        Text("Failed")
    }
}

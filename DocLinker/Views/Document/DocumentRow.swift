//
//  DocumentRow.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct DocumentRow: View {
    @AppStorage(.rootPath) var rootPath: URL?
    @Environment(\.revealItem) var revealItem

    let doc: Document
    let inNavigator: Bool
    var filenameDisplay: String { doc.displayPath(root: rootPath) }

    init(_ doc: Document, inNavigator: Bool) {
        self.doc = doc
        self.inNavigator = inNavigator
    }

    var body: some View {
        HStack {
            if let thumbnail = doc.thumbnailImage {
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(filenameDisplay)
                .font(.body)
        }
        .frame(height: 24)
        .contextMenu {
            if !inNavigator {
                Button("Reveal in Navigator") { revealItem(.documents(doc)) }
            }
            Button("Reveal in Finder") { NSWorkspace.shared.activateFileViewerSelecting([doc.fileURL]) }
        }
    }

}

#Preview {
    if let doc = try? Document(fileURL: URL(fileURLWithPath: "/Users/casey")) {
        DocumentRow(doc, inNavigator: false)
    }
    else {
        Text("Failed")
    }
}

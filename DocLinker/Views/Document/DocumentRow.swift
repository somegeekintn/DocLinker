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
    var filenameDisplay: String { doc.displayPath(root: rootPath) }

    init(_ doc: Document) {
        self.doc = doc
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
            Spacer()
            DocumentCategory(category: doc.category)
        }
        .frame(height: 24)
        .contextMenu {
            Button("Reveal in Finder") { NSWorkspace.shared.activateFileViewerSelecting([doc.fileURL]) }
            Menu("Category") {
                ForEach(Document.Category.allCases) { category in
                    Button(category.displayText) { doc.category = category }
                }
            }
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

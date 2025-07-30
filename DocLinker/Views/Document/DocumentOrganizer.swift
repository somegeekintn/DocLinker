//
//  DocumentOrganizer.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct DocumentOrganizer: View {
    @Environment(\.modelContext) var modelContext
    @State var presentFiles: Bool = false
    @State var dropTargeted: Bool = false
    @Binding var selection: Document?

    var dropTargetColor: Color { dropTargeted ? .green : .clear }

    init(selection: Binding<Document?>) {
        self._selection = selection
    }

    var body: some View {
        VStack {
            DocumentList(query: Document.defaultQuery, selection: $selection)
            Spacer()
            Button(action: { presentFiles = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "document.badge.plus")
                    Text("Add Item")
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
        }
        .border(dropTargetColor)
        .onDrop(of: [.fileURL], isTargeted: $dropTargeted, perform: handleDroppedItems)
        .fileImporter(isPresented: $presentFiles, allowedContentTypes: [.item], onCompletion: completeFileSelection)
    }

    func handleDroppedItems(items: [NSItemProvider]) -> Bool {
        for item in items {
            if item.canLoadObject(ofClass: URL.self) {
                _ = item.loadObject(ofClass: URL.self) { url, _ in
                    if let url {
                        Task { await addDocumentFrom(url: url) }
                    }
                }
            }
        }

        return true
    }

    func completeFileSelection(result: Result<URL, any Error>) {
        guard let fileURL = try? result.get() else { return }

        addDocumentFrom(url: fileURL)
    }

    func addDocumentFrom(url: URL) {
        withAnimation { Document.addDocumentFrom(url: url, context: modelContext); return }
    }
}

#Preview {
    DocumentOrganizer(selection: .constant(nil))
}

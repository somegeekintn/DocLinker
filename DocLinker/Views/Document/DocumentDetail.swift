//
//  DocumentDetail.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct DocumentDetail: View {
    @Environment(\.displayScale) var displayScale
    @State var doc: Document
    @State var personSelection: Person? = nil
    @State var previewData: Data? = nil

    var previewImage: NSImage? { guard let previewData else { return nil }; return NSImage(data: previewData) }
    var docmage: NSImage? { previewImage ?? doc.thumbnailImage }

    init(_ doc: Document) {
        self._doc = State(initialValue: doc)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("URL: \(doc.fileURL.path)")
                HStack {
                    Picker("Category", selection: $doc.category) {
                        ForEach(Document.Category.allCases) { category in
                            Text(category.displayText)
                        }
                    }
                    .frame(maxWidth: 240)
                }
                TextField("Notes", text: $doc.notes, axis: .vertical)

                Toggle("Incomplete", isOn: $doc.incomplete)
                    .toggleStyle(.checkbox)
                
                if let docmage {
                    Image(nsImage: docmage)
                        .border(.secondary)
                        .padding(.top)
                }
                
                Text("People")
                List(selection: $personSelection) {
                    ForEach(doc.people, id: \.self) { person in
                        PersonRow(person)
                    }
                }
                .frame(height: 320)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .onAppear(perform: handleAppearance)
    }

    func handleAppearance() {
        doc.generateThumbnail()
        previewData = doc.previewData

        if previewData == nil {
            Task {
                let imageData = try await doc.fileURL.generateImageData(size: CGSize(width: 640, height: 480), scale: displayScale)

                doc.previewData = imageData
                withAnimation { self.previewData = imageData }
            }
        }
    }
}

#Preview {
    if let doc = try? Document(fileURL: URL(fileURLWithPath: "/Users/casey")) {
        DocumentDetail(doc)
    }
    else {
        Text("Failed")
    }
}

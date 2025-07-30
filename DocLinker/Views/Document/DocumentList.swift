//
//  DocumentList.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct DocumentList: View {
    @Environment(\.modelContext) var modelContext
    @Query var docs: [Document]
    @State var presentFiles: Bool = false
    @State var dropTargeted: Bool = false
    @Binding var selection: Document?

    var dropTargetColor: Color { dropTargeted ? .green : .clear }

    init(query: Query<Document, [Document]>, selection: Binding<Document?>) {
        self._docs = query
        self._selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(docs) { doc in
                NavigationLink(value: doc) { DocumentRow(doc, inNavigator: true) }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.sidebar)
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(docs[index])
            }
        }
    }
}

#Preview {
    DocumentList(query: Document.defaultQuery, selection: .constant(nil))
}

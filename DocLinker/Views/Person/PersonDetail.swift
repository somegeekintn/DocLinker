//
//  PersonDetail.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData
import OSLog

struct PersonDetail: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.revealItem) var revealItem
    @State var person: Person
    @State var dropTargeted: Bool = false
    @State var docSelection: Document? = nil

    let minimalVersion: Bool
    var dropTargetColor: Color { dropTargeted ? .green : .clear }

    init(_ person: Person, minimalVersion: Bool = false) {
        self._person = State(initialValue: person)
        self.minimalVersion = minimalVersion
    }

    var body: some View {
        if minimalVersion {
            fieldsView
        }
        else {
            fullVersion
                .navigationTitle("\(person.firstName) \(person.lastName)")
        }
    }

    @ViewBuilder
    var fieldsView: some View {
        VStack {
            HStack {
                HStack(spacing: 0) {
                    Text("I")
                    TextField("ID", value: $person.identifier, format: .number.grouping(.never)).frame(maxWidth: 64)
                }
                TextField("First", text: $person.firstName)
                TextField("Last", text: $person.lastName)
            }

            TextField("Notes", text: $person.notes, axis: .vertical)
        }
        .padding(.bottom)
    }

    @ViewBuilder
    var fullVersion: some View {
        VStack {
            fieldsView
            Text("Items")
            List(selection: $docSelection) {
                ForEach(person.docs, id: \.self) { doc in
                    DocumentRow(doc)
                }
            }
            .contextMenu(forSelectionType: Document.self,
                menu: { items in },
                primaryAction: { items in
                    if let doc = items.first {
                        revealItem(.documents(doc))
                    }
                })
        }
        .padding()
        .border(dropTargetColor)
        .padding()
        .onDrop(of: [.fileURL], isTargeted: $dropTargeted, perform: handleDroppedItems)
    }

    func handleDroppedItems(items: [NSItemProvider]) -> Bool {
        for item in items {
            if item.canLoadObject(ofClass: URL.self) {
                _ = item.loadObject(ofClass: URL.self) { url, _ in
                    if let url {
                        Task { await addItemFrom(url: url) }
                    }
                }
            }
        }

        return true
    }

    func addItemFrom(url: URL) {
        do {
            let doc = try Document.addDocumentFrom(url: url, context: modelContext).get()

            if !doc.people.contains(where: { $0.id == person.id }) {
                withAnimation { doc.people.append(person) }
            }
        }
        catch { }
    }
}

#Preview {
    PersonDetail(Person(identifier: 123, firstName: "John", lastName: "Doe"))
}

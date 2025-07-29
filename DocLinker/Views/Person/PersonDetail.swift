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

    var fieldsView: some View {
        HStack {
            TextField("ID", text: $person.identifier).frame(maxWidth: 64)
            TextField("First", text: $person.firstName)
            TextField("Last", text: $person.lastName)
        }
        .padding(.bottom)
    }

    var fullVersion: some View {
        VStack {
            fieldsView
            Text("Items")
            List(selection: $docSelection) {
                ForEach(person.docs, id: \.self) { doc in
                    DocumentRow(doc, inNavigator: false)
                }
            }
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
            let docs = try modelContext.fetch(FetchDescriptor<Document>(predicate: #Predicate {$0.fileURL == url }))
            let doc = try docs.first ?? Document(fileURL: url)

            withAnimation { doc.people.append(person) }
        }
        catch {
            Logger.app.error("Failed to add new item: \(error)")
        }
    }
}

#Preview {
    PersonDetail(Person(identifier: "Preview", firstName: "John", lastName: "Doe"))
}

//
//  ContentView.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var itemSelection = ItemSelection.people(nil)

    var documentSelection: Binding<Document?> {
        Binding(
            get: { itemSelection.document },
            set: { itemSelection = .documents($0) }
        )
    }

    var personSelection: Binding<Person?> {
        Binding(
            get: { itemSelection.person },
            set: { itemSelection = .people($0) }
        )
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ForEach(ItemSelection.Category.allCases, id: \.self) { category in
                        SimpleButton(label: category.tabName, imageName: category.tabImage, selected: itemSelection.category == category) {
                            withAnimation { itemSelection = category.defaultSelection }
                        }
                    }
                }

                Divider()

                Group {
                    switch itemSelection {
                    case .people:       PersonOrganizer(selection: personSelection)
                    case .documents:    DocumentOrganizer(selection: documentSelection)
                    }
                }
                .padding(.bottom)
            }
            .navigationDestination(for: Document.self, destination: documentDetail)
            .navigationDestination(for: Person.self, destination: personDetail)
            .navigationSplitViewColumnWidth(min: 264, ideal: 320)
        } detail: {
            Text("Select an item")
        }
    }

    @ViewBuilder
    func documentDetail(for document: Document) -> some View {
        DocumentDetail(document)
            .id(document.fileURL)
            .environment(\.revealItem, .init(handleItemReveal))
    }

    @ViewBuilder
    func personDetail(for person: Person) -> some View {
        PersonDetail(person)
            .id(person.identifier)
            .environment(\.revealItem, .init(handleItemReveal))
    }

    func handleItemReveal(_ selection: ItemSelection) {
        withAnimation { itemSelection = selection }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Document.self, Person.self], inMemory: true)
}

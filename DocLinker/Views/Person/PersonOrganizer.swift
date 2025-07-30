//
//  PersonOrganizer.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct PersonOrganizer: View {
    enum Sorting {
        case name(_ reversed: Bool)
        case id(_ reversed: Bool)

        var isName: Bool { guard case .name = self else { return false }; return true }
        var isID: Bool { guard case .id = self else { return false }; return true }

        @MainActor
        var query: Query<Person, [Person]> {
            switch self {
            case let .name(reversed):
                let order: SortOrder = reversed ? .reverse : .forward

                return Query(sort: [SortDescriptor(\.lastName, order: order), SortDescriptor(\.firstName, order: order)])
            case let .id(reversed):
                return Query(sort: \.id, order: reversed ? .reverse : .forward)
            }
        }
    }

    @Environment(\.modelContext) var modelContext
    @State var newPerson: Person?
    @State var validationError: Bool = false
    @State var sorting = Sorting.id(false)
    @Binding var selection: Person?

    var nameImages: [String] {
        var images: [String] = ["person.text.rectangle"]

        if case let .name(reversed) = sorting {
            images.insert(reversed ? "arrow.down" : "arrow.up", at: 0)
        }

        return images
    }

    var idImages: [String] {
        var images: [String] = ["key.card"]

        if case let .id(reversed) = sorting {
            images.insert(reversed ? "arrow.down" : "arrow.up", at: 0)
        }

        return images
    }

    init(selection: Binding<Person?>) {
        self._selection = selection
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                SimpleButton(label: "Name", imageNames: nameImages, selected: sorting.isName, action: sortByName)
                SimpleButton(label: "ID", imageNames: idImages, selected: sorting.isID, action: sortByID)
            }
            Divider()
            PersonList(query: sorting.query, selection: $selection)
            Spacer()
            Divider()
            Button(action: { prepareNewPerson() }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Add Person")
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
        }
        .sheet(item: $newPerson) { person in
            VStack {
                Text("Add New Person")

                PersonDetail(person, minimalVersion: true)

                if validationError {
                    Text("Missing required fields").foregroundStyle(.red)
                        .padding(.bottom)
                }

                HStack {
                    Button("Cancel", role: .cancel) { newPerson = nil }
                    Button("Okay", role: .destructive) { insertPerson(person) }
                }
            }
            .padding()
            .onSubmit { insertPerson(person) }
        }
    }

    func prepareNewPerson() {
        newPerson = Person(identifier: 0, firstName: "", lastName: "")
    }

    func insertPerson(_ person: Person) {
        withAnimation {
            if person.identifier == 0 || person.firstName.isEmpty || person.lastName.isEmpty {
                validationError = true
            }
            else {
                modelContext.insert(person)
                validationError = false
                newPerson = nil
            }
        }
    }

    func sortByName() {
        if case let .name(reversed) = sorting {
            sorting = .name(!reversed)
        }
        else {
            sorting = .name(false)
        }
    }

    func sortByID() {
        if case let .id(reversed) = sorting {
            sorting = .id(!reversed)
        }
        else {
            sorting = .id(false)
        }
    }
}

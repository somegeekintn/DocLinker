//
//  PersonOrganizer.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct PersonOrganizer: View {
    @Environment(\.modelContext) var modelContext
    @State var newPerson: Person?
    @State var validationError: Bool = false

    var body: some View {
        VStack {
            PersonList(query: Person.defaultQuery)
            Spacer()
            Button(action: { prepareNewPerson() }) {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Add Person")
                }
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
        newPerson = Person(identifier: "", firstName: "", lastName: "")
    }

    func insertPerson(_ person: Person) {
        withAnimation {
            if person.identifier.isEmpty || person.firstName.isEmpty || person.lastName.isEmpty {
                validationError = true
            }
            else {
                modelContext.insert(person)
                validationError = false
                newPerson = nil
            }
        }
    }
}

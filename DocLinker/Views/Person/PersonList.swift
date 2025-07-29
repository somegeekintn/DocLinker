//
//  PersonList.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct PersonList: View {
    @Environment(\.modelContext) var modelContext
    @Query var people: [Person]

    init(query: Query<Person, [Person]>) {
        self._people = query
    }

    var body: some View {
        List {
            ForEach(people) { person in
                NavigationLink(value: person) { PersonRow(person) }
            }
            .onDelete(perform: deleteItems)

        }
    }

    func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(people[index])
            }
        }
    }
}

#Preview {
    PersonList(query: Person.defaultQuery)
}

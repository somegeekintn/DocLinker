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
    @Binding var selection: Person?

    init(query: Query<Person, [Person]>, selection: Binding<Person?>) {
        self._people = query
        self._selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(people) { person in
                NavigationLink(value: person) { PersonRow(person, inNavigator: true) }
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
    PersonList(query: Person.defaultQuery, selection: .constant(nil))
}

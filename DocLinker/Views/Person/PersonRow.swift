//
//  PersonRow.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct PersonRow: View {
    @Environment(\.openURL) var openURL
    @Environment(\.revealItem) var revealItem

    let person: Person
    let inNavigator: Bool

    var thumbnail: NSImage? { person.docs.first(where: { $0.category == .thumbnail })?.thumbnailImage }
    var thumbnailImage: Image { thumbnail.map({ Image(nsImage: $0) }) ?? Image(systemName: "person.fill")}
    var personURL: URL? { URL(string: "https://www.somegeekintn.com/roots/getperson.php?personID=\(person.identifier)&tree=Main") }

    init(_ person: Person, inNavigator: Bool) {
        self.person = person
        self.inNavigator = inNavigator
    }

    var body: some View {
        HStack {
            thumbnailImage
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text("\(person.lastName), \(person.firstName) - (\(person.identifier))")
                .font(.body)
        }
        .frame(height: 24)
        .contextMenu {
            if !inNavigator {
                Button("Reveal in Navigator") { revealItem(.people(person)) }
            }
            Button("Open page") { personURL.map { openURL($0) } }
        }
    }
}

#Preview {
    PersonRow(Person(identifier: "Preview", firstName: "John", lastName: "Doe"), inNavigator: false)
}

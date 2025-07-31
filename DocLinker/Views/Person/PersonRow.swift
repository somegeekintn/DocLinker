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

    var thumbnail: NSImage? { person.docs.first(where: { $0.category == .thumbnail })?.thumbnailImage }
    var thumbnailImage: Image { thumbnail.map({ Image(nsImage: $0) }) ?? Image(systemName: "person.fill")}
    var personURL: URL? { URL(string: "https://www.somegeekintn.com/roots/getperson.php?personID=I\(person.identifier)&tree=Main") }

    init(_ person: Person) {
        self.person = person
    }

    var body: some View {
        HStack {
            thumbnailImage
                .resizable()
                .aspectRatio(contentMode: .fit)

            Text(verbatim: "(I\(person.identifier): \(person.lastName), \(person.firstName) [\(person.docs.count)]")
                .font(.body)
        }
        .frame(height: 28)
        .contextMenu {
            Button("Open page") { personURL.map { openURL($0) } }
        }
    }
}

#Preview {
    PersonRow(Person(identifier: 123, firstName: "John", lastName: "Doe"))
}

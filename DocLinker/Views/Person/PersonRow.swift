//
//  PersonRow.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct PersonRow: View {
    let person: Person

    var thumbnail: NSImage? { person.docs.first(where: { $0.category == .thumbnail })?.thumbnailImage }
    var thumbnailImage: Image { thumbnail.map({ Image(nsImage: $0) }) ?? Image(systemName: "person.fill")}

    init(_ person: Person) {
        self.person = person
    }

    var body: some View {
        HStack {
            thumbnailImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)

            Text("\(person.identifier): \(person.lastName), \(person.firstName)")
        }
    }
}

#Preview {
    PersonRow(Person(identifier: "Preview", firstName: "John", lastName: "Doe"))
}

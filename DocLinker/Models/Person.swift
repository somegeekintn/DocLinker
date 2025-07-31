//
//  Person.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftData
import SwiftUI

@Model
final class Person: Codable {
    enum CodingKeys: String, CodingKey {
        case identifier
        case firstName
        case lastName
        case notes
    }

    @Attribute(.unique) var identifier: Int
    var firstName: String
    var lastName: String
    var notes: String = ""
    var docs: [Document] = []

    var fullName: String { "\(lastName), \(firstName)" }
    var reportText: String { "[\(identifier)] - \(fullName)" }

    @MainActor
    static var defaultQuery: Query<Person, [Person]> { Query(sort: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]) }

    init(identifier: Int, firstName: String, lastName: String, notes: String = "") {
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.notes = notes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(Int.self, forKey: .identifier)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        notes = try container.decode(String.self, forKey: .notes)
        // Item codes Person so we do not decode items in Person
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(notes, forKey: .notes)
    }
}

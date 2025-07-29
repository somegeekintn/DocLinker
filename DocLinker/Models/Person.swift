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
    }

    @Attribute(.unique) var identifier: String
    var firstName: String
    var lastName: String
    var docs: [Document] = []

    var fullName: String { "\(lastName), \(firstName)" }
    var reportText: String { "[\(identifier)] - \(fullName)" }

    @MainActor
    static var defaultQuery: Query<Person, [Person]> { Query(sort: [SortDescriptor(\.lastName), SortDescriptor(\.firstName)]) }

    init(identifier: String, firstName: String, lastName: String) {
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        identifier = try container.decode(String.self, forKey: .identifier)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        // Item codes Person so we do not decode items in Person
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(identifier, forKey: .identifier)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
    }
}

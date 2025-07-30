//
//  ItemSelection.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/30/25.
//

import Foundation

enum ItemSelection {
    enum Category: CaseIterable {
        case people
        case documents

        var tabName: String {
            switch self {
            case .people:       "People"
            case .documents:    "Documents"
            }
        }

        var tabImage: String {
            switch self {
            case .people:       "person"
            case .documents:    "document"
            }
        }

        var defaultSelection: ItemSelection {
            switch self {
            case .people:       .people(nil)
            case .documents:    .documents(nil)
            }
        }
    }

    case people(Person?)
    case documents(Document?)

    static var tabItems: [ItemSelection] { [.people(nil), .documents(nil) ] }

    var category: Category {
        switch self {
        case .people:       .people
        case .documents:    .documents
        }
    }

    var document: Document? {
        switch self {
        case .people:               nil
        case let .documents(doc):   doc
        }
    }

    var person: Person? {
        switch self {
        case let .people(person):   person
        case .documents:            nil
        }
    }
}


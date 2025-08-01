//
//  Document.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftData
import SwiftUI
import OSLog

@Model
final class Document: Codable {
    enum CodingKeys: String, CodingKey {
        case fileURL
        case notes
        case bookmarkData
        case category
        case incomplete
        case people
    }

    enum Category: Codable, CaseIterable, Identifiable {
        case general
        case thumbnail
        case photo
        case census
        case birth
        case death
        case marriage
        case military

        var id: Self { self }
        
        var displayText: String {
            switch self {
            case .general:      "General"
            case .thumbnail:    "Thumbnail"
            case .photo:        "Photo"
            case .census:       "Census"
            case .birth:        "Birth"
            case .death:        "Death"
            case .marriage:     "Marriage"
            case .military:     "Military"
            }
        }
    }

    var fileURL: URL
    var filename: String    // fileURL.lastPathComponent but SwiftData needs it to sort
    var notes: String = ""
    var bookmarkData: Data
    var thumbnailData: Data?
    var category: Category
    var incomplete: Bool
    @Relationship(deleteRule: .nullify, inverse: \Person.docs)
    var people: [Person] = []
    @Transient var previewData: Data?

    var thumbnailImage: NSImage? { guard let thumbnailData else { return nil }; return NSImage(data: thumbnailData) }

    var reportText: String {
        let linkedPeopleText = people.sorted(by: { $0.fullName < $1.fullName }).map({ $0.reportText }).joined(separator: "\n\t")

        return "\(fileURL.path): [\(category.displayText)]\n\t\(linkedPeopleText)"
    }

    @MainActor
    static var defaultQuery: Query<Document, [Document]> { Query(sort: [SortDescriptor(\.filename, order: .forward)]) }

    init(fileURL: URL, notes: String = "", category: Category = .general, incomplete: Bool = false) throws {
        self.fileURL = fileURL
        self.filename = fileURL.lastPathComponent
        self.notes = notes
        self.category = category
        self.incomplete = incomplete
        self.bookmarkData = try fileURL.bookmarkData(options: [.minimalBookmark])

        generateThumbnail()
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(URL.self, forKey: .fileURL)

        fileURL = url
        filename = url.lastPathComponent
        notes = try container.decode(String.self, forKey: .notes)
        bookmarkData = try container.decode(Data.self, forKey: .bookmarkData)
        category = try container.decode(Category.self, forKey: .category)
        incomplete = try container.decode(Bool.self, forKey: .incomplete)
        people = try container.decode([Person].self, forKey: .people)

        generateThumbnail()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(fileURL, forKey: .fileURL)
        try container.encode(notes, forKey: .notes)
        try container.encode(bookmarkData, forKey: .bookmarkData)
        try container.encode(category, forKey: .category)
        try container.encode(people, forKey: .people)
    }

    func generateThumbnail() {
        resolveBookmark()

        if thumbnailData == nil {
            Task {
                do {
                    self.thumbnailData = try await fileURL.generateImageData(size: CGSize(width: 200, height: 200))
                }
                catch {
                    Logger.app.error("Failed to generate thumbnail: \(error)")
                }
            }
        }
    }

    func resolveBookmark() {
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)

            if isStale {
                self.fileURL = url
                self.filename = fileURL.lastPathComponent
                self.bookmarkData = try fileURL.bookmarkData(options: [.minimalBookmark])
                self.thumbnailData = nil
            }
        }
        catch {
            Logger.app.error("Failed to resolve bookmark: \(error)")
        }
    }

    func displayPath(root: URL?) -> String {
        guard let root, fileURL.path.hasPrefix(root.path) else { return filename }

        return String(fileURL.path.dropFirst(root.path.count))
    }

    @discardableResult
    static func addDocumentFrom(url: URL, context: ModelContext) -> Result<Document, any Error> {
        do {
            let resolvedURL = url.resolvingSymlinksInPath()
            let docs = try context.fetch(FetchDescriptor<Document>(predicate: #Predicate {$0.fileURL == resolvedURL }))

            if let result = docs.first {
                return .success(result)
            }
            else {
                let newDoc = try Document(fileURL: resolvedURL)

                context.insert(newDoc)

                return .success(newDoc)
            }
        }
        catch {
            Logger.app.error("Failed to add new document: \(error)")

            return .failure(error)
        }
    }
}

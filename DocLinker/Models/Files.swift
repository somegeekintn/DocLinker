//
//  Files.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import UniformTypeIdentifiers

enum ExportFile: FileDocument {
    case json(JSONFile)
    case report(ReportFile)

    static var readableContentTypes: [UTType] { [.json, .plainText] }

    var contentType: UTType {
        switch self {
        case .json:     .json
        case .report:   .plainText
        }
    }

    var defaultFilename: String {
        switch self {
        case .json:     "linked-docs"
        case .report:   "linked-docs"
        }
    }

    init(configuration: ReadConfiguration) throws {
        self = try configuration.contentType == .json ? .json(JSONFile(configuration: configuration)) : .report(ReportFile(configuration: configuration))
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        switch self {
        case let .json(jsonFile):       try jsonFile.fileWrapper(configuration: configuration)
        case let .report(reportFile):   try reportFile.fileWrapper(configuration: configuration)
        }
    }
}

struct JSONFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var jsonData: Data?

    init(jsonData: Data?) {
        self.jsonData = jsonData
    }

    init(configuration: ReadConfiguration) throws {
        jsonData = configuration.file.regularFileContents
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let data = jsonData else { throw URLError(.cannotOpenFile) }

        return FileWrapper(regularFileWithContents: data)
    }
}

struct ReportFile: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText] }

    var report: String

    init(report: String) {
        self.report = report
    }

    init(configuration: ReadConfiguration) throws {
        report = configuration.file.regularFileContents.map({ String(data: $0, encoding: .utf8) ?? "" }) ?? ""
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: report.data(using: .utf8) ?? Data())
    }
}

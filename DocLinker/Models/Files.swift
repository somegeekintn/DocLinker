//
//  Files.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import UniformTypeIdentifiers

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

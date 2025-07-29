//
//  DocLinkerApp.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct DocLinkerApp: App {
    @State var showingExporter: Bool = false
    @State var jsonFile: JSONFile?
    @State var reportFile: ReportFile?

    var exportingJSON: Binding<Bool> { Binding(get: { jsonFile != nil }, set: { _ in jsonFile = nil }) }
    var exportingReport: Binding<Bool> { Binding(get: { reportFile != nil }, set: { _ in reportFile = nil }) }

    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Document.self, Person.self])
        let storeURL = URL.applicationSupportDirectory.appending(path: "DocLinker/Data.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fileExporter(isPresented: exportingJSON,
                              document: jsonFile,
                              contentType: .json,
                              defaultFilename: "linked-docs",
                              onCompletion: handleJSONResult)
                .fileExporter(isPresented: exportingReport,
                              document: reportFile,
                              contentType: .plainText,
                              defaultFilename: "linked-docs",
                              onCompletion: handleReportResult)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(after: .newItem) {
                Divider()
                Button("Save Report") { generateReport() }
                    .keyboardShortcut("s")
                Button("Import JSON") { Logger.app.info("JSON importing coming soon") }
                    .keyboardShortcut("o")
                Button("Export JSON") { exportJSON() }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
            }
        }
    }

    func exportJSON() {
        do {
            // Note: A Person without associated Items will not be exported
            let context = sharedModelContainer.mainContext
            let docs = try context.fetch(FetchDescriptor<Document>())
            let jsonData = try JSONEncoder().encode(docs)

            jsonFile = JSONFile(jsonData: jsonData)
        }
        catch {
            Logger.app.error("Failed to export JSON: \(error)")
        }
    }

    func generateReport() {
        do {
            // Note: A Person without associated Items will not be exported
            let context = sharedModelContainer.mainContext
            let items = try context.fetch(FetchDescriptor<Document>()).sorted(by: { $0.filename < $1.filename})
            let report = items.map({ $0.reportText }).joined(separator: "\n")

            reportFile = ReportFile(report: report)
        }
        catch {
            Logger.app.error("Failed to generate report: \(error)")
        }
    }

    func handleJSONResult(_ result: Result<URL, any Error>) {
        if case .failure(let error) = result {
            Logger.app.error("Failed to export JSON: \(error)")
        }
    }

    func handleReportResult(_ result: Result<URL, any Error>) {
        if case .failure(let error) = result {
            Logger.app.error("Failed to save report: \(error)")
        }
    }
}

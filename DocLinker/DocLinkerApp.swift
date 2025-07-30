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
    @State var exportFile: ExportFile?

    var exportingFile: Binding<Bool> { Binding(get: { exportFile != nil }, set: { _ in exportFile = nil }) }

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
                .fileExporter(isPresented: exportingFile,
                              document: exportFile,
                              contentType: exportFile?.contentType ?? .plainText,
                              defaultFilename: exportFile?.defaultFilename,
                              onCompletion: handleExportResult)
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

        Settings { SettingsView() }
    }

    func exportJSON() {
        do {
            // Note: A Person without associated Items will not be exported
            let context = sharedModelContainer.mainContext
            let docs = try context.fetch(FetchDescriptor<Document>())
            let jsonData = try JSONEncoder().encode(docs)

            exportFile = .json(JSONFile(jsonData: jsonData))
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

            exportFile = .report(ReportFile(report: report))
        }
        catch {
            Logger.app.error("Failed to generate report: \(error)")
        }
    }

    func handleExportResult(_ result: Result<URL, any Error>) {
        if case .failure(let error) = result {
            Logger.app.error("Failed to export file: \(error)")
        }
    }
}

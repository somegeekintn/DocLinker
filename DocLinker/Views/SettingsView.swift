//
//  SettingsView.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(.rootPath) var rootPath: URL?
    @State var presentPathSelector: Bool = false

    var pathText: String { rootPath.map({ $0.path() }) ?? "Not set" }

    var body: some View {
        VStack {
            HStack {
                Text("Root Path: \(pathText)")
                    .frame(width: 480)
                    .truncationMode(.middle)
                Button("Select") { presentPathSelector = true }
            }
        }
        .padding()
        .navigationTitle("Settings")
        .fileImporter(isPresented: $presentPathSelector, allowedContentTypes: [.directory], onCompletion: handlePathSelection)
    }

    func handlePathSelection(_ result: Result<URL, any Error>) {
        guard let fileURL = try? result.get() else { return }

        rootPath = fileURL
    }
}

extension AppStorage {
  init(wrappedValue: Value, _ key: SettingsKey, store: UserDefaults? = nil) where Value == Bool {
    self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
  }

  init(wrappedValue: Value, _ key: SettingsKey, store: UserDefaults? = nil) where Value: RawRepresentable, Value.RawValue == Int {
    self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
  }

  init(_ key: SettingsKey, store: UserDefaults? = nil) where Value == String? {
    self.init(key.rawValue, store: store)
  }

  init(wrappedValue: Value, _ key: SettingsKey, store: UserDefaults? = nil) where Value == String {
    self.init(wrappedValue: wrappedValue, key.rawValue, store: store)
  }

  init(_ key: SettingsKey, store: UserDefaults? = nil) where Value == URL? {
    self.init(key.rawValue, store: store)
  }

}

enum SettingsKey: String, CaseIterable {
    case rootPath   = "rootPath"
}

#Preview {
    SettingsView()
}

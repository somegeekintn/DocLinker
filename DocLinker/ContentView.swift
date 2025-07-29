//
//  ContentView.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    enum Selection: CaseIterable {
        case people
        case documents

        var labelName: String {
            switch self {
            case .people:       "People"
            case .documents:    "Documents"
            }
        }

        var imageName: String {
            switch self {
            case .people:       "person"
            case .documents:    "document"
            }
        }
    }

    @State var selection = Selection.people

    var body: some View {
        NavigationSplitView {
            VStack {
                Group {
                    switch selection {
                    case .people:       PersonOrganizer()
                    case .documents:    DocumentOrganizer()
                    }
                }
                .padding(.bottom, 8)

                Divider()

                HStack(spacing: 16) {
                    ForEach(Selection.allCases, id: \.self) { item in
                        SimpleButton(label: item.labelName, imageName: item.imageName, selected: selection == item) {
                            withAnimation { selection = item }
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: Document.self) { DocumentDetail($0).id($0.fileURL) }
            .navigationDestination(for: Person.self) { PersonDetail($0).id($0.identifier) }
            .navigationSplitViewColumnWidth(min: 264, ideal: 320)
        } detail: {
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Document.self, Person.self], inMemory: true)
}

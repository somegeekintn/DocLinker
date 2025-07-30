//
//  SimpleButton.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct SimpleButton: View {
    let label: String
    let imageNames: [String]
    let selected: Bool
    let action: () -> Void

    init(label: String, imageName: String, selected: Bool = false, action: @escaping () -> Void) {
        self.init(label: label, imageNames: [imageName], selected: selected, action: action)
    }
    
    init(label: String, imageNames: [String], selected: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.imageNames = imageNames
        self.selected = selected
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(imageNames, id: \.self) { imageName in
                Image(systemName: imageName)
            }
            Text(label)
        }
        .font(.title2)
        .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .contentShape(Rectangle())
        .onTapGesture { action() }
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.primary)
            }
        }
    }
}

#Preview {
    SimpleButton(label: "Add Item", imageName: "plus.circle") { }
}

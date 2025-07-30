//
//  Environment.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/30/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var revealItem = RevealItemAction.defaultValue
}

struct RevealItemAction: EnvironmentKey {
    typealias Action = @MainActor @Sendable (ItemSelection) -> Void
    let action: Action

    static var defaultValue: RevealItemAction { RevealItemAction { _ in } }

    init(_ action: @escaping Action) {
        self.action = action
    }

    @MainActor func callAsFunction(_ item: ItemSelection) {
        action(item)
    }
}

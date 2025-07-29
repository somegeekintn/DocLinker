//
//  Logger.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import Foundation
import OSLog

public extension Logger {
  enum Category: String {
    case app          = "App"
    case dev          = "Develop"

    var logger: Logger {
      switch self {
      case .app:          return .app
      case .dev:          return .dev
      }
    }
  }

  static let app          = Logger(.app)
  static let dev          = Logger(.dev)
  static let defaultSubsystem = Bundle.main.bundleIdentifier ?? "DocLinker"

  init(_ category: Category) {
    self.init(subsystem: Self.defaultSubsystem, category: category.rawValue)
  }
}

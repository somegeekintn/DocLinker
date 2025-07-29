//
//  LayoutDebug.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import SwiftUI

struct LayoutDebug: ViewModifier {
  enum Style {
    case layout
    case spacing
  }

  struct Options: OptionSet {
    let rawValue: Int

    static let frame     = Options(rawValue: (1 << 0))
    static let safeArea  = Options(rawValue: (1 << 1))
    static let height    = Options(rawValue: (1 << 2))
    static let width     = Options(rawValue: (1 << 3))
    static let all: Options = [.frame, .safeArea, .height, .width]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }
  }

  @Environment(\.displayScale) var displayScale

  let style: Style

  let options: Options
  let alignment: Alignment
  let color: Color

  let spacing: CGFloat
  let descender: CGFloat

  init(options: Options = .frame, alignment: Alignment = .bottomTrailing, color: Color = .yellow) {
    self.style = .layout

    self.options = options
    self.alignment = alignment
    self.color = color

    self.spacing = 0
    self.descender = 0
  }

  init(spacing: CGFloat, descender: CGFloat, color: Color = .red) {
    self.style = .spacing

    self.options = .all
    self.alignment = .bottomTrailing
    self.color = color

    self.spacing = spacing
    self.descender = descender
  }

    func body(content: Content) -> some View {
    content
      .overlay {
        GeometryReader { geometry in
          let frame = geometry.frame(in: CoordinateSpace.local)

          switch style {
          case .layout:
            if !options.isEmpty {
              Path { path in

                path.addRect(frame)
                path.move(to: CGPoint(x: frame.midX, y: frame.minY))
                path.addLine(to: CGPoint(x: frame.midX, y: frame.maxY))
                path.move(to: CGPoint(x: frame.minX, y: frame.midY))
                path.addLine(to: CGPoint(x: frame.maxX, y: frame.midY))
              }
              .stroke(color, lineWidth: 1.0 / displayScale)
              .overlay(alignment: .bottomTrailing) {
                VStack(alignment: .trailing) {
                  if options.contains(.frame) {
                    let gFrame = "\(geometry.frame(in: .global))"

                    Text("Frame: \(gFrame)")
                  }
                  if options.contains(.safeArea) {
                    let safe = "\(geometry.safeAreaInsets)"

                    Text("Safe: \(safe)")
                  }
                  if options.contains(.height) {
                    let height = Double(geometry.frame(in: .global).height)

                    Text("H: \(height.formatted(.number.precision(.fractionLength(2))))")
                  }
                  if options.contains(.width) {
                    let width = Double(geometry.frame(in: .global).width)

                    Text("W: \(width.formatted(.number.precision(.fractionLength(2))))")
                  }
                }
                .padding(4)
                .background(.black.opacity(0.5))
                .font(.debugging())
                .foregroundColor(color)
              }
              .border(color, width: 1.0 / displayScale)
            }

          case .spacing:
            color.frame(height: spacing)
              .offset(y: geometry.size.height - descender)
          }
        }
        .allowsHitTesting(false)
      }
  }
}

extension View {
  func layoutDebug(options: LayoutDebug.Options = .frame, alignment: Alignment = .bottomTrailing, color: Color = .yellow) -> some View {
    modifier(LayoutDebug(options: options, alignment: alignment, color: color))
  }

  func layoutDebug(spacing: CGFloat, descender: CGFloat, color: Color = .red) -> some View {
    modifier(LayoutDebug(spacing: spacing, descender: descender, color: color))
  }
}

extension Font {
  static var debugFontSize: CGFloat { 13.0 }

  static func debugging(size: CGFloat = Self.debugFontSize) -> SwiftUI.Font {
    .system(size: size, design: .monospaced)
  }
}

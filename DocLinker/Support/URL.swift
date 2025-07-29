//
//  URL.swift
//  DocLinker
//
//  Created by Casey Fleser on 7/29/25.
//

import Foundation
import QuickLookThumbnailing

extension URL {
    func generateImageData(size: CGSize, scale: CGFloat = 1) async throws -> Data? {
        let request = QLThumbnailGenerator.Request(fileAt: self, size: size, scale: scale, representationTypes: [.icon, .thumbnail])
        let rep = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
        let nsImage = rep.nsImage

        return nsImage.tiffRepresentation(using: .jpeg, factor: 0.8)
    }
}

// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// [UInt8]+RFC_2183.swift
// swift-rfc-2183
//
// Canonical byte serialization for RFC 2183 Content-Disposition headers

import INCITS_4_1986
import RFC_2045
import RFC_5322
import Standards

// MARK: - ContentDisposition Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 2183 ContentDisposition
    ///
    /// This is the canonical serialization of Content-Disposition headers to bytes.
    /// RFC 2183 Content-Disposition headers are ASCII-only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_2183.ContentDisposition (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// ContentDisposition → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Performance
    ///
    /// Efficient byte composition:
    /// - Single allocation with capacity estimation
    /// - Direct ASCII byte operations
    /// - No intermediate String allocations
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = RFC_2183.ContentDisposition.attachment(
    ///     filename: try RFC_2183.Filename("document.pdf")
    /// )
    /// let bytes = [UInt8](disposition)
    /// // bytes represents "attachment; filename=\"document.pdf\"" as ASCII bytes
    /// ```
    ///
    /// - Parameter contentDisposition: The content disposition to serialize
    public init(_ contentDisposition: RFC_2183.ContentDisposition) {
        self = []

        // Estimate capacity: type + parameters
        let estimatedCapacity = contentDisposition.type.rawValue.count +
                                (contentDisposition.parameters.estimatedSize)
        self.reserveCapacity(estimatedCapacity)

        // Append disposition type
        self.append(contentsOf: contentDisposition.type.rawValue.utf8)

        let params = contentDisposition.parameters

        // Add standard parameters in RFC-defined order
        if let filename = params.filename {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "filename".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""

            // Escape quotes in filename
            for char in filename.value {
                if char == "\"" {
                    self.append(.ascii.reverseSolidus) // "\\"
                }
                self.append(contentsOf: char.utf8)
            }

            self.append(.ascii.quotationMark) // "\""
        }

        if let creationDate = params.creationDate {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "creation-date".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""
            let dateString = RFC_5322.DateTime.Formatter.format(creationDate)
            self.append(contentsOf: dateString.utf8)
            self.append(.ascii.quotationMark) // "\""
        }

        if let modificationDate = params.modificationDate {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "modification-date".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""
            let dateString = RFC_5322.DateTime.Formatter.format(modificationDate)
            self.append(contentsOf: dateString.utf8)
            self.append(.ascii.quotationMark) // "\""
        }

        if let readDate = params.readDate {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "read-date".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""
            let dateString = RFC_5322.DateTime.Formatter.format(readDate)
            self.append(contentsOf: dateString.utf8)
            self.append(.ascii.quotationMark) // "\""
        }

        if let size = params.size {
            // Size is unquoted per RFC 2183
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "size".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(contentsOf: String(size.bytes).utf8)
        }

        // RFC 7578 extension - name parameter
        if let name = params.name {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: "name".utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""

            // Escape quotes in name
            for char in name {
                if char == "\"" {
                    self.append(.ascii.reverseSolidus) // "\\"
                }
                self.append(contentsOf: char.utf8)
            }

            self.append(.ascii.quotationMark) // "\""
        }

        // Extension parameters in sorted order for stability
        for (key, value) in params.extensionParameters.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            self.append(.ascii.semicolon) // ";"
            self.append(.ascii.space)
            self.append(contentsOf: key.rawValue.utf8)
            self.append(.ascii.equalsSign) // "="
            self.append(.ascii.quotationMark) // "\""

            // Escape quotes in value
            for char in value {
                if char == "\"" {
                    self.append(.ascii.reverseSolidus) // "\\"
                }
                self.append(contentsOf: char.utf8)
            }

            self.append(.ascii.quotationMark) // "\""
        }
    }
}

// MARK: - Helper Extension

extension RFC_2183.Parameters {
    /// Estimates the size needed for parameter serialization
    fileprivate var estimatedSize: Int {
        var size = 0

        if let filename = filename {
            size += 20 + filename.value.count // "; filename=\"...\""
        }
        if creationDate != nil {
            size += 50 // "; creation-date=\"...\""
        }
        if modificationDate != nil {
            size += 55 // "; modification-date=\"...\""
        }
        if readDate != nil {
            size += 45 // "; read-date=\"...\""
        }
        if size != nil {
            size += 20 // "; size=..."
        }
        if let name = name {
            size += 15 + name.count // "; name=\"...\""
        }

        // Extension parameters
        size += extensionParameters.reduce(0) { $0 + $1.key.rawValue.count + $1.value.count + 10 }

        return size
    }
}

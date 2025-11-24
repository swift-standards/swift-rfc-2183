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

// StringProtocol+RFC_2183.swift
// swift-rfc-2183
//
// String representations composed through canonical byte serialization

// MARK: - ContentDisposition String Representation

extension StringProtocol {
    /// Creates string representation of an RFC 2183 ContentDisposition
    ///
    /// RFC 2183 Content-Disposition headers are pure ASCII (7-bit), and this initializer
    /// interprets them as UTF-8 (since ASCII ⊂ UTF-8).
    ///
    /// - Parameter contentDisposition: The content disposition to represent
    public init(_ contentDisposition: RFC_2183.ContentDisposition) {
        self = Self(decoding: [UInt8](contentDisposition), as: UTF8.self)
    }
}

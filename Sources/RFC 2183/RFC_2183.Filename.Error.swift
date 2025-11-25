//
//  RFC_2183.Filename.Error.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension RFC_2183.Filename {
    /// Filename-specific error type for typed throws
    ///
    /// Errors that can occur when validating Content-Disposition filename parameters.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Filename is empty
        case empty

        /// Filename contains non-ASCII characters
        case notASCII(String)

        /// Filename contains control characters
        case containsControlCharacters(String, byte: UInt8)

        /// Filename contains path traversal (..)
        case containsPathTraversal(String)

        /// Filename contains path separators (/ or \)
        case containsPathSeparator(String)

        /// Filename is an absolute path
        case isAbsolutePath(String)
    }
}

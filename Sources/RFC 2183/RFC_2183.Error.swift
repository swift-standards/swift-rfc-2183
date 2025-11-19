//
//  File.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

extension RFC_2183 {
    /// Errors that can occur when parsing Content-Disposition headers
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Invalid Content-Disposition format
        case invalidFormat(String)

        // Size errors
        /// Size parameter value is negative
        case negativeSizeNotAllowed

        // Filename errors
        /// Filename contains non-ASCII characters
        case filenameNotASCII
        /// Filename contains control characters
        case filenameContainsControlCharacters
        /// Filename contains path traversal (..)
        case filenameContainsPathTraversal
        /// Filename contains path separators (/ or \)
        case filenameContainsPathSeparator
        /// Filename is an absolute path
        case filenameIsAbsolutePath

        public var errorDescription: String? {
            switch self {
            case .invalidFormat(let value):
                return "Invalid Content-Disposition format: \(value)"
            case .negativeSizeNotAllowed:
                return "Size parameter must be non-negative"
            case .filenameNotASCII:
                return "Filename must contain only ASCII characters"
            case .filenameContainsControlCharacters:
                return "Filename must not contain control characters"
            case .filenameContainsPathTraversal:
                return "Filename must not contain path traversal (..)"
            case .filenameContainsPathSeparator:
                return "Filename must not contain path separators (/ or \\)"
            case .filenameIsAbsolutePath:
                return "Filename must not be an absolute path"
            }
        }
    }
}

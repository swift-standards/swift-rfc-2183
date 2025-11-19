import Foundation
import INCITS_4_1986

extension RFC_2183 {
    /// Validated filename for Content-Disposition filename parameter.
    ///
    /// RFC 2183 Section 2.3 specifies that the filename parameter suggests
    /// a default filename. This type validates filenames to prevent security
    /// issues like path traversal and control character injection.
    ///
    /// ## Validation Rules
    ///
    /// - Must be valid ASCII (uses INCITS 4-1986 validation)
    /// - No control characters (0x00-0x1F, 0x7F)
    /// - No path separators (/, \)
    /// - No parent directory references (..)
    /// - No absolute path indicators
    ///
    /// ## Example
    ///
    /// ```swift
    /// let filename = try RFC_2183.Filename("document.pdf")
    /// print(filename.value) // "document.pdf"
    ///
    /// // Invalid: contains path traversal
    /// try RFC_2183.Filename("../etc/passwd") // throws
    /// ```
    public struct Filename: Hashable, Sendable, Codable {
        /// The validated filename string.
        public let value: String

        /// Creates a validated filename.
        ///
        /// - Parameter value: The filename string to validate.
        /// - Throws: `RFC_2183.Error` if validation fails.
        public init(_ value: String) throws {
            // Validate ASCII using INCITS 4-1986
            guard let asciiBytes = value.asciiBytes else {
                throw RFC_2183.Error.filenameNotASCII
            }

            // Check for control characters
            guard !asciiBytes.contains(where: \.isASCIIControl) else {
                throw RFC_2183.Error.filenameContainsControlCharacters
            }

            // Check for path traversal
            guard !value.contains("..") else {
                throw RFC_2183.Error.filenameContainsPathTraversal
            }

            // Check for path separators
            guard !value.contains("/"), !value.contains("\\") else {
                throw RFC_2183.Error.filenameContainsPathSeparator
            }

            // Check for absolute path indicators
            guard !value.hasPrefix("/"), !value.hasPrefix("\\") else {
                throw RFC_2183.Error.filenameIsAbsolutePath
            }

            self.value = value
        }

        /// The base filename without any path components.
        ///
        /// This is equivalent to the validated value since path components
        /// are already rejected during validation.
        public var baseName: String {
            value
        }
    }
}

extension RFC_2183.Filename: CustomStringConvertible {
    public var description: String {
        value
    }
}

extension RFC_2183.Filename: LosslessStringConvertible {
    public init?(_ description: String) {
        try? self.init(description)
    }
}

extension RFC_2183.Filename: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        do {
            try self.init(value)
        } catch {
            preconditionFailure("""
                Invalid filename literal: \(value)
                Error: \(error)
                Use RFC_2183.Filename.init(_:) for runtime values.
                """)
        }
    }
}

//
//  RFC_2183.Filename.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import INCITS_4_1986

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

        /// Creates a filename WITHOUT validation
        ///
        /// **Warning**: Bypasses all RFC validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameter value: The raw value (unchecked)
        init(__unchecked value: String) {
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

// MARK: - UInt8.ASCII.Serializable

extension RFC_2183.Filename: UInt8.ASCII.Serializable {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init

    /// Parses a filename from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 filenames are ASCII-only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_2183.Filename (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → Filename
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("document.pdf".utf8)
    /// let filename = try RFC_2183.Filename(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the filename
    /// - Throws: `RFC_2183.Filename.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        // Empty check
        guard !bytes.isEmpty else {
            throw Error.empty
        }

        // Check for control characters and non-ASCII
        for byte in bytes {
            guard byte.ascii.isVisible || byte == .ascii.space else {
                if byte > 127 {
                    throw Error.notASCII(String(decoding: bytes, as: UTF8.self))
                }
                throw Error.containsControlCharacters(
                    String(decoding: bytes, as: UTF8.self),
                    byte: byte
                )
            }
        }

        let value = String(decoding: bytes, as: UTF8.self)

        // Check for path traversal
        guard !value.contains("..") else {
            throw Error.containsPathTraversal(value)
        }

        // Check for path separators
        guard !value.contains("/"), !value.contains("\\") else {
            throw Error.containsPathSeparator(value)
        }

        // Check for absolute path indicators
        guard !value.hasPrefix("/"), !value.hasPrefix("\\") else {
            throw Error.isAbsolutePath(value)
        }

        self.init(__unchecked: value)
    }
}

// MARK: - Byte Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 2183 filename
    ///
    /// This is the canonical serialization of filenames to bytes.
    /// RFC 2183 filenames are ASCII-only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_2183.Filename (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Filename → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let filename = try RFC_2183.Filename("document.pdf")
    /// let bytes = [UInt8](filename)
    /// ```
    ///
    /// - Parameter filename: The filename to serialize
    public init(_ filename: RFC_2183.Filename) {
        self = Array(filename.value.utf8)
    }
}

// MARK: - Protocol Conformances

extension RFC_2183.Filename: RawRepresentable {
    public var rawValue: String { value }

    public init?(rawValue: String) {
        try? self.init(rawValue)
    }
}

extension RFC_2183.Filename: CustomStringConvertible {}

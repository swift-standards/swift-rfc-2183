//
//  RFC_2183.Size.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import INCITS_4_1986

extension RFC_2183 {
    /// File size in bytes for Content-Disposition size parameter.
    ///
    /// RFC 2183 Section 2.7 specifies that the size parameter indicates
    /// the approximate size of the file in octets.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let size = try RFC_2183.Size(bytes: 1024)
    /// print(size.bytes) // 1024
    /// ```
    public struct Size: Hashable, Sendable, Codable, Comparable {
        /// The size in bytes.
        public let bytes: Int

        /// Creates a size value WITHOUT validation
        ///
        /// **Warning**: Bypasses validation.
        /// Only use with compile-time constants or pre-validated values.
        ///
        /// - Parameter bytes: The number of bytes (unchecked)
        init(__unchecked bytes: Int) {
            self.bytes = bytes
        }

        /// Creates a size value from a byte count.
        ///
        /// - Parameter bytes: The number of bytes. Must be non-negative.
        /// - Throws: `RFC_2183.Size.Error.negative` if bytes is negative.
        public init(bytes: Int) throws(Error) {
            guard bytes >= 0 else {
                throw Error.negative(bytes)
            }
            self.init(__unchecked: bytes)
        }

        // MARK: - Comparable

        public static func < (lhs: Size, rhs: Size) -> Bool {
            lhs.bytes < rhs.bytes
        }
    }
}

// MARK: - Binary.ASCII.Serializable

extension RFC_2183.Size: Binary.ASCII.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii size: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: String(size.bytes).utf8)
    }

    /// Parses a size from canonical byte representation (CANONICAL PRIMITIVE)
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 size values are ASCII digits only.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_2183.Size (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → Size
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("1024".utf8)
    /// let size = try RFC_2183.Size(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the size
    /// - Throws: `RFC_2183.Size.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        let string = String(decoding: bytes, as: UTF8.self)
        guard let value = Int(string) else {
            throw Error.invalidFormat(string)
        }
        guard value >= 0 else {
            throw Error.negative(value)
        }
        self.init(__unchecked: value)
    }
}

// MARK: - Byte Serialization

extension [UInt8] {
    /// Creates ASCII byte representation of an RFC 2183 size
    ///
    /// This is the canonical serialization of sizes to bytes.
    /// RFC 2183 sizes are ASCII digits only by definition.
    ///
    /// ## Category Theory
    ///
    /// This is the most universal serialization (natural transformation):
    /// - **Domain**: RFC_2183.Size (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// String representation is derived as composition:
    /// ```
    /// Size → [UInt8] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let size = try RFC_2183.Size(bytes: 1024)
    /// let bytes = [UInt8](size)
    /// ```
    ///
    /// - Parameter size: The size to serialize
    public init(_ size: RFC_2183.Size) {
        self = Array(String(size.bytes).utf8)
    }
}

// MARK: - Protocol Conformances

extension RFC_2183.Size: RawRepresentable {
    public var rawValue: String { String(bytes) }

    public init?(rawValue: String) {
        guard let value = Int(rawValue), value >= 0 else {
            return nil
        }
        self.init(__unchecked: value)
    }
}

extension RFC_2183.Size: CustomStringConvertible {}

extension RFC_2183.Size: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let bytes = Int(description), bytes >= 0 else {
            return nil
        }
        self.init(__unchecked: bytes)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_2183.Size: ExpressibleByIntegerLiteral {
    /// Creates a size from an integer literal
    ///
    /// **Note**: Bypasses validation via `init(__unchecked:)`.
    /// Only use with compile-time constants.
    ///
    /// ```swift
    /// let size: RFC_2183.Size = 1024
    /// ```
    public init(integerLiteral value: Int) {
        self.init(__unchecked: value)
    }
}

import Foundation

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

        /// Creates a size value from a byte count.
        ///
        /// - Parameter bytes: The number of bytes. Must be non-negative.
        /// - Throws: `RFC_2183.Error.negativeSizeNotAllowed` if bytes is negative.
        public init(bytes: Int) throws {
            guard bytes >= 0 else {
                throw RFC_2183.Error.negativeSizeNotAllowed
            }
            self.bytes = bytes
        }

        /// Creates a size value from a byte count without validation.
        ///
        /// - Parameter uncheckedBytes: The number of bytes. Must be non-negative.
        /// - Precondition: `uncheckedBytes >= 0`
        public init(uncheckedBytes: Int) {
            precondition(uncheckedBytes >= 0, "Size must be non-negative")
            self.bytes = uncheckedBytes
        }

        // MARK: - Comparable

        public static func < (lhs: Size, rhs: Size) -> Bool {
            lhs.bytes < rhs.bytes
        }
    }
}

extension RFC_2183.Size: CustomStringConvertible {
    public var description: String {
        "\(bytes)"
    }
}

extension RFC_2183.Size: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let bytes = Int(description), bytes >= 0 else {
            return nil
        }
        self.bytes = bytes
    }
}

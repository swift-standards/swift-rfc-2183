import Foundation

extension RFC_2183 {
    /// Type-safe Content-Disposition parameter name.
    ///
    /// Parameter names are case-insensitive per RFC 2183.
    /// This type ensures consistent handling and provides static constants
    /// for standard parameters.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let name: RFC_2183.ParameterName = .filename
    /// print(name.rawValue) // "filename"
    ///
    /// let custom = RFC_2183.ParameterName(rawValue: "Custom-Param")
    /// print(custom.rawValue) // "custom-param" (lowercased)
    /// ```
    public struct ParameterName: RawRepresentable, Hashable, Sendable, Codable {
        /// The lowercased parameter name.
        public let rawValue: String

        /// Creates a parameter name from a raw string value.
        ///
        /// The value is automatically lowercased for case-insensitive comparison.
        ///
        /// - Parameter rawValue: The parameter name string.
        public init(rawValue: String) {
            self.rawValue = rawValue.lowercased()
        }

        // MARK: - RFC 2183 Standard Parameters

        /// The filename parameter (RFC 2183 Section 2.3).
        ///
        /// Suggests a default filename for saving the file.
        public static let filename = ParameterName(rawValue: "filename")

        /// The creation-date parameter (RFC 2183 Section 2.4).
        ///
        /// Date-time when the file was created (RFC 5322 format).
        public static let creationDate = ParameterName(rawValue: "creation-date")

        /// The modification-date parameter (RFC 2183 Section 2.5).
        ///
        /// Date-time when the file was last modified (RFC 5322 format).
        public static let modificationDate = ParameterName(rawValue: "modification-date")

        /// The read-date parameter (RFC 2183 Section 2.6).
        ///
        /// Date-time when the file was last read (RFC 5322 format).
        public static let readDate = ParameterName(rawValue: "read-date")

        /// The size parameter (RFC 2183 Section 2.7).
        ///
        /// Approximate size of the file in octets.
        public static let size = ParameterName(rawValue: "size")

        // MARK: - RFC 7578 Extension

        /// The name parameter (RFC 7578 Section 4.2).
        ///
        /// Field name for multipart/form-data submissions.
        public static let name = ParameterName(rawValue: "name")
    }
}

extension RFC_2183.ParameterName: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension RFC_2183.ParameterName: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

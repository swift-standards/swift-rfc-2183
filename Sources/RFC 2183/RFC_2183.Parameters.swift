import Foundation
import RFC_2045
import RFC_5322

extension RFC_2183 {
    /// Structured parameters for Content-Disposition headers.
    ///
    /// Provides type-safe access to standard Content-Disposition parameters
    /// with proper validation and parsing.
    ///
    /// ## Standard Parameters (RFC 2183)
    ///
    /// - `filename`: Suggested filename for saving
    /// - `creationDate`: When the file was created
    /// - `modificationDate`: When the file was last modified
    /// - `readDate`: When the file was last read
    /// - `size`: Approximate file size in bytes
    ///
    /// ## Extension Parameters (RFC 7578)
    ///
    /// - `name`: Field name for multipart/form-data
    ///
    /// ## Example
    ///
    /// ```swift
    /// var params = RFC_2183.Parameters()
    /// params.filename = try Filename("document.pdf")
    /// params.size = try Size(bytes: 1024)
    /// params.creationDate = try RFC_5322.DateTime(parsing: "Mon, 01 Jan 2024 12:00:00 +0000")
    /// ```
    public struct Parameters: Hashable, Sendable, Codable {
        // MARK: - RFC 2183 Standard Parameters

        /// The filename parameter (RFC 2183 Section 2.3).
        ///
        /// Suggests a default filename for saving the file.
        public var filename: Filename?

        /// The creation-date parameter (RFC 2183 Section 2.4).
        ///
        /// Date-time when the file was created (RFC 5322 format).
        public var creationDate: RFC_5322.DateTime?

        /// The modification-date parameter (RFC 2183 Section 2.5).
        ///
        /// Date-time when the file was last modified (RFC 5322 format).
        public var modificationDate: RFC_5322.DateTime?

        /// The read-date parameter (RFC 2183 Section 2.6).
        ///
        /// Date-time when the file was last read (RFC 5322 format).
        public var readDate: RFC_5322.DateTime?

        /// The size parameter (RFC 2183 Section 2.7).
        ///
        /// Approximate size of the file in octets.
        public var size: Size?

        // MARK: - RFC 7578 Extension

        /// The name parameter (RFC 7578 Section 4.2).
        ///
        /// Field name for multipart/form-data submissions.
        public var name: String?

        // MARK: - Extension Parameters

        /// Additional extension parameters not defined in standards.
        ///
        /// Stores arbitrary parameter name-value pairs for future extensions
        /// or vendor-specific parameters.
        public var extensionParameters: [ParameterName: String]

        // MARK: - Initialization

        /// Creates an empty parameter set.
        public init(
            filename: Filename? = nil,
            creationDate: RFC_5322.DateTime? = nil,
            modificationDate: RFC_5322.DateTime? = nil,
            readDate: RFC_5322.DateTime? = nil,
            size: Size? = nil,
            name: String? = nil,
            extensionParameters: [ParameterName: String] = [:]
        ) {
            self.filename = filename
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.readDate = readDate
            self.size = size
            self.name = name
            self.extensionParameters = extensionParameters
        }
    }
}

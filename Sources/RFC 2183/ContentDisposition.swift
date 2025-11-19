import INCITS_4_1986

/// RFC 2183 namespace
public enum RFC_2183 {}

extension RFC_2183 {
    /// Content-Disposition header field
    ///
    /// Communicates presentation information in Internet messages,
    /// indicating whether content should be displayed inline or treated
    /// as an attachment.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Inline content
    /// let inline = RFC_2183.ContentDisposition(type: .inline)
    ///
    /// // Attachment with filename
    /// let attachment = RFC_2183.ContentDisposition(
    ///     type: .attachment,
    ///     parameters: ["filename": "document.pdf"]
    /// )
    ///
    /// // Form data with field name and filename
    /// let formData = RFC_2183.ContentDisposition(
    ///     type: .formData,
    ///     parameters: [
    ///         "name": "avatar",
    ///         "filename": "photo.jpg"
    ///     ]
    /// )
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 2183 Section 2:
    ///
    /// > The Content-Disposition header field is used to convey presentational
    /// > information for a message or body part. The disposition-type indicates
    /// > how the part should be handled.
    public struct ContentDisposition: Hashable, Sendable, Codable {
        /// The disposition type (inline, attachment, etc.)
        public let type: DispositionType

        /// Optional parameters (filename, size, dates, etc.)
        public let parameters: [String: String]

        /// Creates a new Content-Disposition header
        ///
        /// - Parameters:
        ///   - type: Disposition type
        ///   - parameters: Optional parameters
        public init(
            type: DispositionType,
            parameters: [String: String] = [:]
        ) {
            self.type = type
            self.parameters = parameters
        }

        /// Parses a Content-Disposition header value
        ///
        /// - Parameter headerValue: The header value (e.g., "attachment; filename=\"file.pdf\"")
        /// - Throws: `RFC_2183.Error.invalidFormat` if the value is malformed
        public init(parsing headerValue: String) throws {
            let components = headerValue.split(separator: ";", maxSplits: 1)

            // Parse disposition type
            guard let typeString = components.first else {
                throw RFC_2183.Error.invalidFormat(headerValue)
            }

            self.type = DispositionType(
                rawValue: String(typeString).trimming(.whitespaces)
            )

            // Parse parameters if present
            var params: [String: String] = [:]
            if components.count > 1 {
                let paramString = String(components[1])
                let paramPairs = paramString.split(separator: ";")

                for pair in paramPairs {
                    let keyValue = pair.split(separator: "=", maxSplits: 1)
                    guard keyValue.count == 2 else {
                        continue
                    }

                    let key = String(keyValue[0]).trimming(.whitespaces).lowercased()
                    var value = String(keyValue[1]).trimming(.whitespaces)

                    // Remove quotes if present
                    if value.hasPrefix("\"") && value.hasSuffix("\"") {
                        value = String(value.dropFirst().dropLast())
                        // Unescape quotes per RFC 2183
                        value = value.replacing("\\\"", with: "\"")
                    }

                    params[key] = value
                }
            }

            self.parameters = params
        }

        /// The complete header value
        ///
        /// Example: `"attachment; filename=\"document.pdf\""`
        public var headerValue: String {
            var result = type.rawValue

            for (key, value) in parameters.sorted(by: { $0.key < $1.key }) {
                // Per RFC 2183 Section 2, parameter values SHOULD be quoted
                // Certain parameters like size may be unquoted tokens
                let escapedValue = value.replacing("\"", with: "\\\"")

                // Quote all values except pure numeric tokens (e.g., size parameter per RFC 2183)
                let isPureNumeric = !value.isEmpty && value.allSatisfy { $0.isASCIIDigit }

                let quotedValue = isPureNumeric ? value : "\"\(escapedValue)\""
                result += "; \(key)=\(quotedValue)"
            }

            return result
        }
    }
}

// MARK: - Disposition Type

extension RFC_2183 {
    /// Disposition type for Content-Disposition header
    ///
    /// Indicates how content should be presented or handled.
    /// Uses a struct (not enum) to allow extension types per RFC 2183.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Standard types
    /// let inline = RFC_2183.DispositionType.inline
    /// let attachment = RFC_2183.DispositionType.attachment
    ///
    /// // Extension type
    /// let custom = RFC_2183.DispositionType(rawValue: "x-custom")
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 2183 Section 2.1:
    ///
    /// > A disposition type of "inline" indicates that the body part should be
    /// > displayed automatically upon display of the message. A disposition type
    /// > of "attachment" indicates that the body part should not be displayed
    /// > automatically and requires some form of action from the user to view it.
    public struct DispositionType: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String

        /// Creates a disposition type
        ///
        /// - Parameter rawValue: The disposition type name (case-insensitive)
        public init(rawValue: String) {
            self.rawValue = rawValue.lowercased()
        }

        // MARK: - Standard Disposition Types (RFC 2183)

        /// Content should be displayed inline
        ///
        /// **RFC 2183 Section 2.1**: Display automatically upon message display
        public static let inline = DispositionType(rawValue: "inline")

        /// Content should be treated as an attachment
        ///
        /// **RFC 2183 Section 2.2**: Not displayed automatically, requires user action
        public static let attachment = DispositionType(rawValue: "attachment")

        // MARK: - Extension Types

        /// Form data (RFC 7578)
        ///
        /// Used in multipart/form-data submissions with field names and filenames
        public static let formData = DispositionType(rawValue: "form-data")
    }
}

// MARK: - Typed Parameter Accessors

extension RFC_2183.ContentDisposition {
    /// The filename parameter (RFC 2183 Section 2.3)
    ///
    /// Suggested filename for saving the content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = RFC_2183.ContentDisposition(
    ///     type: .attachment,
    ///     parameters: ["filename": "document.pdf"]
    /// )
    /// print(disposition.filename) // Optional("document.pdf")
    /// ```
    public var filename: String? {
        parameters["filename"]
    }

    /// The creation-date parameter (RFC 2183 Section 2.4)
    ///
    /// Date-time when the file was created (RFC 822 format).
    public var creationDate: String? {
        parameters["creation-date"]
    }

    /// The modification-date parameter (RFC 2183 Section 2.5)
    ///
    /// Date-time when the file was last modified (RFC 822 format).
    public var modificationDate: String? {
        parameters["modification-date"]
    }

    /// The read-date parameter (RFC 2183 Section 2.6)
    ///
    /// Date-time when the file was last read (RFC 822 format).
    public var readDate: String? {
        parameters["read-date"]
    }

    /// The size parameter (RFC 2183 Section 2.7)
    ///
    /// Approximate size of the file in octets.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = RFC_2183.ContentDisposition(
    ///     type: .attachment,
    ///     parameters: [
    ///         "filename": "data.bin",
    ///         "size": "1048576"
    ///     ]
    /// )
    /// print(disposition.size) // Optional(1048576)
    /// ```
    public var size: Int? {
        parameters["size"].flatMap(Int.init)
    }

    /// The name parameter (form-data extension from RFC 7578)
    ///
    /// Form field name in multipart/form-data submissions.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = RFC_2183.ContentDisposition(
    ///     type: .formData,
    ///     parameters: ["name": "avatar"]
    /// )
    /// print(disposition.name) // Optional("avatar")
    /// ```
    public var name: String? {
        parameters["name"]
    }
}

// MARK: - Convenience Constructors

extension RFC_2183.ContentDisposition {
    /// Creates an inline Content-Disposition
    ///
    /// - Returns: Content-Disposition with type inline
    ///
    /// ## Example
    ///
    /// ```swift
    /// let inline = RFC_2183.ContentDisposition.inline()
    /// // Content-Disposition: inline
    /// ```
    public static func inline() -> Self {
        Self(type: .inline)
    }

    /// Creates an attachment Content-Disposition
    ///
    /// - Parameter filename: Optional filename parameter
    /// - Returns: Content-Disposition with type attachment
    ///
    /// ## Example
    ///
    /// ```swift
    /// let attachment = RFC_2183.ContentDisposition.attachment(filename: "document.pdf")
    /// // Content-Disposition: attachment; filename="document.pdf"
    /// ```
    public static func attachment(filename: String? = nil) -> Self {
        var params: [String: String] = [:]
        if let filename = filename {
            params["filename"] = filename
        }
        return Self(type: .attachment, parameters: params)
    }

    /// Creates a form-data Content-Disposition
    ///
    /// - Parameters:
    ///   - name: Form field name
    ///   - filename: Optional filename for file uploads
    /// - Returns: Content-Disposition with type form-data
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Text field
    /// let field = RFC_2183.ContentDisposition.formData(name: "username")
    /// // Content-Disposition: form-data; name="username"
    ///
    /// // File upload
    /// let file = RFC_2183.ContentDisposition.formData(name: "avatar", filename: "photo.jpg")
    /// // Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
    /// ```
    public static func formData(name: String, filename: String? = nil) -> Self {
        var params: [String: String] = ["name": name]
        if let filename = filename {
            params["filename"] = filename
        }
        return Self(type: .formData, parameters: params)
    }
}

// MARK: - Errors

extension RFC_2183 {
    /// Errors that can occur when parsing Content-Disposition headers
    public enum Error: Swift.Error, Hashable, Sendable {
        /// Invalid Content-Disposition format
        case invalidFormat(String)

        public var errorDescription: String? {
            switch self {
            case .invalidFormat(let value):
                return "Invalid Content-Disposition format: \(value)"
            }
        }
    }
}

// MARK: - Protocol Conformances

extension RFC_2183.ContentDisposition: CustomStringConvertible {
    public var description: String { headerValue }
}

extension RFC_2183.ContentDisposition: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        try! self.init(parsing: value)
    }
}

extension RFC_2183.DispositionType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {
    public var description: String { rawValue }
}

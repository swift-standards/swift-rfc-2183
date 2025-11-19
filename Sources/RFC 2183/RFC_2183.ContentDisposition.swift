import INCITS_4_1986
import RFC_5322

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
    ///     parameters: Parameters(filename: try Filename("document.pdf"))
    /// )
    ///
    /// // Form data with field name and filename
    /// let formData = RFC_2183.ContentDisposition(
    ///     type: .formData,
    ///     parameters: Parameters(
    ///         name: "avatar",
    ///         filename: try Filename("photo.jpg")
    ///     )
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

        /// Typed parameters (filename, size, dates, etc.)
        public let parameters: Parameters

        /// Creates a new Content-Disposition header
        ///
        /// - Parameters:
        ///   - type: Disposition type
        ///   - parameters: Typed parameters
        public init(
            type: DispositionType,
            parameters: Parameters = Parameters()
        ) {
            self.type = type
            self.parameters = parameters
        }
    }
}

extension RFC_2183.ContentDisposition {

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

        self.type = RFC_2183.DispositionType(
            rawValue: String(typeString).trimming(.whitespaces)
        )

        // Parse parameters if present
        var rawParams: [String: String] = [:]
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

                rawParams[key] = value
            }
        }

        // Convert raw parameters to typed parameters
        self.parameters = try Self.parseParameters(rawParams)
    }

    /// Parse raw string parameters into typed Parameters struct.
    private static func parseParameters(_ raw: [String: String]) throws -> Parameters {
        var params = Parameters()

        // Parse standard parameters with validation
        if let filenameStr = raw["filename"] {
            params.filename = try? Filename(filenameStr)
        }

        if let creationDateStr = raw["creation-date"] {
            params.creationDate = try? RFC_5322.DateTime(parsing: creationDateStr)
        }

        if let modDateStr = raw["modification-date"] {
            params.modificationDate = try? RFC_5322.DateTime(parsing: modDateStr)
        }

        if let readDateStr = raw["read-date"] {
            params.readDate = try? RFC_5322.DateTime(parsing: readDateStr)
        }

        if let sizeStr = raw["size"] {
            params.size = try? Size(bytes: Int(sizeStr) ?? -1)
        }

        // RFC 7578 extension
        params.name = raw["name"]

        // Store unknown parameters in extensionParameters
        let knownKeys: Set<String> = [
            "filename",
            "creation-date",
            "modification-date",
            "read-date",
            "size",
            "name"
        ]

        for (key, value) in raw where !knownKeys.contains(key) {
            params.extensionParameters[ParameterName(rawValue: key)] = value
        }

        return params
    }
}

// MARK: - Disposition Type

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
    /// - Parameters:
    ///   - filename: Optional filename parameter
    ///   - size: Optional size parameter
    ///   - creationDate: Optional creation date
    ///   - modificationDate: Optional modification date
    ///   - readDate: Optional read date
    /// - Returns: Content-Disposition with type attachment
    ///
    /// ## Example
    ///
    /// ```swift
    /// let attachment = RFC_2183.ContentDisposition.attachment(
    ///     filename: try Filename("document.pdf"),
    ///     size: try Size(bytes: 1024)
    /// )
    /// // Content-Disposition: attachment; filename="document.pdf"; size=1024
    /// ```
    public static func attachment(
        filename: Filename? = nil,
        size: Size? = nil,
        creationDate: RFC_5322.DateTime? = nil,
        modificationDate: RFC_5322.DateTime? = nil,
        readDate: RFC_5322.DateTime? = nil
    ) -> Self {
        Self(
            type: .attachment,
            parameters: Parameters(
                filename: filename,
                creationDate: creationDate,
                modificationDate: modificationDate,
                readDate: readDate,
                size: size
            )
        )
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
    /// let file = RFC_2183.ContentDisposition.formData(
    ///     name: "avatar",
    ///     filename: try Filename("photo.jpg")
    /// )
    /// // Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
    /// ```
    public static func formData(name: String, filename: Filename? = nil) -> Self {
        Self(
            type: .formData,
            parameters: Parameters(
                filename: filename,
                name: name
            )
        )
    }
}



// MARK: - Protocol Conformances

extension RFC_2183.ContentDisposition: CustomStringConvertible {
    public var description: String { .init(self) }
}

extension RFC_2183.DispositionType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {
    public var description: String { rawValue }
}

import INCITS_4_1986
import RFC_2045
public import RFC_5322

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
    /// Parses a Content-Disposition header from canonical byte representation
    ///
    /// This is the primitive parser that works at the byte level.
    /// RFC 2183 headers are pure ASCII, so this parser operates on ASCII bytes.
    ///
    /// ## Category Theory
    ///
    /// This is the fundamental parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_2183.ContentDisposition (structured data)
    ///
    /// String-based parsing is derived as composition:
    /// ```
    /// String → [UInt8] (UTF-8 bytes) → ContentDisposition
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let bytes = Array("attachment; filename=\"doc.pdf\"".utf8)
    /// let disposition = try RFC_2183.ContentDisposition(parsing: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the header value
    /// - Throws: `RFC_2183.Error` if the bytes are malformed
    public init(_ bytes: [UInt8]) throws {
        // Split on first semicolon to separate type from parameters
        guard let firstSemicolon = bytes.firstIndex(of: .ascii.semicolon) else {
            // No parameters, just disposition type
            let typeBytes = bytes.trimming(.ascii.whitespaces)
            guard !typeBytes.isEmpty else {
                throw RFC_2183.Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
            }

            self.type = RFC_2183.DispositionType(
                rawValue: String(decoding: typeBytes, as: UTF8.self)
            )
            self.parameters = .init()
            return
        }

        // Parse disposition type
        let typeBytes = bytes[..<firstSemicolon].trimming(.ascii.whitespaces)
        guard !typeBytes.isEmpty else {
            throw RFC_2183.Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
        }

        self.type = RFC_2183.DispositionType(
            rawValue: String(decoding: typeBytes, as: UTF8.self)
        )

        // Parse parameters
        let parametersBytes = bytes[(firstSemicolon + 1)...]
        var rawParams: [String: String] = [:]

        // Split on semicolons to get parameter pairs
        let paramPairs = parametersBytes.split(separator: .ascii.semicolon)

        for paramPair in paramPairs {
            // Split on equals to get key=value
            guard let equalsIndex = paramPair.firstIndex(of: .ascii.equalsSign) else {
                continue
            }

            let keyBytes = paramPair[..<equalsIndex].trimming(.ascii.whitespaces)
            var valueBytes = Array(paramPair[(equalsIndex + 1)...].trimming(.ascii.whitespaces))

            guard !keyBytes.isEmpty else {
                continue
            }

            // Handle quoted values
            if valueBytes.first == .ascii.quotationMark && valueBytes.last == .ascii.quotationMark {
                // Remove surrounding quotes
                valueBytes = Array(valueBytes.dropFirst().dropLast())

                // Unescape quotes per RFC 2183
                valueBytes = Self.unescapeQuotes(valueBytes)
            }

            let key = String(decoding: keyBytes, as: UTF8.self).lowercased()
            let value = String(decoding: valueBytes, as: UTF8.self)

            rawParams[key] = value
        }

        // Convert raw parameters to typed parameters
        self.parameters = try Self.parseParameters(rawParams)
    }

    /// Unescapes quoted-pair sequences in parameter values
    ///
    /// RFC 2183 allows escaping quotes with backslash: \"
    ///
    /// - Parameter bytes: The bytes to unescape
    /// - Returns: Unescaped bytes
    private static func unescapeQuotes(_ bytes: [UInt8]) -> [UInt8] {
        var result: [UInt8] = []
        var i = 0

        while i < bytes.count {
            if i < bytes.count - 1 &&
               bytes[i] == .ascii.reverseSolidus && // backslash
               bytes[i + 1] == .ascii.quotationMark { // quote
                // Skip the backslash, include the quote
                result.append(bytes[i + 1])
                i += 2
            } else {
                result.append(bytes[i])
                i += 1
            }
        }

        return result
    }
}

extension RFC_2183.ContentDisposition {

    /// Parses a Content-Disposition header value
    ///
    /// Composes through canonical byte representation for academic correctness.
    ///
    /// ## Category Theory
    ///
    /// Parsing composes as:
    /// ```
    /// String → [UInt8] (UTF-8) → ContentDisposition
    /// ```
    ///
    /// - Parameter headerValue: The header value (e.g., "attachment; filename=\"file.pdf\"")
    /// - Throws: `RFC_2183.Error.invalidFormat` if the value is malformed
    public init(parsing headerValue: String) throws {
        // Convert to canonical byte representation (UTF-8, which is ASCII-compatible)
        let bytes = Array(headerValue.utf8)

        // Delegate to primitive byte-level parser
        try self.init(bytes)
    }

    /// Parse raw string parameters into typed Parameters struct.
    package static func parseParameters(_ raw: [String: String]) throws -> RFC_2183.Parameters {
        var params = RFC_2183.Parameters()

        // Parse standard parameters with validation
        if let filenameStr = raw["filename"] {
            params.filename = try? RFC_2183.Filename(filenameStr)
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
            params.size = try? RFC_2183.Size(bytes: Int(sizeStr) ?? -1)
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
            params.extensionParameters[RFC_2045.Parameter.Name(rawValue: key)] = value
        }

        return params
    }
}

// MARK: - Disposition Type

// MARK: - Convenience Accessors

extension RFC_2183.ContentDisposition {
    /// The filename parameter (RFC 2183 Section 2.3)
    ///
    /// Convenience accessor that delegates to `parameters.filename`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let disposition = try RFC_2183.ContentDisposition(
    ///     parsing: "attachment; filename=\"document.pdf\""
    /// )
    /// print(disposition.filename?.value) // "document.pdf"
    /// ```
    public var filename: RFC_2183.Filename? {
        parameters.filename
    }

    /// The creation-date parameter (RFC 2183 Section 2.4)
    ///
    /// Convenience accessor that delegates to `parameters.creationDate`.
    ///
    /// Date-time when the file was created (RFC 5322 format).
    public var creationDate: RFC_5322.DateTime? {
        parameters.creationDate
    }

    /// The modification-date parameter (RFC 2183 Section 2.5)
    ///
    /// Convenience accessor that delegates to `parameters.modificationDate`.
    ///
    /// Date-time when the file was last modified (RFC 5322 format).
    public var modificationDate: RFC_5322.DateTime? {
        parameters.modificationDate
    }

    /// The read-date parameter (RFC 2183 Section 2.6)
    ///
    /// Convenience accessor that delegates to `parameters.readDate`.
    ///
    /// Date-time when the file was last read (RFC 5322 format).
    public var readDate: RFC_5322.DateTime? {
        parameters.readDate
    }

    /// The size parameter (RFC 2183 Section 2.7)
    ///
    /// Convenience accessor that delegates to `parameters.size`.
    ///
    /// Approximate size of the file in octets.
    public var size: RFC_2183.Size? {
        parameters.size
    }

    /// The name parameter (RFC 7578 Section 4.2)
    ///
    /// Convenience accessor that delegates to `parameters.name`.
    ///
    /// Field name for multipart/form-data submissions.
    public var name: String? {
        parameters.name
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
        filename: RFC_2183.Filename? = nil,
        size: RFC_2183.Size? = nil,
        creationDate: RFC_5322.DateTime? = nil,
        modificationDate: RFC_5322.DateTime? = nil,
        readDate: RFC_5322.DateTime? = nil
    ) -> Self {
        Self(
            type: .attachment,
            parameters: .init(
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
    public static func formData(name: String, filename: RFC_2183.Filename? = nil) -> Self {
        Self(
            type: .formData,
            parameters: .init(
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

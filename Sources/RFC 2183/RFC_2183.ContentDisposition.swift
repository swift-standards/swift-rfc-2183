//
//  RFC_2183.ContentDisposition.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import INCITS_4_1986
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

extension [UInt8] {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition.Type
    ) {
        self = Array("Content-Disposition".utf8)
    }
}

// MARK: - UInt8.ASCII.Serializable

extension RFC_2183.ContentDisposition: UInt8.ASCII.Serializable {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init

    /// Parses a Content-Disposition header from canonical byte representation (CANONICAL PRIMITIVE)
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
    /// let disposition = try RFC_2183.ContentDisposition(ascii: bytes)
    /// ```
    ///
    /// - Parameter bytes: The ASCII byte representation of the header value
    /// - Throws: `RFC_2183.ContentDisposition.Error` if the bytes are malformed
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void) throws(Error)
    where Bytes.Element == UInt8 {
        // Split on first semicolon to separate type from parameters
        guard let firstSemicolon = bytes.firstIndex(of: .ascii.semicolon) else {
            // No parameters, just disposition type
            let typeBytes = bytes.trimming(.ascii.whitespaces)
            guard !typeBytes.isEmpty else {
                throw Error.emptyDispositionType
            }

            self.type = RFC_2183.DispositionType(
                rawValue: String(decoding: typeBytes, as: UTF8.self)
            )
            self.parameters = .init()
            return
        }

        // Parse disposition type
        let typeBytes = (bytes[..<firstSemicolon]).trimming(.ascii.whitespaces)
        guard !typeBytes.isEmpty else {
            throw Error.emptyDispositionType
        }

        self.type = RFC_2183.DispositionType(
            rawValue: String(decoding: typeBytes, as: UTF8.self)
        )

        // Parse parameters – work on a slice, avoid Array copy
        let parametersStartIndex = bytes.index(after: firstSemicolon)
        let parametersSlice = bytes[parametersStartIndex...]

        var rawParams: [String: String] = [:]

        // Split on semicolons to get parameter pairs
        let paramPairs = parametersSlice.split(separator: .ascii.semicolon)
        rawParams.reserveCapacity(paramPairs.count)

        for paramPair in paramPairs {
            // Split on equals to get key=value
            guard let equalsIndex = paramPair.firstIndex(of: .ascii.equalsSign) else {
                continue
            }

            let keyBytes = (paramPair[..<equalsIndex]).trimming(.ascii.whitespaces)
            guard !keyBytes.isEmpty else { continue }

            let valueStartIndex = paramPair.index(after: equalsIndex)
            let valueSlice = (paramPair[valueStartIndex...]).trimming(.ascii.whitespaces)
            guard !valueSlice.isEmpty else { continue }

            // Determine quoting with a single forward pass
            guard let firstByte = valueSlice.first else { continue }

            var lastByte = firstByte
            var length = 0
            for byte in valueSlice {
                lastByte = byte
                length &+= 1
            }

            // Lowercase at the ASCII byte level, then allocate String once
            let key = String(decoding: keyBytes.ascii.lowercased(), as: UTF8.self)

            let value: String
            let isQuoted =
                firstByte == .ascii.quotationMark
                && lastByte == .ascii.quotationMark
                && length >= 2
            if isQuoted {
                // Only now allocate a new buffer for the unescaped content
                let inner = valueSlice.dropFirst().dropLast()
                let unescaped = Self.unescapeQuotes(inner)
                value = String(decoding: unescaped, as: UTF8.self)
            } else {
                // No unescaping: decode directly from the slice, zero extra copies
                value = String(decoding: valueSlice, as: UTF8.self)
            }

            rawParams[key] = value
        }

        // Convert raw parameters to typed parameters
        self.parameters = Self.parseParameters(rawParams)
    }

    /// Unescapes quoted-pair sequences in parameter values
    ///
    /// RFC 2183 allows escaping quotes with backslash: \"
    ///
    /// - Parameter bytes: The bytes to unescape
    /// - Returns: Unescaped bytes
    private static func unescapeQuotes<C: Collection>(
        _ bytes: C
    ) -> [UInt8] where C.Element == UInt8 {
        var result: [UInt8] = []
        result.reserveCapacity(bytes.count)

        var i = bytes.startIndex
        let end = bytes.endIndex

        while i != end {
            let current = bytes[i]
            let nextIndex = bytes.index(after: i)

            // Check for backslash + quote
            let isEscapedQuote =
                nextIndex != end
                && current == .ascii.reverseSolidus  // '\'
                && bytes[nextIndex] == .ascii.quotationMark  // '"'
            if isEscapedQuote {
                // Include only the quote
                result.append(.ascii.quotationMark)

                // Skip both characters
                i = bytes.index(after: nextIndex)
            } else {
                // Not an escape sequence
                result.append(current)
                i = nextIndex
            }
        }

        return result
    }
}

// MARK: - Parameter Parsing

extension RFC_2183.ContentDisposition {
    /// Parse raw string parameters into typed Parameters struct.
    package static func parseParameters(_ raw: [String: String]) -> RFC_2183.Parameters {
        var params = RFC_2183.Parameters()

        // Parse standard parameters with validation (silently ignore invalid values)
        if let filenameStr = raw["filename"] {
            params.filename = try? RFC_2183.Filename(filenameStr)
        }

        if let creationDateStr = raw["creation-date"] {
            params.creationDate = try? RFC_5322.DateTime(ascii: Array(creationDateStr.utf8))
        }

        if let modDateStr = raw["modification-date"] {
            params.modificationDate = try? RFC_5322.DateTime(ascii: Array(modDateStr.utf8))
        }

        if let readDateStr = raw["read-date"] {
            params.readDate = try? RFC_5322.DateTime(ascii: Array(readDateStr.utf8))
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
            "name",
        ]

        for (key, value) in raw where !knownKeys.contains(key) {
            params.extensionParameters[RFC_2045.Parameter.Name(rawValue: key)] = value
        }

        return params
    }
}

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
    ///     "attachment; filename=\"document.pdf\""
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

extension RFC_2183.ContentDisposition: CustomStringConvertible {}

extension RFC_2183.DispositionType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {
    public var description: String { rawValue }
}

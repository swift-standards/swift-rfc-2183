//
//  RFC_2183.ContentDisposition.Error.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension RFC_2183.ContentDisposition {
    /// ContentDisposition-specific error type for typed throws
    ///
    /// Errors that can occur when parsing Content-Disposition header values.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The Content-Disposition format is invalid
        case invalidFormat(String)

        /// The disposition type is empty
        case emptyDispositionType

        /// A parameter key is empty
        case emptyParameterKey

        /// A parameter value is empty
        case emptyParameterValue(key: String)

        /// Failed to parse a nested type (filename, size, date)
        case invalidParameter(key: String, value: String, reason: String)
    }
}

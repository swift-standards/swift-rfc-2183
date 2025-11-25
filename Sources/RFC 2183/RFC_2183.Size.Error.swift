//
//  RFC_2183.Size.Error.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension RFC_2183.Size {
    /// Size-specific error type for typed throws
    ///
    /// Errors that can occur when validating Content-Disposition size parameters.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Size value is negative
        case negative(Int)

        /// Size value is not a valid integer
        case invalidFormat(String)
    }
}

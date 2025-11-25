//
//  RFC_5322.Header.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import RFC_5322

extension RFC_5322.Header {
    /// Creates an RFC 5322 header from a Content-Disposition value
    ///
    /// - Parameter contentDisposition: The Content-Disposition value
    /// - Throws: RFC_5322.Header.Value.Error if the value is invalid
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition
    ) throws {
        try self.init(name: .contentDisposition, value: .init(String(contentDisposition)))
    }
}

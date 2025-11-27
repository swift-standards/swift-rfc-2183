//
//  RFC_5322.Header.Name.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

public import RFC_5322

extension RFC_5322.Header.Name {
    /// Content-Disposition: header (RFC 2183)
    ///
    /// The Content-Disposition header field conveys presentation information
    /// for a message or body part.
    public static let contentDisposition: Self = .init(
        __unchecked: (),
        rawValue: "Content-Disposition"
    )
}

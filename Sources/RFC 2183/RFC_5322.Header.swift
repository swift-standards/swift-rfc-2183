//
//  File.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

import RFC_5322

extension RFC_5322.Header {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition
    ) {
        self.init(name: .contentDisposition, value: String(contentDisposition))
    }
}


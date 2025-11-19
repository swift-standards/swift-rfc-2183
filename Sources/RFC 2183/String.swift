//
//  File.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

import INCITS_4_1986
public import RFC_5322
public import RFC_2045

extension String {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition
    ) {
        var result = contentDisposition.type.rawValue

        let params = contentDisposition.parameters

        // Add standard parameters in RFC-defined order
        if let filename = params.filename {
            result += "; filename=\"\(filename.value.replacing("\"", with: "\\\""))\""
        }

        if let creationDate = params.creationDate {
            result += "; creation-date=\"\(RFC_5322.DateTime.Formatter.format(creationDate))\""
        }

        if let modificationDate = params.modificationDate {
            result += "; modification-date=\"\(RFC_5322.DateTime.Formatter.format(modificationDate))\""
        }

        if let readDate = params.readDate {
            result += "; read-date=\"\(RFC_5322.DateTime.Formatter.format(readDate))\""
        }

        if let size = params.size {
            // Size is unquoted per RFC 2183
            result += "; size=\(size.bytes)"
        }

        // RFC 7578 extension
        if let name = params.name {
            result += "; name=\"\(name.replacing("\"", with: "\\\""))\""
        }

        // Extension parameters in sorted order for stability
        for (key, value) in params.extensionParameters.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let escapedValue = value.replacing("\"", with: "\\\"")
            result += "; \(key.rawValue)=\"\(escapedValue)\""
        }

        self = result
    }
}


//
////and then (should be in RFC_5322)
//extension String {
//    public init(
//        _ header: RFC_5322.Header.Name
//    ) {
//        ...
//    }
//}

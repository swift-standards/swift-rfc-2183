//
//  File.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

import INCITS_4_1986
import RFC_5322

extension String {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition
    ) {
        var result = contentDisposition.type.rawValue
        
        for (key, value) in contentDisposition.parameters.sorted(by: { $0.key < $1.key }) {
            // Per RFC 2183 Section 2, parameter values SHOULD be quoted
            // Certain parameters like size may be unquoted tokens
            let escapedValue = value.replacing("\"", with: "\\\"")
            
            // Quote all values except pure numeric tokens (e.g., size parameter per RFC 2183)
            let isPureNumeric = !value.isEmpty && value.allSatisfy { $0.isASCIIDigit }
            
            let quotedValue = isPureNumeric ? value : "\"\(escapedValue)\""
            result += "; \(key)=\(quotedValue)"
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

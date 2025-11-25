//
//  RFC_2183.DispositionType.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

extension RFC_2183 {
    /// Disposition type for Content-Disposition header
    ///
    /// Indicates how content should be presented or handled.
    /// Uses a struct (not enum) to allow extension types per RFC 2183.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Standard types
    /// let inline = RFC_2183.DispositionType.inline
    /// let attachment = RFC_2183.DispositionType.attachment
    ///
    /// // Extension type
    /// let custom = RFC_2183.DispositionType(rawValue: "x-custom")
    /// ```
    ///
    /// ## RFC Reference
    ///
    /// From RFC 2183 Section 2.1:
    ///
    /// > A disposition type of "inline" indicates that the body part should be
    /// > displayed automatically upon display of the message. A disposition type
    /// > of "attachment" indicates that the body part should not be displayed
    /// > automatically and requires some form of action from the user to view it.
    public struct DispositionType: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String
        
        /// Creates a disposition type
        ///
        /// - Parameter rawValue: The disposition type name (case-insensitive)
        public init(rawValue: String) {
            self.rawValue = rawValue.lowercased()
        }
    }
}

extension RFC_2183.DispositionType {
    
    // MARK: - Standard Disposition Types (RFC 2183)
    
    /// Content should be displayed inline
    ///
    /// **RFC 2183 Section 2.1**: Display automatically upon message display
    public static let inline = Self(rawValue: "inline")
    
    /// Content should be treated as an attachment
    ///
    /// **RFC 2183 Section 2.2**: Not displayed automatically, requires user action
    public static let attachment = Self(rawValue: "attachment")
    
    // MARK: - Extension Types
    
    /// Form data (RFC 7578)
    ///
    /// Used in multipart/form-data submissions with field names and filenames
    public static let formData = Self(rawValue: "form-data")
}

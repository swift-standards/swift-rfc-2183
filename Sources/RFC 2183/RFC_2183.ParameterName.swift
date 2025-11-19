import Foundation
public import RFC_2045

// RFC 2183 uses RFC 2045 parameter name handling
extension RFC_2183 {
    /// Type alias for Content-Disposition parameter names.
    ///
    /// Content-Disposition parameters follow the general MIME parameter syntax
    /// defined in RFC 2045 Section 5.1. RFC 2183-specific parameter name constants
    /// are provided as extensions.
    public typealias ParameterName = RFC_2045.Parameter.Name
}

// MARK: - RFC 2183 Content-Disposition Parameters

extension RFC_2045.Parameter.Name {
    /// The filename parameter (RFC 2183 Section 2.3).
    ///
    /// Suggests a default filename for saving the file.
    ///
    /// Example: `Content-Disposition: attachment; filename="document.pdf"`
    public static let filename = Self(rawValue: "filename")

    /// The creation-date parameter (RFC 2183 Section 2.4).
    ///
    /// Date-time when the file was created (RFC 5322 format).
    ///
    /// Example: `Content-Disposition: attachment; creation-date="Mon, 01 Jan 2024 12:00:00 +0000"`
    public static let creationDate = Self(rawValue: "creation-date")

    /// The modification-date parameter (RFC 2183 Section 2.5).
    ///
    /// Date-time when the file was last modified (RFC 5322 format).
    ///
    /// Example: `Content-Disposition: attachment; modification-date="Mon, 01 Jan 2024 13:00:00 +0000"`
    public static let modificationDate = Self(rawValue: "modification-date")

    /// The read-date parameter (RFC 2183 Section 2.6).
    ///
    /// Date-time when the file was last read (RFC 5322 format).
    ///
    /// Example: `Content-Disposition: attachment; read-date="Mon, 01 Jan 2024 14:00:00 +0000"`
    public static let readDate = Self(rawValue: "read-date")

    /// The size parameter (RFC 2183 Section 2.7).
    ///
    /// Approximate size of the file in octets.
    ///
    /// Example: `Content-Disposition: attachment; size=1024`
    public static let size = Self(rawValue: "size")

    // MARK: - RFC 7578 Extension

    /// The name parameter (RFC 7578 Section 4.2).
    ///
    /// Field name for multipart/form-data submissions.
    ///
    /// Example: `Content-Disposition: form-data; name="avatar"`
    public static let name = Self(rawValue: "name")
}

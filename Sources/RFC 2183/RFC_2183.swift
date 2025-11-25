//
//  RFC_2183.swift
//  swift-rfc-2183
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

@_exported import INCITS_4_1986

/// RFC 2183: Communicating Presentation Information in Internet Messages
///
/// This namespace contains types for working with Content-Disposition headers
/// as defined in RFC 2183.
///
/// ## Overview
///
/// RFC 2183 defines the Content-Disposition header field, which allows
/// message senders to indicate how content should be presented to users.
///
/// ## Key Types
///
/// - ``ContentDisposition``: The main header type
/// - ``DispositionType``: inline, attachment, form-data, etc.
/// - ``Filename``: Validated filename parameter
/// - ``Size``: File size in bytes
/// - ``Parameters``: Structured parameter container
///
/// ## Example
///
/// ```swift
/// // Parse from header value
/// let disposition = try RFC_2183.ContentDisposition(
///     "attachment; filename=\"document.pdf\"; size=1024"
/// )
///
/// // Access parameters
/// print(disposition.type)           // attachment
/// print(disposition.filename?.value) // "document.pdf"
/// print(disposition.size?.bytes)     // 1024
///
/// // Create programmatically
/// let attachment = RFC_2183.ContentDisposition.attachment(
///     filename: try RFC_2183.Filename("report.pdf"),
///     size: try RFC_2183.Size(bytes: 2048)
/// )
/// ```
///
/// ## RFC Reference
///
/// - [RFC 2183](https://www.rfc-editor.org/rfc/rfc2183): Communicating Presentation Information in Internet Messages
/// - [RFC 7578](https://www.rfc-editor.org/rfc/rfc7578): Returning Values from Forms: multipart/form-data
public enum RFC_2183 {}

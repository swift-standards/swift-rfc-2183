# RFC 2183: Content-Disposition Header

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-standards%2Fswift-rfc-2183%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/swift-standards/swift-rfc-2183)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fswift-standards%2Fswift-rfc-2183%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/swift-standards/swift-rfc-2183)

A Swift implementation of **RFC 2183** - Communicating Presentation Information in Internet Messages: The Content-Disposition Header Field.

## Overview

This package provides type-safe Swift types for working with Content-Disposition headers in MIME messages and HTTP responses. It follows the RFC 2183 specification exactly while providing convenient, Swift-friendly APIs.

## Features

- ✅ **RFC 2183 Compliant**: Implements the full specification
- ✅ **Type-Safe**: Strong typing for disposition types and parameters
- ✅ **Extensible**: Supports custom disposition types
- ✅ **Parameter Validation**: Proper escaping and quoting per RFC
- ✅ **Swift 6 Concurrency**: Full Sendable support
- ✅ **Zero Dependencies**: Standalone implementation

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-rfc-2183.git", from: "0.1.0")
]
```

## Usage

### Basic Usage

```swift
import RFC_2183

// Inline content
let inline = RFC_2183.ContentDisposition.inline()
// Content-Disposition: inline

// Attachment with filename
let attachment = RFC_2183.ContentDisposition.attachment(filename: "document.pdf")
// Content-Disposition: attachment; filename="document.pdf"

// Form data
let formData = RFC_2183.ContentDisposition.formData(
    name: "avatar",
    filename: "photo.jpg"
)
// Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
```

### Parsing Headers

```swift
// Parse from header value
let disposition = try RFC_2183.ContentDisposition(
    parsing: #"attachment; filename="report.pdf""#
)

print(disposition.type)      // .attachment
print(disposition.filename)  // Optional("report.pdf")
```

### Working with Parameters

```swift
// Create with multiple parameters
let disposition = RFC_2183.ContentDisposition(
    type: .attachment,
    parameters: [
        "filename": "data.bin",
        "size": "1048576",
        "creation-date": "Mon, 01 Jan 2024 12:00:00 GMT"
    ]
)

// Access typed parameters
print(disposition.filename)        // Optional("data.bin")
print(disposition.size)            // Optional(1048576)
print(disposition.creationDate)    // Optional("Mon, 01 Jan 2024...")
```

### Custom Disposition Types

```swift
// RFC 2183 allows extension types
let custom = RFC_2183.ContentDisposition(
    type: RFC_2183.DispositionType(rawValue: "x-custom"),
    parameters: ["param": "value"]
)
```

### String Literals

```swift
// Create from string literal
let disposition: RFC_2183.ContentDisposition = "attachment; filename=\"test.txt\""

// Create type from string literal
let type: RFC_2183.DispositionType = "inline"
```

## RFC 2183 Disposition Types

### Standard Types

- **`inline`**: Content should be displayed automatically
- **`attachment`**: Content should be saved/downloaded (requires user action)

### Extension Types

- **`form-data`**: Used in multipart/form-data (RFC 7578)

## Standard Parameters

Per RFC 2183, the following parameters are defined:

- **`filename`**: Suggested filename for saving content
- **`creation-date`**: When file was created (RFC 822 date-time)
- **`modification-date`**: When file was last modified
- **`read-date`**: When file was last read
- **`size`**: File size in octets

### Form-Data Extension (RFC 7578)

- **`name`**: Form field name in multipart/form-data

## API Reference

### `RFC_2183.ContentDisposition`

```swift
public struct ContentDisposition {
    public let type: DispositionType
    public let parameters: [String: String]

    // Initializers
    public init(type: DispositionType, parameters: [String: String] = [:])
    public init(parsing headerValue: String) throws

    // Properties
    public var headerValue: String
    public var filename: String?
    public var creationDate: String?
    public var modificationDate: String?
    public var readDate: String?
    public var size: Int?
    public var name: String?  // form-data extension

    // Convenience constructors
    public static func inline() -> Self
    public static func attachment(filename: String? = nil) -> Self
    public static func formData(name: String, filename: String? = nil) -> Self
}
```

### `RFC_2183.DispositionType`

```swift
public struct DispositionType {
    public let rawValue: String

    public static let inline: DispositionType
    public static let attachment: DispositionType
    public static let formData: DispositionType  // RFC 7578 extension
}
```

## Examples

### HTTP Response Headers

```swift
// Download file
let disposition = RFC_2183.ContentDisposition.attachment(filename: "report.pdf")
response.headers.add(name: "Content-Disposition", value: disposition.headerValue)
```

### Email Attachments

```swift
// Email with attachment
let disposition = RFC_2183.ContentDisposition(
    type: .attachment,
    parameters: [
        "filename": "invoice.pdf",
        "size": "524288",
        "creation-date": "Wed, 12 Feb 1997 16:29:51 -0500"
    ]
)
```

### Multipart Form Data

```swift
// File upload field
let fileField = RFC_2183.ContentDisposition.formData(
    name: "document",
    filename: "contract.pdf"
)

// Text field
let textField = RFC_2183.ContentDisposition.formData(name: "username")
```

## Escaping and Quoting

The package automatically handles escaping and quoting per RFC 2183:

```swift
// Filenames with quotes are escaped
let disposition = RFC_2183.ContentDisposition.attachment(
    filename: #"file"with"quotes.txt"#
)
// Content-Disposition: attachment; filename="file\"with\"quotes.txt"

// Filenames with spaces are quoted
let disposition = RFC_2183.ContentDisposition.attachment(
    filename: "my document.pdf"
)
// Content-Disposition: attachment; filename="my document.pdf"
```

## Related RFCs

- **RFC 2045**: MIME Part One - Format of Internet Message Bodies
- **RFC 2046**: MIME Part Two - Media Types
- **RFC 2183**: Content-Disposition Header (this package)
- **RFC 7578**: Returning Values from Forms: multipart/form-data

## License

Apache License 2.0

See [LICENSE.txt](LICENSE.txt) for details.

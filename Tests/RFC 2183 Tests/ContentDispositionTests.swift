import Testing
@testable import RFC_2183
@testable import RFC_2045

@Suite
struct `Content-Disposition Tests` {

    // MARK: - Basic Parsing Tests

    @Test
    func `Parse inline disposition`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "inline")
        #expect(disposition.type == .inline)
        #expect(disposition.filename == nil)
        #expect(String(disposition) == "inline")
    }

    @Test
    func `Parse attachment without filename`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment")
        #expect(disposition.type == .attachment)
        #expect(disposition.filename == nil)
    }

    @Test
    func `Parse attachment with filename`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment; filename=\"document.pdf\"")
        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "document.pdf")
        #expect(String(disposition) == "attachment; filename=\"document.pdf\"")
    }

    @Test
    func `Parse form-data with name`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "form-data; name=\"username\"")
        #expect(disposition.type == .formData)
        #expect(disposition.name == "username")
    }

    @Test
    func `Parse form-data with name and filename`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "form-data; name=\"avatar\"; filename=\"photo.jpg\"")
        #expect(disposition.type == .formData)
        #expect(disposition.name == "avatar")
        #expect(disposition.filename?.value == "photo.jpg")
    }

    // MARK: - Parameter Tests

    @Test
    func `Parse size parameter`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"data.bin\"; size=1048576"
        )
        #expect(disposition.filename?.value == "data.bin")
        #expect(disposition.size?.bytes == 1048576)
    }

    @Test
    func `Parse date parameters`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"doc.pdf\"; creation-date=\"Mon, 01 Jan 2024 12:00:00 GMT\""
        )
        #expect(disposition.filename?.value == "doc.pdf")
        #expect(disposition.creationDate != nil)
    }

    // MARK: - Escaping Tests

    @Test
    func `Parse filename with escaped quotes`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: #"attachment; filename="file\"with\"quotes.txt""#
        )
        #expect(disposition.filename?.value == #"file"with"quotes.txt"#)
    }

    @Test
    func `Render filename with quotes - escapes them`() throws {
        let disposition = RFC_2183.ContentDisposition(
            type: .attachment,
            parameters: .init(filename: try .init(#"file"with"quotes.txt"#))
        )
        #expect(String(disposition) == #"attachment; filename="file\"with\"quotes.txt""#)
    }

    @Test
    func `Parse filename with spaces`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"my document.pdf\""
        )
        #expect(disposition.filename?.value == "my document.pdf")
    }

    // MARK: - Convenience Constructor Tests

    @Test
    func `Create inline using convenience`() {
        let disposition = RFC_2183.ContentDisposition.inline()
        #expect(disposition.type == .inline)
        #expect(String(disposition) == "inline")
    }

    @Test
    func `Create attachment using convenience`() throws {
        let disposition = RFC_2183.ContentDisposition.attachment(filename: try .init("report.pdf"))
        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "report.pdf")
        #expect(String(disposition) == "attachment; filename=\"report.pdf\"")
    }

    @Test
    func `Create form-data using convenience`() throws {
        let disposition = RFC_2183.ContentDisposition.formData(name: "avatar", filename: try .init("photo.jpg"))
        #expect(disposition.type == .formData)
        #expect(disposition.name == "avatar")
        #expect(disposition.filename?.value == "photo.jpg")
    }

    // MARK: - String Literal Tests

    @Test
    func `Create from string literal`() throws {
        let disposition: RFC_2183.ContentDisposition = try .init(parsing: #"attachment; filename="test.txt""#)
        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "test.txt")
    }

    @Test
    func `Create disposition type from string literal`() {
        let type: RFC_2183.DispositionType = "inline"
        #expect(type == .inline)
    }

    // MARK: - Roundtrip Tests

    @Test
    func `Roundtrip parse and render - simple`() throws {
        let original = "attachment; filename=\"document.pdf\""
        let disposition = try RFC_2183.ContentDisposition(parsing: original)
        #expect(String(disposition) == original)
    }

    @Test
    func `Roundtrip parse and render - complex`() throws {
        let original = "attachment; filename=\"data.bin\"; size=1024"
        let disposition = try RFC_2183.ContentDisposition(parsing: original)
        #expect(String(disposition) == original)
    }

    // MARK: - Custom Disposition Types

    @Test
    func `Custom disposition type`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "x-custom; param=value")
        #expect(disposition.type.rawValue == "x-custom")
        #expect(disposition.parameters.extensionParameters[.init(rawValue: "param")] == "value")
    }

    // MARK: - Edge Cases

    @Test
    func `Empty filename parameter`() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment; filename=\"\"")
        #expect(disposition.filename?.value == "")
    }

    @Test
    func `Whitespace handling`() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment  ;  filename=\"doc.pdf\"  "
        )
        #expect(disposition.type == .attachment)
        #expect(disposition.filename?.value == "doc.pdf")
    }
}

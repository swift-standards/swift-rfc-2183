import Testing
@testable import RFC_2183

@Suite("Content-Disposition Tests")
struct ContentDispositionTests {

    // MARK: - Basic Parsing Tests

    @Test("Parse inline disposition")
    func parseInline() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "inline")
        #expect(disposition.type == .inline)
        #expect(disposition.parameters.isEmpty)
        #expect(disposition.headerValue == "inline")
    }

    @Test("Parse attachment without filename")
    func parseAttachmentWithoutFilename() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment")
        #expect(disposition.type == .attachment)
        #expect(disposition.parameters.isEmpty)
        #expect(disposition.filename == nil)
    }

    @Test("Parse attachment with filename")
    func parseAttachmentWithFilename() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment; filename=\"document.pdf\"")
        #expect(disposition.type == .attachment)
        #expect(disposition.filename == "document.pdf")
        #expect(disposition.headerValue == "attachment; filename=\"document.pdf\"")
    }

    @Test("Parse form-data with name")
    func parseFormDataWithName() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "form-data; name=\"username\"")
        #expect(disposition.type == .formData)
        #expect(disposition.name == "username")
    }

    @Test("Parse form-data with name and filename")
    func parseFormDataWithNameAndFilename() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "form-data; name=\"avatar\"; filename=\"photo.jpg\"")
        #expect(disposition.type == .formData)
        #expect(disposition.name == "avatar")
        #expect(disposition.filename == "photo.jpg")
    }

    // MARK: - Parameter Tests

    @Test("Parse size parameter")
    func parseSizeParameter() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"data.bin\"; size=1048576"
        )
        #expect(disposition.filename == "data.bin")
        #expect(disposition.size == 1048576)
    }

    @Test("Parse date parameters")
    func parseDateParameters() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"doc.pdf\"; creation-date=\"Mon, 01 Jan 2024 12:00:00 GMT\""
        )
        #expect(disposition.filename == "doc.pdf")
        #expect(disposition.creationDate == "Mon, 01 Jan 2024 12:00:00 GMT")
    }

    // MARK: - Escaping Tests

    @Test("Parse filename with escaped quotes")
    func parseFilenameWithEscapedQuotes() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: #"attachment; filename="file\"with\"quotes.txt""#
        )
        #expect(disposition.filename == #"file"with"quotes.txt"#)
    }

    @Test("Render filename with quotes - escapes them")
    func renderFilenameWithQuotes() {
        let disposition = RFC_2183.ContentDisposition(
            type: .attachment,
            parameters: ["filename": #"file"with"quotes.txt"#]
        )
        #expect(disposition.headerValue == #"attachment; filename="file\"with\"quotes.txt""#)
    }

    @Test("Parse filename with spaces")
    func parseFilenameWithSpaces() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment; filename=\"my document.pdf\""
        )
        #expect(disposition.filename == "my document.pdf")
    }

    // MARK: - Convenience Constructor Tests

    @Test("Create inline using convenience")
    func createInlineConvenience() {
        let disposition = RFC_2183.ContentDisposition.inline()
        #expect(disposition.type == .inline)
        #expect(disposition.headerValue == "inline")
    }

    @Test("Create attachment using convenience")
    func createAttachmentConvenience() {
        let disposition = RFC_2183.ContentDisposition.attachment(filename: "report.pdf")
        #expect(disposition.type == .attachment)
        #expect(disposition.filename == "report.pdf")
        #expect(disposition.headerValue == "attachment; filename=\"report.pdf\"")
    }

    @Test("Create form-data using convenience")
    func createFormDataConvenience() {
        let disposition = RFC_2183.ContentDisposition.formData(name: "avatar", filename: "photo.jpg")
        #expect(disposition.type == .formData)
        #expect(disposition.name == "avatar")
        #expect(disposition.filename == "photo.jpg")
    }

    // MARK: - String Literal Tests

    @Test("Create from string literal")
    func createFromStringLiteral() {
        let disposition: RFC_2183.ContentDisposition = "attachment; filename=\"test.txt\""
        #expect(disposition.type == .attachment)
        #expect(disposition.filename == "test.txt")
    }

    @Test("Create disposition type from string literal")
    func createDispositionTypeFromStringLiteral() {
        let type: RFC_2183.DispositionType = "inline"
        #expect(type == .inline)
    }

    // MARK: - Roundtrip Tests

    @Test("Roundtrip parse and render - simple")
    func roundtripSimple() throws {
        let original = "attachment; filename=\"document.pdf\""
        let disposition = try RFC_2183.ContentDisposition(parsing: original)
        #expect(disposition.headerValue == original)
    }

    @Test("Roundtrip parse and render - complex")
    func roundtripComplex() throws {
        let original = "attachment; filename=\"data.bin\"; size=1024"
        let disposition = try RFC_2183.ContentDisposition(parsing: original)
        #expect(disposition.headerValue == original)
    }

    // MARK: - Custom Disposition Types

    @Test("Custom disposition type")
    func customDispositionType() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "x-custom; param=value")
        #expect(disposition.type.rawValue == "x-custom")
        #expect(disposition.parameters["param"] == "value")
    }

    // MARK: - Edge Cases

    @Test("Empty filename parameter")
    func emptyFilenameParameter() throws {
        let disposition = try RFC_2183.ContentDisposition(parsing: "attachment; filename=\"\"")
        #expect(disposition.filename == "")
    }

    @Test("Whitespace handling")
    func whitespaceHandling() throws {
        let disposition = try RFC_2183.ContentDisposition(
            parsing: "attachment  ;  filename=\"doc.pdf\"  "
        )
        #expect(disposition.type == .attachment)
        #expect(disposition.filename == "doc.pdf")
    }
}

public import ASCII_Serializer
public import Binary_Serializable
import INCITS_4_1986
public import Parseable_ASCII
import RFC_2045
public import RFC_5322

private typealias Code = ASCII.Code

extension RFC_2183 {

    public struct ContentDisposition: Hashable, Sendable, Codable {

        public let type: DispositionType

        public let parameters: Parameters

        public init(
            type: DispositionType,
            parameters: Parameters = Parameters()
        ) {
            self.type = type
            self.parameters = parameters
        }
    }
}

extension [Byte] {
    public init(
        _ contentDisposition: RFC_2183.ContentDisposition.Type
    ) {
        self = [Byte]("Content-Disposition".utf8)
    }
}

extension RFC_2183.ContentDisposition: ASCII.Serializable, Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ disposition: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        RFC_2183.DispositionType.serialize(disposition.type, into: &buffer)
        RFC_2183.Parameters.serialize(disposition.parameters, into: &buffer)
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ disposition: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_2183.DispositionType.serialize(disposition.type, into: &buffer)
        RFC_2183.Parameters.serialize(disposition.parameters, into: &buffer)
    }
}

extension RFC_2183.ContentDisposition: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard let firstSemicolon = bytes.firstIndex(where: { $0 == Code.semicolon.byte }) else {

            let typeString = String(decoding: bytes, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !typeString.isEmpty else {
                throw Error.emptyDispositionType
            }

            self.type = RFC_2183.DispositionType(rawValue: typeString)
            self.parameters = .init()
            return
        }

        let typeString = String(decoding: bytes[..<firstSemicolon], as: UTF8.self)
            .trimming(.ascii.whitespaces)
        guard !typeString.isEmpty else {
            throw Error.emptyDispositionType
        }

        self.type = RFC_2183.DispositionType(rawValue: typeString)

        let parametersStartIndex = bytes.index(after: firstSemicolon)
        let parametersSlice = bytes[parametersStartIndex...]

        var rawParams: [String: String] = [:]

        let pCodes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            pCodes = try [ASCII.Code](parametersSlice)
        } catch {
            throw Error.invalidFormat(String(decoding: bytes, as: UTF8.self))
        }
        var segStart = 0

        func processParam(_ lo: Int, _ hi: Int) {
            let segment = pCodes[lo..<hi]

            guard let equalsIndex = segment.firstIndex(of: Code.equalsSign) else {
                return
            }

            let keySlice = segment[..<equalsIndex]
            let keyString = String(decoding: keySlice, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !keyString.isEmpty else { return }

            let valueRawSlice = segment[(equalsIndex &+ 1)...]
            let valueString = String(decoding: valueRawSlice, as: UTF8.self)
                .trimming(.ascii.whitespaces)
            guard !valueString.isEmpty else { return }

            let valueCodes = valueString.utf8.compactMap { byte -> ASCII.Code? in
                do throws(ASCII.Code.Error) {
                    return try ASCII.Code(Byte(byte))
                } catch {
                    return nil
                }
            }

            guard let firstCode = valueCodes.first else { return }
            let lastCode = valueCodes.last ?? firstCode
            let length = valueCodes.count

            let key = keyString.lowercased()

            let value: String
            let isQuoted =
                firstCode == Code.quotationMark
                && lastCode == Code.quotationMark
                && length >= 2
            if isQuoted {
                let inner = valueCodes.dropFirst().dropLast()
                let unescaped = Self.unescapeQuotes(inner)
                value = String(decoding: unescaped, as: UTF8.self)
            } else {
                value = valueString
            }

            rawParams[key] = value
        }

        for idx in 0..<pCodes.count {
            if pCodes[idx] == Code.semicolon {
                processParam(segStart, idx)
                segStart = idx &+ 1
            }
        }
        processParam(segStart, pCodes.count)

        self.parameters = Self.parseParameters(rawParams)
    }

    private static func unescapeQuotes<C: Collection>(
        _ bytes: C
    ) -> [Byte] where C.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity(bytes.count)

        var i = bytes.startIndex
        let end = bytes.endIndex

        while i != end {
            let current = bytes[i]
            let nextIndex = bytes.index(after: i)

            let isEscapedQuote =
                nextIndex != end
                && current == Code.reverseSolidus
                && bytes[nextIndex] == Code.quotationMark
            if isEscapedQuote {

                result.append(Code.quotationMark)

                i = bytes.index(after: nextIndex)
            } else {

                result.append(current)
                i = nextIndex
            }
        }

        return result
    }
}

extension RFC_2183.ContentDisposition {

    package static func parseParameters(_ raw: [String: String]) -> RFC_2183.Parameters {
        var params = RFC_2183.Parameters()

        if let filenameStr = raw["filename"] {
            do throws(RFC_2183.Filename.Error) {
                params.filename = try RFC_2183.Filename(filenameStr)
            } catch {
                params.filename = nil
            }
        }

        if let creationDateStr = raw["creation-date"] {
            do throws(RFC_5322.DateTime.Error) {
                params.creationDate = try RFC_5322.DateTime(ascii: [Byte](creationDateStr.utf8))
            } catch {
                params.creationDate = nil
            }
        }

        if let modDateStr = raw["modification-date"] {
            do throws(RFC_5322.DateTime.Error) {
                params.modificationDate = try RFC_5322.DateTime(ascii: [Byte](modDateStr.utf8))
            } catch {
                params.modificationDate = nil
            }
        }

        if let readDateStr = raw["read-date"] {
            do throws(RFC_5322.DateTime.Error) {
                params.readDate = try RFC_5322.DateTime(ascii: [Byte](readDateStr.utf8))
            } catch {
                params.readDate = nil
            }
        }

        if let sizeStr = raw["size"] {
            do throws(RFC_2183.Size.Error) {
                params.size = try RFC_2183.Size(bytes: Int(sizeStr) ?? -1)
            } catch {
                params.size = nil
            }
        }

        params.name = raw["name"]

        let knownKeys: Set<String> = [
            "filename",
            "creation-date",
            "modification-date",
            "read-date",
            "size",
            "name",
        ]

        for (key, value) in raw where !knownKeys.contains(key) {
            params.extensionParameters[RFC_2045.Parameter.Name(rawValue: key)] = value
        }

        return params
    }
}

extension RFC_2183.ContentDisposition {

    public var filename: RFC_2183.Filename? {
        parameters.filename
    }

    public var creationDate: RFC_5322.DateTime? {
        parameters.creationDate
    }

    public var modificationDate: RFC_5322.DateTime? {
        parameters.modificationDate
    }

    public var readDate: RFC_5322.DateTime? {
        parameters.readDate
    }

    public var size: RFC_2183.Size? {
        parameters.size
    }

    public var name: String? {
        parameters.name
    }
}

extension RFC_2183.ContentDisposition {

    public static func inline() -> Self {
        Self(type: .inline)
    }

    public static func attachment(
        filename: RFC_2183.Filename? = nil,
        size: RFC_2183.Size? = nil,
        creationDate: RFC_5322.DateTime? = nil,
        modificationDate: RFC_5322.DateTime? = nil,
        readDate: RFC_5322.DateTime? = nil
    ) -> Self {
        Self(
            type: .attachment,
            parameters: .init(
                filename: filename,
                creationDate: creationDate,
                modificationDate: modificationDate,
                readDate: readDate,
                size: size
            )
        )
    }

    public static func formData(name: String, filename: RFC_2183.Filename? = nil) -> Self {
        Self(
            type: .formData,
            parameters: .init(
                filename: filename,
                name: name
            )
        )
    }
}

extension RFC_2183.ContentDisposition: CustomStringConvertible {

    public var description: String {
        var codes: [ASCII.Code] = []
        Self.serialize(self, into: &codes)
        return String(decoding: codes.map(\.byte), as: UTF8.self)
    }
}

extension RFC_2183.DispositionType: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension RFC_2183.DispositionType: CustomStringConvertible {
    public var description: String { rawValue }
}

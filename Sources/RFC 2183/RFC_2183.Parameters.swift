public import ASCII_Serializer
public import Binary_Serializable
public import RFC_2045
public import RFC_5322

private typealias Code = ASCII.Code

extension RFC_2183 {

    public struct Parameters: Hashable, Sendable, Codable {

        public var filename: Filename?

        public var creationDate: RFC_5322.DateTime?

        public var modificationDate: RFC_5322.DateTime?

        public var readDate: RFC_5322.DateTime?

        public var size: Size?

        public var name: String?

        public var extensionParameters: [ParameterName: String]

        public init(
            filename: Filename? = nil,
            creationDate: RFC_5322.DateTime? = nil,
            modificationDate: RFC_5322.DateTime? = nil,
            readDate: RFC_5322.DateTime? = nil,
            size: Size? = nil,
            name: String? = nil,
            extensionParameters: [ParameterName: String] = [:]
        ) {
            self.filename = filename
            self.creationDate = creationDate
            self.modificationDate = modificationDate
            self.readDate = readDate
            self.size = size
            self.name = name
            self.extensionParameters = extensionParameters
        }
    }
}

extension RFC_2183.Parameters: ASCII.Serializable, Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ params: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        if let filename = params.filename {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "filename".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in filename.value.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }

        if let creationDate = params.creationDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "creation-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(creationDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let modificationDate = params.modificationDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "modification-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(modificationDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let readDate = params.readDate {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "read-date".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            RFC_5322.DateTime.serialize(readDate, into: &buffer)
            buffer.append(Code.quotationMark)
        }

        if let size = params.size {

            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "size".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            RFC_2183.Size.serialize(size, into: &buffer)
        }

        if let name = params.name {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)
            for c in "name".utf8 { buffer.append(ASCII.Code(c)) }
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in name.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }

        for (key, value) in params.extensionParameters.sorted(by: {
            $0.key.rawValue < $1.key.rawValue
        }) {
            buffer.append(Code.semicolon)
            buffer.append(Code.space)

            RFC_2045.Parameter.Name.serialize(key, into: &buffer)
            buffer.append(Code.equalsSign)
            buffer.append(Code.quotationMark)
            for c in value.utf8 {
                let code = ASCII.Code(c)
                if code == Code.quotationMark { buffer.append(Code.reverseSolidus) }
                buffer.append(code)
            }
            buffer.append(Code.quotationMark)
        }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ params: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        if let filename = params.filename {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "filename".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in filename.value.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }

        if let creationDate = params.creationDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "creation-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(creationDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let modificationDate = params.modificationDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "modification-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(modificationDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let readDate = params.readDate {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "read-date".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            RFC_5322.DateTime.serialize(readDate, into: &buffer)
            buffer.append(Code.quotationMark.byte)
        }

        if let size = params.size {

            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "size".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            RFC_2183.Size.serialize(size, into: &buffer)
        }

        if let name = params.name {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)
            for c in "name".utf8 { buffer.append(Byte(c)) }
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in name.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }

        for (key, value) in params.extensionParameters.sorted(by: {
            $0.key.rawValue < $1.key.rawValue
        }) {
            buffer.append(Code.semicolon.byte)
            buffer.append(Code.space.byte)

            RFC_2045.Parameter.Name.serialize(key, into: &buffer)
            buffer.append(Code.equalsSign.byte)
            buffer.append(Code.quotationMark.byte)
            for c in value.utf8 {
                if ASCII.Code(c) == Code.quotationMark { buffer.append(Code.reverseSolidus.byte) }
                buffer.append(Byte(c))
            }
            buffer.append(Code.quotationMark.byte)
        }
    }
}

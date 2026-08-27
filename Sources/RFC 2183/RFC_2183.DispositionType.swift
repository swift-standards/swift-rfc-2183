public import ASCII_Serializer
public import Binary_Serializable

extension RFC_2183 {

    public struct DispositionType: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue.lowercased()
        }
    }
}

extension RFC_2183.DispositionType {

    public static let inline = Self(rawValue: "inline")

    public static let attachment = Self(rawValue: "attachment")

    public static let formData = Self(rawValue: "form-data")
}

extension RFC_2183.DispositionType: ASCII.Serializable, Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        for byte in value.rawValue.utf8 { buffer.append(ASCII.Code(byte)) }
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        for byte in value.rawValue.utf8 { buffer.append(Byte(byte)) }
    }
}

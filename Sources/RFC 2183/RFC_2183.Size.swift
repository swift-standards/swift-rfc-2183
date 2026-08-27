public import ASCII_Serializer
public import Binary_Serializable
public import Parseable_ASCII

extension RFC_2183 {

    public struct Size: Hashable, Sendable, Codable, Comparable {

        public let bytes: Int

        init(__unchecked bytes: Int) {
            self.bytes = bytes
        }

        public init(bytes: Int) throws(Error) {
            guard bytes >= 0 else {
                throw Error.negative(bytes)
            }
            self.init(__unchecked: bytes)
        }
    }
}

extension RFC_2183.Size {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.bytes < rhs.bytes
    }
}

extension RFC_2183.Size: ASCII.Parseable {

    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let string = String(decoding: bytes, as: UTF8.self)
        guard let value = Int(string) else {
            throw Error.invalidFormat(string)
        }
        guard value >= 0 else {
            throw Error.negative(value)
        }
        self.init(__unchecked: value)
    }
}

extension [Byte] {

    public init(_ size: RFC_2183.Size) {
        self = [Byte](String(size.bytes).utf8)
    }
}

extension RFC_2183.Size: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {
    public var rawValue: String { String(bytes) }

    public init?(rawValue: String) {
        guard let value = Int(rawValue), value >= 0 else {
            return nil
        }
        self.init(__unchecked: value)
    }

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

extension RFC_2183.Size: CustomStringConvertible {

    public var description: String { String(bytes) }
}

extension RFC_2183.Size: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let bytes = Int(description), bytes >= 0 else {
            return nil
        }
        self.init(__unchecked: bytes)
    }
}

extension RFC_2183.Size: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(__unchecked: value)
    }
}

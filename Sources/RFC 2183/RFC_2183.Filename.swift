public import ASCII_Serializer
public import Binary_Serializable
import INCITS_4_1986
public import Parseable_ASCII

private typealias Code = ASCII.Code

extension RFC_2183 {

    public struct Filename: Hashable, Sendable, Codable {

        public let value: String

        init(__unchecked value: String) {
            self.value = value
        }
    }
}

extension RFC_2183.Filename {

    public var baseName: String {
        value
    }
}

extension RFC_2183.Filename: Swift.RawRepresentable, ASCII.Serializable, Binary.Serializable {
    public var rawValue: String { value }

    public init?(rawValue: String) {
        do throws(RFC_2183.Filename.Error) {
            try self.init(rawValue)
        } catch {
            return nil
        }
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

extension RFC_2183.Filename: CustomStringConvertible {

    public var description: String { value }
}

extension RFC_2183.Filename: ASCII.Parseable {

    public init(_ string: some StringProtocol) throws(Error) {
        try self.init(ascii: [Byte](string.utf8))
    }

    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {

        guard !bytes.isEmpty else {
            throw Error.empty
        }

        for byte in bytes {

            let code: ASCII.Code
            do throws(ASCII.Code.Error) {
                code = try ASCII.Code(byte)
            } catch {
                throw Error.notASCII(String(decoding: bytes, as: UTF8.self))
            }
            guard code.isVisible || code == Code.space else {

                throw Error.containsControlCharacters(
                    String(decoding: bytes, as: UTF8.self),
                    byte: code
                )
            }
        }

        let value = String(decoding: bytes, as: UTF8.self)

        guard !value.contains("..") else {
            throw Error.containsPathTraversal(value)
        }

        guard !value.contains("/"), !value.contains("\\") else {
            throw Error.containsPathSeparator(value)
        }

        guard !value.hasPrefix("/"), !value.hasPrefix("\\") else {
            throw Error.isAbsolutePath(value)
        }

        self.init(__unchecked: value)
    }
}

extension [Byte] {

    public init(_ filename: RFC_2183.Filename) {
        self = [Byte](filename.value.utf8)
    }
}

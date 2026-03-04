//
//  RFC_2183.ContentDisposition.Parse.swift
//  swift-rfc-2183
//
//  Content-Disposition: disposition-type *(";" parameter)
//

public import Parser_Primitives
public import RFC_2045

extension RFC_2183.ContentDisposition {
    /// Parses a Content-Disposition header per RFC 2183 Section 2.
    ///
    /// `disposition = disposition-type *(";" disposition-parm)`
    ///
    /// Where `disposition-parm = token "=" (token / quoted-string)`
    ///
    /// Returns the disposition type and parameters as raw byte slices.
    /// Reuses `RFC_2045.Parse.Token` and `RFC_2045.Parse.QuotedString`
    /// since MIME parameter syntax is shared.
    public struct Parse<Input: Collection.Slice.`Protocol`>: Sendable
    where Input: Sendable, Input.Element == UInt8 {
        @inlinable
        public init() {}
    }
}

extension RFC_2183.ContentDisposition.Parse {
    public struct Parameter: Sendable {
        public let name: Input
        public let value: Input

        @inlinable
        public init(name: Input, value: Input) {
            self.name = name
            self.value = value
        }
    }

    public struct Output: Sendable {
        public let dispositionType: Input
        public let parameters: [Parameter]

        @inlinable
        public init(dispositionType: Input, parameters: [Parameter]) {
            self.dispositionType = dispositionType
            self.parameters = parameters
        }
    }

    public enum Error: Swift.Error, Sendable, Equatable {
        case expectedToken
    }
}

extension RFC_2183.ContentDisposition.Parse: Parser.`Protocol` {
    public typealias Failure = RFC_2183.ContentDisposition.Parse<Input>.Error

    @inlinable
    public func parse(_ input: inout Input) throws(Failure) -> Output {
        // Parse disposition type (token)
        let dispositionType: Input
        do {
            dispositionType = try RFC_2045.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedToken
        }

        // Parse optional parameters: *(";" OWS token "=" (token / quoted-string))
        var parameters: [Parameter] = []

        while input.startIndex < input.endIndex {
            // Skip OWS
            Self._skipOWS(&input)

            // Expect ';'
            guard input.startIndex < input.endIndex,
                input[input.startIndex] == 0x3B
            else {
                break
            }
            input = input[input.index(after: input.startIndex)...]

            // Skip OWS
            Self._skipOWS(&input)

            // Parse parameter name (token)
            guard let name = try? RFC_2045.Parse.Token<Input>().parse(&input) else {
                break
            }

            // Expect '='
            guard input.startIndex < input.endIndex,
                input[input.startIndex] == 0x3D
            else {
                break
            }
            input = input[input.index(after: input.startIndex)...]

            // Parse value (token or quoted-string)
            let value: Input
            if input.startIndex < input.endIndex && input[input.startIndex] == 0x22 {
                guard let qs = try? RFC_2045.Parse.QuotedString<Input>().parse(&input) else {
                    break
                }
                value = qs
            } else {
                guard let tok = try? RFC_2045.Parse.Token<Input>().parse(&input) else {
                    break
                }
                value = tok
            }

            parameters.append(Parameter(name: name, value: value))
        }

        return Output(dispositionType: dispositionType, parameters: parameters)
    }

    @inlinable
    static func _skipOWS(_ input: inout Input) {
        while input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            guard byte == 0x20 || byte == 0x09 else { break }
            input = input[input.index(after: input.startIndex)...]
        }
    }
}

public import Parser
public import RFC_2045

extension RFC_2183.ContentDisposition {

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

        let dispositionType: Input
        do throws(RFC_2045.Parse.Token<Input>.Error) {
            dispositionType = try RFC_2045.Parse.Token<Input>().parse(&input)
        } catch {
            throw .expectedToken
        }

        var parameters: [Parameter] = []

        while input.startIndex < input.endIndex {

            Self._skipOWS(&input)

            guard input.startIndex < input.endIndex,
                input[input.startIndex] == 0x3B
            else {
                break
            }
            input = input[input.index(after: input.startIndex)...]

            Self._skipOWS(&input)

            let name: Input
            do throws(RFC_2045.Parse.Token<Input>.Error) {
                name = try RFC_2045.Parse.Token<Input>().parse(&input)
            } catch {
                break
            }

            guard input.startIndex < input.endIndex,
                input[input.startIndex] == 0x3D
            else {
                break
            }
            input = input[input.index(after: input.startIndex)...]

            let value: Input
            if input.startIndex < input.endIndex && input[input.startIndex] == 0x22 {
                let qs: Input
                do throws(RFC_2045.Parse.QuotedString<Input>.Error) {
                    qs = try RFC_2045.Parse.QuotedString<Input>().parse(&input)
                } catch {
                    break
                }
                value = qs
            } else {
                let tok: Input
                do throws(RFC_2045.Parse.Token<Input>.Error) {
                    tok = try RFC_2045.Parse.Token<Input>().parse(&input)
                } catch {
                    break
                }
                value = tok
            }

            parameters.append(Parameter(name: name, value: value))
        }

        return Output(dispositionType: dispositionType, parameters: parameters)
    }

    @inlinable
    package static func _skipOWS(_ input: inout Input) {
        while input.startIndex < input.endIndex {
            let byte = input[input.startIndex]
            guard byte == 0x20 || byte == 0x09 else { break }
            input = input[input.index(after: input.startIndex)...]
        }
    }
}

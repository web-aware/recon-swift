public protocol ReconParser {
  func feed(input: ReconInput) -> ReconParsee

  func cont(parser: ReconParser, _ input: ReconInput) -> ReconParsee

  func done(value: Any, _ input: ReconInput) -> ReconParsee

  func fail(reason: String, _ input: ReconInput) -> ReconParsee

  func expected(expected: String, _ input: ReconInput) -> ReconParsee

  func unexpectedEOF(input: ReconInput) -> ReconParsee

  func run(input: ReconInput) -> ReconParsee

  func parse(string: String) -> ReconParsee
}

extension ReconParser {
  func cont(parser: ReconParser, _ input: ReconInput) -> ReconParsee {
    return ReconParsee.Cont(parser, input)
  }

  func done(value: Any, _ input: ReconInput) -> ReconParsee {
    return ReconParsee.Done(value, input)
  }

  func fail(reason: String, _ input: ReconInput) -> ReconParsee {
    return ReconParsee.Fail(reason, input)
  }

  func expected(expected: String, _ input: ReconInput) -> ReconParsee {
    if let found = input.head {
      return fail("expected \(expected), but found \(found)", input)
    } else {
      return fail("unexpected \(expected)", input)
    }
  }

  func unexpectedEOF(input: ReconInput) -> ReconParsee {
    return fail("Unexpected EOF", input)
  }

  func run(input: ReconInput) -> ReconParsee {
    var parsee = cont(self, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, _):
      return next.feed(ReconInputDone())
    default:
      return parsee
    }
  }

  func parse(string: String) -> ReconParsee {
    return run(ReconInputString(string))
  }
}


struct ReconDocumentParser: ReconParser {
  let value: ReconParser

  init(_ value: ReconParser) {
    self.value = value
  }

  init() {
    self.init(ReconBlockParser())
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.value, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconDocumentParser(next), remaining)
    case ReconParsee.Done(_, let remaining) where !input.isEmpty:
      return expected("end of input", remaining)
    default:
      return parsee
    }
  }
}


struct ReconBlockParser: ReconParser {
  let builder: ValueBuilder

  init(_ builder: ValueBuilder) {
    self.builder = builder
  }

  init() {
    self.init(ValueBuilder())
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isWhitespace(c) {
      input = input.tail
    }
    if let c = input.head {
      if c == "@" || c == "{" || c == "[" || isNameStartChar(c) || c == "\"" || c == "-" || c >= "0" && c <= "9" || c == "%" {
        return cont(ReconBlockKeyParser(builder), input)
      } else {
        return expected("block value", input)
      }
    } else if input.isDone {
      return done(builder.state, input)
    }
    return cont(ReconBlockParser(builder), input)
  }
}

struct ReconBlockKeyParser: ReconParser {
  let key: ReconParser
  let builder: ValueBuilder

  init(_ key: ReconParser, _ builder: ValueBuilder) {
    self.key = key
    self.builder = builder
  }

  init(_ builder: ValueBuilder) {
    self.init(ReconBlockItemParser(), builder)
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.key, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconBlockKeyParser(next, builder), remaining)
    case ReconParsee.Done(let key as Value, let remaining):
      if remaining.isDone {
        var builder = self.builder
        builder.appendValue(key)
        return done(builder.state, remaining)
      } else {
        return cont(ReconBlockKeyRestParser(key, builder), remaining)
      }
    default:
      return parsee
    }
  }
}

struct ReconBlockKeyRestParser: ReconParser {
  let key: Value
  let builder: ValueBuilder

  init(_ key: Value, _ builder: ValueBuilder) {
    self.key = key
    self.builder = builder
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var builder = self.builder
    while let c = input.head where isSpace(c) {
      input = input.tail
    }
    if let c = input.head where c == ":" {
      return cont(ReconBlockKeyThenValueParser(key, builder), input.tail)
    } else if !input.isEmpty {
      builder.appendValue(key)
      return cont(ReconBlockSeparatorParser(builder), input)
    } else if input.isDone {
      builder.appendValue(key)
      return done(builder.state, input)
    }
    return cont(ReconBlockKeyRestParser(key, builder), input)
  }
}

struct ReconBlockKeyThenValueParser: ReconParser {
  let key: Value
  let builder: ValueBuilder

  init(_ key: Value, _ builder: ValueBuilder) {
    self.key = key
    self.builder = builder
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var builder = self.builder
    while let c = input.head where isSpace(c) {
      input = input.tail
    }
    if !input.isEmpty {
      return cont(ReconBlockKeyValueParser(key, builder), input)
    } else if input.isDone {
      builder.appendSlot(key)
      return done(builder.state, input)
    }
    return cont(ReconBlockKeyThenValueParser(key, builder), input)
  }
}

struct ReconBlockKeyValueParser: ReconParser {
  let key: Value
  let value: ReconParser
  let builder: ValueBuilder

  init(_ key: Value, _ value: ReconParser, _ builder: ValueBuilder) {
    self.key = key
    self.value = value
    self.builder = builder
  }

  init(_ key: Value, _ builder: ValueBuilder) {
    self.init(key, ReconBlockItemParser(), builder)
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.value, input)
    var builder = self.builder
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconBlockKeyValueParser(key, next, builder), remaining)
    case ReconParsee.Done(let value as Value, let remaining):
      builder.appendSlot(key, value)
      return cont(ReconBlockSeparatorParser(builder), remaining)
    default:
      return parsee
    }
  }
}

struct ReconBlockSeparatorParser: ReconParser {
  let builder: ValueBuilder

  init(_ builder: ValueBuilder) {
    self.builder = builder
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isSpace(c) {
      input = input.tail
    }
    if let c = input.head where c == "," || c == ";" || isNewline(c) {
      return cont(ReconBlockParser(builder), input.tail)
    } else if !input.isEmpty || input.isDone {
      return done(builder.state, input)
    }
    return cont(ReconBlockSeparatorParser(builder), input)
  }
}


struct ReconAttrParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head where c == "@" {
      return cont(ReconAttrIdentParser(), input.tail)
    } else if !input.isEmpty {
      return expected("attribute", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconAttrIdentParser: ReconParser {
  let ident: ReconParser

  init(_ ident: ReconParser) {
    self.ident = ident
  }

  init() {
    self.init(ReconIdentParser())
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(ident, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconAttrIdentParser(next), remaining)
    case ReconParsee.Done(let key as String, let remaining):
      if !remaining.isDone {
        return cont(ReconAttrIdentRestParser(key), remaining)
      } else {
        return done(Field.Attr(key: key, value: Value.Extant), remaining)
      }
    default:
      return parsee
    }
  }
}

struct ReconAttrIdentRestParser: ReconParser {
  let key: String

  init(_ key: String) {
    self.key = key
  }

  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head where c == "(" {
      return cont(ReconAttrParamBlockParser(key), input.tail)
    } else if !input.isEmpty || input.isDone {
      return done(Field.Attr(key: key, value: Value.Extant), input)
    }
    return cont(self, input)
  }
}

struct ReconAttrParamBlockParser: ReconParser {
  let key: String

  init(_ key: String) {
    self.key = key
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isWhitespace(c) {
      input = input.tail
    }
    if let c = input.head where c == ")" {
      return done(Field.Attr(key: key, value: Value.Extant), input.tail)
    } else if !input.isEmpty {
      return cont(ReconAttrParamParser(key), input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(ReconAttrParamBlockParser(key), input)
  }
}

struct ReconAttrParamParser: ReconParser {
  let key: String
  let value: ReconParser

  init(_ key: String, _ value: ReconParser) {
    self.key = key
    self.value = value
  }

  init(_ key: String) {
    self.init(key, ReconBlockParser())
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.value, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconAttrParamParser(key, next), remaining)
    case ReconParsee.Done(let value as Value, let remaining):
      return cont(ReconAttrParamRestParser(key, value), remaining)
    default:
      return parsee
    }
  }
}

struct ReconAttrParamRestParser: ReconParser {
  let key: String
  let value: Value

  init(_ key: String, _ value: Value) {
    self.key = key
    self.value = value
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isWhitespace(c) {
      input = input.tail
    }
    if let c = input.head where c == ")" {
      return done(Field.Attr(key: key, value: value), input.tail)
    } else if !input.isEmpty {
      return expected(")", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(ReconAttrParamRestParser(key, value), input)
  }
}


struct ReconBlockItemParser: ReconParser {
  let builder: ReconBuilder?

  init(_ builder: ReconBuilder?) {
    self.builder = builder
  }

  init() {
    self.init(nil)
  }

  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head {
      switch c {
      case "@":
        return cont(ReconBlockItemFieldParser(ReconAttrParser(), builder), input)
      case "{":
        let builder = self.builder ?? RecordBuilder()
        let value = ReconRecordParser(builder)
        return cont(ReconBlockItemInnerParser(value, builder), input)
      case "[":
        let builder = self.builder ?? RecordBuilder()
        let value = ReconMarkupParser(builder)
        return cont(ReconBlockItemInnerParser(value, builder), input)
      case _ where isNameStartChar(c):
        return cont(ReconBlockItemValueParser(ReconIdentParser(), builder), input)
      case "\"":
        return cont(ReconBlockItemValueParser(ReconStringParser(), builder), input)
      case _ where c == "-" || c >= "0" && c <= "9":
        return cont(ReconBlockItemValueParser(ReconNumberParser(), builder), input)
      case "%":
        return cont(ReconBlockItemValueParser(ReconDataParser(), builder), input)
      default:
        if let builder = self.builder {
          return done(builder.state, input)
        } else {
          return done(Value.Extant, input)
        }
      }
    } else if input.isDone {
      if let builder = self.builder {
        return done(builder.state, input)
      } else {
        return done(Value.Extant, input)
      }
    }
    return cont(ReconBlockItemParser(builder), input)
  }
}

struct ReconBlockItemFieldParser: ReconParser {
  let field: ReconParser
  let builder: ReconBuilder?

  init(_ field: ReconParser, _ builder: ReconBuilder?) {
    self.field = field
    self.builder = builder
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.field, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconBlockItemFieldParser(next, builder), remaining)
    case ReconParsee.Done(let field as Field, let remaining):
      var builder = self.builder ?? ValueBuilder()
      builder.appendField(field)
      return cont(ReconBlockItemFieldRestParser(builder), remaining)
    default:
      return parsee
    }
  }
}

struct ReconBlockItemFieldRestParser: ReconParser {
  let builder: ReconBuilder

  init(_ builder: ReconBuilder) {
    self.builder = builder
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isSpace(c) {
      input = input.tail
    }
    if !input.isEmpty {
      return cont(ReconBlockItemParser(builder), input)
    } else if input.isDone {
      return done(builder.state, input)
    }
    return cont(ReconBlockItemFieldRestParser(builder), input)
  }
}

struct ReconBlockItemValueParser: ReconParser {
  let value: ReconParser
  let builder: ReconBuilder?

  init(_ value: ReconParser, _ builder: ReconBuilder?) {
    self.value = value
    self.builder = builder
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.value, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconBlockItemValueParser(next, builder), remaining)
    case ReconParsee.Done(let value, let remaining):
      var builder = self.builder ?? ValueBuilder()
      builder.appendAny(value)
      if remaining.isDone {
        return done(builder.state, remaining)
      } else {
        return cont(ReconBlockItemRestParser(builder), remaining)
      }
    default:
      return parsee
    }
  }
}

struct ReconBlockItemInnerParser: ReconParser {
  let value: ReconParser
  let builder: ReconBuilder

  init(_ value: ReconParser, _ builder: ReconBuilder) {
    self.value = value
    self.builder = builder
  }

  func feed(input: ReconInput) -> ReconParsee {
    var parsee = cont(self.value, input)
    while case ReconParsee.Cont(let next, let remaining) = parsee where !remaining.isEmpty || remaining.isDone {
      parsee = next.feed(remaining)
    }
    switch parsee {
    case ReconParsee.Cont(let next, let remaining):
      return cont(ReconBlockItemInnerParser(next, builder), remaining)
    case ReconParsee.Done(_, let remaining):
      return cont(ReconBlockItemRestParser(builder), remaining)
    default:
      return parsee
    }
  }
}

struct ReconBlockItemRestParser: ReconParser {
  let builder: ReconBuilder

  init(_ builder: ReconBuilder) {
    self.builder = builder
  }

  func feed(var input: ReconInput) -> ReconParsee {
    while let c = input.head where isSpace(c) {
      input = input.tail
    }
    if let c = input.head where c == "@" {
      return cont(ReconBlockItemParser(builder), input)
    } else if !input.isEmpty || input.isDone {
      return done(builder.state, input)
    }
    return cont(ReconBlockItemRestParser(builder), input)
  }
}


struct ReconInlineItemParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    assert(false)
  }
}


struct ReconRecordParser: ReconParser {
  let builder: ReconBuilder?

  init(_ builder: ReconBuilder?) {
    self.builder = builder
  }

  func feed(input: ReconInput) -> ReconParsee {
    assert(false)
  }
}


struct ReconMarkupParser: ReconParser {
  let builder: ReconBuilder?

  init(_ builder: ReconBuilder?) {
    self.builder = builder
  }

  init() {
    self.init(nil)
  }

  func feed(input: ReconInput) -> ReconParsee {
    assert(false)
  }
}


struct ReconIdentParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head where isNameStartChar(c) {
      return cont(ReconIdentRestParser(String(c)), input.tail)
    } else if !input.isEmpty {
      return expected("identifier", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconIdentRestParser: ReconParser {
  let ident: String

  init(_ ident: String) {
    self.ident = ident;
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var ident = self.ident
    while let c = input.head where isNameChar(c) {
      ident.append(c)
      input = input.tail
    }
    if !input.isEmpty || input.isDone {
      return done(ident, input)
    }
    return cont(ReconIdentRestParser(ident), input)
  }
}


struct ReconStringParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head where c == "\"" {
      return cont(ReconStringRestParser(), input.tail)
    } else if !input.isEmpty {
      return expected("string", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconStringRestParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  init() {
    self.init("")
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var string = self.string
    while let c = input.head where c != "\"" && c != "\\" {
      string.append(c)
      input = input.tail
    }
    if let c = input.head {
      if c == "\"" {
        return done(string, input.tail)
      } else if c == "\\" {
        return cont(ReconStringEscapeParser(string), input.tail)
      }
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(ReconStringRestParser(string), input)
  }
}

struct ReconStringEscapeParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head {
      switch c {
      case "\"", "/", "@", "[", "\\", "]", "{", "}":
        string.append(c)
      case "b":
        string.append(UnicodeScalar("\u{8}"))
      case "f":
        string.append(UnicodeScalar("\u{C}"))
      case "n":
        string.append(UnicodeScalar("\n"))
      case "r":
        string.append(UnicodeScalar("\r"))
      case "t":
        string.append(UnicodeScalar("\t"))
      default:
        return expected("escape character", input)
      }
      return cont(ReconStringRestParser(string), input.tail)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}


struct ReconNumberParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head {
      if c == "-" {
        return cont(ReconNumberIntegralParser("-"), input.tail)
      } else {
        return cont(ReconNumberIntegralParser(), input)
      }
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconNumberIntegralParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  init() {
    self.init("")
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head {
      if c == "0" {
        string.append(c)
        return cont(ReconNumberRestParser(string), input.tail)
      } else if c >= "1" && c <= "9" {
        string.append(c)
        return cont(ReconNumberIntegralRestParser(string), input.tail)
      } else {
        return expected("digit", input)
      }
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconNumberIntegralRestParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var string = self.string
    while let c = input.head where c >= "0" && c <= "9" {
      string.append(c)
      input = input.tail
    }
    if !input.isEmpty {
      return cont(ReconNumberRestParser(string), input)
    } else if input.isDone {
      return done(Int(string)!, input)
    }
    return cont(ReconNumberIntegralRestParser(string), input)
  }
}

struct ReconNumberRestParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head {
      if c == "." {
        string.append(c)
        return cont(ReconNumberFractionalParser(string), input.tail)
      }
      else if c == "E" || c == "e" {
        string.append(c)
        return cont(ReconNumberExponentialParser(string), input.tail)
      }
      else {
        return done(Int(string)!, input)
      }
    } else if input.isDone {
      return done(Int(string)!, input)
    }
    return cont(self, input)
  }
}

struct ReconNumberFractionalParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head where c >= "0" && c <= "9" {
      string.append(c)
      return cont(ReconNumberFractionalRestParser(string), input.tail)
    } else if !input.isEmpty {
      return expected("digit", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconNumberFractionalRestParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var string = self.string
    while let c = input.head where c >= "0" && c <= "9" {
      string.append(c)
      input = input.tail
    }
    if !input.isEmpty {
      return cont(ReconNumberFractionalExponentParser(string), input)
    } else if input.isDone {
      return done(Double(string)!, input)
    }
    return cont(ReconNumberFractionalRestParser(string), input)
  }
}

struct ReconNumberFractionalExponentParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head where c == "E" || c == "e" {
      string.append(c)
      return cont(ReconNumberExponentialParser(string), input.tail)
    } else if !input.isEmpty {
      return done(Double(string)!, input)
    } else if input.isDone {
      return done(Double(string)!, input)
    }
    return cont(self, input)
  }
}

struct ReconNumberExponentialParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head {
      if c == "+" || c == "-" {
        string.append(c)
        input = input.tail
      }
      return cont(ReconNumberExponentialPartParser(string), input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconNumberExponentialPartParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(input: ReconInput) -> ReconParsee {
    var string = self.string
    if let c = input.head where c >= "0" && c <= "9" {
      string.append(c)
      return cont(ReconNumberExponentialRestParser(string), input.tail)
    } else if !input.isEmpty {
      return expected("digit", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconNumberExponentialRestParser: ReconParser {
  let string: String

  init(_ string: String) {
    self.string = string
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var string = self.string
    while let c = input.head where c >= "0" && c <= "9" {
      string.append(c)
      input = input.tail
    }
    if !input.isEmpty || input.isDone {
      return done(Double(string)!, input)
    }
    return cont(ReconNumberExponentialRestParser(string), input)
  }
}


struct ReconDataParser: ReconParser {
  func feed(input: ReconInput) -> ReconParsee {
    if let c = input.head where c == "%" {
      return cont(ReconDataRestParser(), input.tail)
    } else if !input.isEmpty {
      return expected("data", input)
    } else if input.isDone {
      return unexpectedEOF(input)
    }
    return cont(self, input)
  }
}

struct ReconDataRestParser: ReconParser {
  let data: Base64Decoder
  let state: Int

  init(_ data: Base64Decoder, _ state: Int) {
    self.data = data
    self.state = state
  }

  init() {
    self.init(Base64Decoder(), 0)
  }

  func feed(var input: ReconInput) -> ReconParsee {
    var data = self.data
    var state = self.state
    while let c = input.head where isBase64Char(c) {
      data.append(c)
      input = input.tail
      state = (state + 1) % 4
    }
    if let c = input.head where state == 2 {
      if c == "=" {
        data.append(c)
        input = input.tail
        state = 4
      } else {
        return expected("base64 digit", input)
      }
    }
    if let c = input.head where state == 3 {
      if c == "=" {
        data.append(c)
        return done(data.state, input.tail)
      } else {
        return expected("base64 digit", input)
      }
    }
    if let c = input.head where state == 4 {
      if c == "=" {
        data.append(c)
        return done(data.state, input.tail)
      } else {
        return expected("=", input)
      }
    }
    if !input.isEmpty {
      if state == 0 {
        return done(data.state, input)
      } else {
        return expected("base64 digit", input)
      }
    } else if input.isDone {
      if state == 0 {
        return done(data.state, input)
      } else {
        return unexpectedEOF(input)
      }
    }
    return cont(ReconDataRestParser(data, state), input)
  }
}


func isSpace(c: UnicodeScalar) -> Bool {
  return c == "\u{20}" || c == "\u{9}"
}

func isNewline(c: UnicodeScalar) -> Bool {
  return c == "\u{A}" || c == "\u{D}"
}

func isWhitespace(c: UnicodeScalar) -> Bool {
  return isSpace(c) || isNewline(c)
}

func isNameStartChar(c: UnicodeScalar) -> Bool {
  return c >= "A" && c <= "Z" ||
    c == "_" ||
    c >= "a" && c <= "z" ||
    c >= "\u{C0}" && c <= "\u{D6}" ||
    c >= "\u{D8}" && c <= "\u{F6}" ||
    c >= "\u{F8}" && c <= "\u{2FF}" ||
    c >= "\u{370}" && c <= "\u{37D}" ||
    c >= "\u{37F}" && c <= "\u{1FFF}" ||
    c >= "\u{200C}" && c <= "\u{200D}" ||
    c >= "\u{2070}" && c <= "\u{218F}" ||
    c >= "\u{2C00}" && c <= "\u{2FEF}" ||
    c >= "\u{3001}" && c <= "\u{D7FF}" ||
    c >= "\u{F900}" && c <= "\u{FDCF}" ||
    c >= "\u{FDF0}" && c <= "\u{FFFD}" ||
    c >= "\u{10000}" && c <= "\u{EFFFF}"
}

func isNameChar(c: UnicodeScalar) -> Bool {
  return c == "-" ||
    c >= "0" && c <= "9" ||
    c >= "A" && c <= "Z" ||
    c == "_" ||
    c >= "a" && c <= "z" ||
    c == "\u{B7}" ||
    c >= "\u{C0}" && c <= "\u{D6}" ||
    c >= "\u{D8}" && c <= "\u{F6}" ||
    c >= "\u{F8}" && c <= "\u{37D}" ||
    c >= "\u{37F}" && c <= "\u{1FFF}" ||
    c >= "\u{200C}" && c <= "\u{200D}" ||
    c >= "\u{203F}" && c <= "\u{2040}" ||
    c >= "\u{2070}" && c <= "\u{218F}" ||
    c >= "\u{2C00}" && c <= "\u{2FEF}" ||
    c >= "\u{3001}" && c <= "\u{D7FF}" ||
    c >= "\u{F900}" && c <= "\u{FDCF}" ||
    c >= "\u{FDF0}" && c <= "\u{FFFD}" ||
    c >= "\u{10000}" && c <= "\u{EFFFF}"
}

func isBase64Char(c: UnicodeScalar) -> Bool {
  return c >= "0" && c <= "9" ||
    c >= "A" && c <= "Z" ||
    c >= "a" && c <= "z" ||
    c == "+" || c == "-" ||
    c == "/" || c == "_"
}

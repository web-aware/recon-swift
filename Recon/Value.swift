public typealias ReconValue = Value

public enum Value: CustomStringConvertible, Hashable {
  case Record(ReconRecord)
  case Text(String)
  case Data(ReconData)
  case Number(Double)
  case Extant
  case Absent

  public init(_ items: Item...) {
    self = Record(ReconRecord(items))
  }

  public init(_ items: [Item]) {
    self = Record(ReconRecord(items))
  }

  public init(_ value: ReconRecord) {
    self = Record(value)
  }

  public init(_ value: String) {
    self = Text(value)
  }

  public init(_ value: ReconData) {
    self = Data(value)
  }

  public init(base64 string: String) {
    self = Data(ReconData(base64: string)!)
  }

  public init(_ value: Double) {
    self = Number(value)
  }

  public var isRecord: Bool {
    if case Record = self {
      return true
    } else {
      return false
    }
  }

  public var isText: Bool {
    if case Text = self {
      return true
    } else {
      return false
    }
  }

  public var isData: Bool {
    if case Data = self {
      return true
    } else {
      return false
    }
  }

  public var isNumber: Bool {
    if case Number = self {
      return true
    } else {
      return false
    }
  }

  public var isExtant: Bool {
    return self == Extant
  }

  public var isAbsent: Bool {
    return self == Absent
  }

  public var record: ReconRecord? {
    if case Record(let value) = self {
      return value
    } else {
      return nil
    }
  }

  public var text: String? {
    if case Text(let value) = self {
      return value
    } else {
      return nil
    }
  }

  public var data: ReconData? {
    if case Data(let value) = self {
      return value
    } else {
      return nil
    }
  }

  public var number: Double? {
    if case Number(let value) = self {
      return value
    } else {
      return nil
    }
  }

  public var first: Item {
    switch self {
    case Record(let value):
      return value.first ?? Item.Absent
    default:
      return Item.Absent
    }
  }

  public var last: Item {
    switch self {
    case Record(let value):
      return value.last ?? Item.Absent
    default:
      return Item.Absent
    }
  }

  public subscript(index: Int) -> Item {
    switch self {
    case Record(let value):
      return value[index] ?? Item.Absent
    default:
      return Item.Absent
    }
  }

  public subscript(key: Value) -> Value {
    switch self {
    case Record(let value):
      return value[key] ?? Value.Absent
    default:
      return Value.Absent
    }
  }

  public subscript(key: String) -> Value {
    switch self {
    case Record(let value):
      return value[key] ?? Value.Absent
    default:
      return Value.Absent
    }
  }

  public func writeRecon(inout string: String) {
    switch self {
    case Record(let value):
      value.writeRecon(&string)
    case Text(let value):
      value.writeRecon(&string)
    case Data(let value):
      value.writeRecon(&string)
    case Number(let value):
      value.writeRecon(&string)
    default:
      break
    }
  }

  public func writeReconBlock(inout string: String) {
    switch self {
    case Record(let value):
      value.writeReconBlock(&string)
    default:
      writeRecon(&string)
    }
  }

  public var recon: String {
    switch self {
    case Record(let value):
      return value.recon
    case Text(let value):
      return value.recon
    case Data(let value):
      return value.recon
    case Number(let value):
      return value.recon
    default:
      return ""
    }
  }

  public var reconBlock: String {
    switch self {
    case Record(let value):
      return value.reconBlock
    default:
      return recon
    }
  }

  public var description: String {
    return recon
  }

  public var hashValue: Int {
    switch self {
    case Record(let value):
      return value.hashValue
    case Text(let value):
      return value.hashValue
    case Data(let value):
      return value.hashValue
    case Number(let value):
      return value.hashValue
    case Extant:
      return 0x8e02616a
    case Absent:
      return 0xd35f02e5
    }
  }

  public static var True: Value {
    return Text("true")
  }

  public static var False: Value {
    return Text("false")
  }

  public static func parseRecon(string: String) -> Value? {
    return ReconDocumentParser().parse(string).value as? Value
  }
}

public func == (lhs: Value, rhs: Value) -> Bool {
  switch (lhs, rhs) {
  case (.Record(let x), .Record(let y)):
    return x == y
  case (.Text(let x), .Text(let y)):
    return x == y
  case (.Data(let x), .Data(let y)):
    return x == y
  case (.Number(let x), .Number(let y)):
    return x == y
  case (.Extant, .Extant):
    return true
  case (.Absent, .Absent):
    return true
  default:
    return false
  }
}

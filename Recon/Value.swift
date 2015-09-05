public enum Value: Hashable {
  case Record(ReconRecord)
  case Text(String)
  case Data(ReconData)
  case Number(Double)
  case Extant
  case Absent

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

public func ==(lhs: Value, rhs: Value) -> Bool {
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

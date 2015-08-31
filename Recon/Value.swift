public typealias ReconField = Field
public typealias ReconValue = Value
public typealias ReconData = Data


public enum Value: Hashable {
  case Text(value: String)
  case Data(value: ReconData)
  case Number(value: Double)
  case Bool(value: Swift.Bool)
  case Extant
  case Absent

  public var hashValue: Int {
    switch self {
    case Text(let value):
      return value.hashValue
    case Data(let value):
      return value.hashValue
    case Number(let value):
      return value.hashValue
    case Bool(let value):
      return value.hashValue
    case Extant:
      return 0x8e02616a
    case Absent:
      return 0xd35f02e5
    }
  }
}

public func ==(lhs: Value, rhs: Value) -> Bool {
  switch (lhs, rhs) {
  case (.Text(let x), .Text(let y)):
    return x == y
  case (.Data(let x), .Data(let y)):
    return x == y
  case (.Number(let x), .Number(let y)):
    return x == y
  case (.Bool(let x), .Bool(let y)):
    return x == y
  case (.Extant, .Extant):
    return true
  case (.Absent, .Absent):
    return true
  default:
    return false
  }
}


public enum Field: Hashable {
  case Attr(key: String, value: Value)
  case Slot(key: Value, value: Value)

  public var hashValue: Int {
    switch self {
    case Attr(let key, let value):
      return MurmurHash3.hash(0x8b9cf328, key, value)
    case Slot(let key, let value):
      return MurmurHash3.hash(0x543c0c9b, key, value)
    }
  }
}

public func ==(lhs: Field, rhs: Field) -> Bool {
  switch (lhs, rhs) {
  case (.Attr(let k1, let v1), .Attr(let k2, let v2)):
    return k1 == k2 && v1 == v2
  case (.Slot(let k1, let v1), .Slot(let k2, let v2)):
    return k1 == k2 && v1 == v2
  default:
    return false
  }
}


public enum Item: Hashable {
  case Field(field: ReconField)
  case Value(value: ReconValue)

  public var hashValue: Int {
    switch self {
    case Field(let field):
      return field.hashValue
    case Value(let value):
      return value.hashValue
    }
  }
}

public func ==(lhs: Item, rhs: Item) -> Bool {
  switch (lhs, rhs) {
  case (.Field(let x), .Field(let y)):
    return x == y
  case (.Value(let x), .Value(let y)):
    return x == y
  default:
    return false
  }
}


struct ValueBuilder {
  func appendValue(value: Value) {}

  func appendAttr(key: Value) {}

  func appendAttr(key: Value, _ value: Value) {}

  func appendSlot(key: Value) {}

  func appendSlot(key: Value, _ value: Value) {}

  var state: Value {
    return Value.Absent
  }
}

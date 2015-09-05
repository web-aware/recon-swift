public enum Field: Hashable {
  case Attr(String, Value)
  case Slot(Value, Value)

  var key: Value {
    switch self {
    case Attr(let key, _):
      return Value.Text(key)
    case Slot(let key, _):
      return key
    }
  }

  var value: Value {
    switch self {
    case Attr(_, let value):
      return value
    case Slot(_, let value):
      return value
    }
  }

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

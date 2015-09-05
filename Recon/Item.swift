public typealias ReconField = Field
public typealias ReconValue = Value
public typealias ReconRecord = Record
public typealias ReconText = String
public typealias ReconData = Data
public typealias ReconNumber = Double

public enum Item: Hashable {
  case Field(ReconField)
  case Value(ReconValue)

  public var first: Item {
    switch self {
    case Value(let value):
      return value.first
    default:
      return Item.Absent
    }
  }

  public var last: Item {
    switch self {
    case Value(let value):
      return value.last
    default:
      return Item.Absent
    }
  }

  public var key: ReconValue? {
    switch self {
    case Field(let field):
      return field.key
    default:
      return nil
    }
  }

  public var value: ReconValue {
    switch self {
    case Field(let field):
      return field.value
    case Value(let value):
      return value
    }
  }

  public subscript(index: Int) -> Item {
    switch self {
    case Value(let value):
      return value[index]
    default:
      return Item.Absent
    }
  }

  public subscript(key: ReconValue) -> ReconValue {
    switch self {
    case Value(let value):
      return value[key]
    default:
      return ReconValue.Absent
    }
  }

  public subscript(key: String) -> ReconValue {
    switch self {
    case Value(let value):
      return value[key]
    default:
      return ReconValue.Absent
    }
  }

  public var hashValue: Int {
    switch self {
    case Field(let field):
      return field.hashValue
    case Value(let value):
      return value.hashValue
    }
  }


  public static func Attr(key: String, _ value: ReconValue) -> Item {
    return Item.Field(ReconField.Attr(key, value))
  }

  public static func Attr(key: String) -> Item {
    return Item.Field(ReconField.Attr(key, ReconValue.Extant))
  }

  public static func Slot(key: ReconValue, _ value: ReconValue) -> Item {
    return Item.Field(ReconField.Slot(key, value))
  }

  public static func Slot(key: ReconValue) -> Item {
    return Item.Field(ReconField.Slot(key, ReconValue.Extant))
  }

  public static func Record(value: ReconRecord) -> Item {
    return Item.Value(ReconValue.Record(value))
  }

  public static func Record(items: Item...) -> Item {
    return Item.Value(ReconValue.Record(ReconRecord(items)))
  }

  public static func Text(value: String) -> Item {
    return Item.Value(ReconValue.Text(value))
  }

  public static func Data(value: ReconData) -> Item {
    return Item.Value(ReconValue.Data(value))
  }

  public static func Number(value: Double) -> Item {
    return Item.Value(ReconValue.Number(value))
  }

  public static var True: Item {
    return Item.Value(ReconValue.True)
  }

  public static var False: Item {
    return Item.Value(ReconValue.False)
  }

  public static var Extant: Item {
    return Item.Value(ReconValue.Extant)
  }

  public static var Absent: Item {
    return Item.Value(ReconValue.Absent)
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

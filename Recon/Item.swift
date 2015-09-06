public enum Item: Hashable {
  case Field(ReconField)
  case Value(ReconValue)

  public var isField: Bool {
    if case Field = self {
      return true
    } else {
      return false
    }
  }

  public var isAttr: Bool {
    if case Field(let field) = self {
      return field.isAttr
    } else {
      return false
    }
  }

  public var isSlot: Bool {
    if case Field(let field) = self {
      return field.isSlot
    } else {
      return false
    }
  }

  public var isValue: Bool {
    if case Value = self {
      return true
    } else {
      return false
    }
  }

  public var isRecord: Bool {
    if case Value(let value) = self {
      return value.isRecord
    } else {
      return false
    }
  }

  public var isText: Bool {
    if case Value(let value) = self {
      return value.isText
    } else {
      return false
    }
  }

  public var isData: Bool {
    if case Value(let value) = self {
      return value.isData
    } else {
      return false
    }
  }

  public var isNumber: Bool {
    if case Value(let value) = self {
      return value.isNumber
    } else {
      return false
    }
  }

  public var isExtant: Bool {
    if case Value(let value) = self {
      return value.isExtant
    } else {
      return false
    }
  }

  public var isAbsent: Bool {
    if case Value(let value) = self {
      return value.isAbsent
    } else {
      return false
    }
  }

  public var key: ReconValue? {
    if case Field(let field) = self {
      return field.key
    } else {
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

  public var record: Record? {
    if case Value(let value) = self {
      return value.record
    } else {
      return nil
    }
  }

  public var text: String? {
    if case Value(let value) = self {
      return value.text
    } else {
      return nil
    }
  }

  public var data: Data? {
    if case Value(let value) = self {
      return value.data
    } else {
      return nil
    }
  }

  public var number: Double? {
    if case Value(let value) = self {
      return value.number
    } else {
      return nil
    }
  }

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

  public func writeRecon(inout string: String) {
    switch self {
    case Field(let field):
      field.writeRecon(&string)
    case Value(let value):
      value.writeRecon(&string)
    }
  }

  public func writeReconBlock(inout string: String) {
    switch self {
    case Field(let field):
      field.writeRecon(&string)
    case Value(let value):
      value.writeReconBlock(&string)
    }
  }

  public var recon: String {
    switch self {
    case Field(let field):
      return field.recon
    case Value(let value):
      return value.recon
    }
  }

  public var reconBlock: String {
    switch self {
    case Field(let field):
      return field.recon
    case Value(let value):
      return value.reconBlock
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

  public static func Data(base64 string: String) -> Item {
    return Item.Value(ReconValue.Data(ReconData.decodeBase64(string)!))
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

public func == (lhs: Item, rhs: Item) -> Bool {
  switch (lhs, rhs) {
  case (.Field(let x), .Field(let y)):
    return x == y
  case (.Value(let x), .Value(let y)):
    return x == y
  default:
    return false
  }
}

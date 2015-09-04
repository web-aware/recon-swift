public typealias ReconField = Field
public typealias ReconValue = Value
public typealias ReconRecord = Record
public typealias ReconData = Data


public enum Value: Hashable {
  case Record(value: ReconRecord)
  case Text(value: String)
  case Data(value: ReconData)
  case Number(value: Double)
  case Bool(value: Swift.Bool)
  case Extant
  case Absent

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
  case (.Record(let x), .Record(let y)):
    return x == y
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

  var key: Value {
    switch self {
    case Attr(let key, _):
      return Value.Text(value: key)
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


  public static func Attr(key: String, _ value: ReconValue) -> Item {
    return Item.Field(field: ReconField.Attr(key: key, value: value))
  }

  public static func Attr(key: String) -> Item {
    return Item.Field(field: ReconField.Attr(key: key, value: ReconValue.Extant))
  }

  public static func Slot(key: ReconValue, _ value: ReconValue) -> Item {
    return Item.Field(field: ReconField.Slot(key: key, value: value))
  }

  public static func Slot(key: ReconValue) -> Item {
    return Item.Field(field: ReconField.Slot(key: key, value: ReconValue.Extant))
  }

  public static func Record(value: ReconRecord) -> Item {
    return Item.Value(value: ReconValue.Record(value: value))
  }

  public static func Text(value: String) -> Item {
    return Item.Value(value: ReconValue.Text(value: value))
  }

  public static func Data(value: ReconData) -> Item {
    return Item.Value(value: ReconValue.Data(value: value))
  }

  public static func Number(value: Double) -> Item {
    return Item.Value(value: ReconValue.Number(value: value))
  }

  public static func Bool(value: Swift.Bool) -> Item {
    return Item.Value(value: ReconValue.Bool(value: value))
  }

  public static var Extant: Item {
    return Item.Value(value: ReconValue.Extant)
  }

  public static var Absent: Item {
    return Item.Value(value: ReconValue.Absent)
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



protocol ReconBuilder {
  mutating func append(item: Item)

  mutating func appendField(field: Field)

  mutating func appendValue(value: Value)

  mutating func appendAttr(key: String)

  mutating func appendAttr(key: String, _ value: Value)

  mutating func appendSlot(key: Value)

  mutating func appendSlot(key: Value, _ value: Value)

  mutating func appendRecord(value: Record)

  mutating func appendText(value: String)

  mutating func appendData(value: Data)

  mutating func appendNumber(value: Double)

  mutating func appendBool(value: Bool)

  mutating func appendAny(value: Any)

  var state: Value { get }
}

extension ReconBuilder {
  mutating func appendField(field: Field) {
    append(Item.Field(field: field))
  }

  mutating func appendValue(value: Value) {
    append(Item.Value(value: value))
  }

  mutating func appendAttr(key: String) {
    append(Item.Field(field: Field.Attr(key: key, value: Value.Extant)))
  }

  mutating func appendAttr(key: String, _ value: Value) {
    append(Item.Field(field: Field.Attr(key: key, value: value)))
  }

  mutating func appendSlot(key: Value) {
    append(Item.Field(field: Field.Slot(key: key, value: Value.Extant)))
  }

  mutating func appendSlot(key: Value, _ value: Value) {
    append(Item.Field(field: Field.Slot(key: key, value: value)))
  }

  mutating func appendRecord(value: Record) {
    appendValue(Value.Record(value: value))
  }

  mutating func appendText(value: String) {
    appendValue(Value.Text(value: value))
  }

  mutating func appendData(value: Data) {
    appendValue(Value.Data(value: value))
  }

  mutating func appendNumber(value: Double) {
    appendValue(Value.Number(value: value))
  }

  mutating func appendBool(value: Bool) {
    appendValue(Value.Bool(value: value))
  }

  mutating func appendAny(value: Any) {
    switch value {
    case let value as Record:
      appendRecord(value)
    case let value as String:
      appendText(value)
    case let value as Data:
      appendData(value)
    case let value as Double:
      appendNumber(value)
    case let value as Int:
      appendNumber(Double(value))
    case let value as Bool:
      appendBool(value)
    default:
      assert(false)
    }
  }
}

struct RecordBuilder: ReconBuilder {
  var record: Record

  init(_ record: Record) {
    self.record = record
  }

  init() {
    self.init(Record())
  }

  mutating func append(item: Item) {
    record.append(item)
  }

  var state: Value {
    return Value.Record(value: record)
  }
}

struct ValueBuilder: ReconBuilder {
  var record: Record?
  var value: Value?

  init() {
    self.record = nil
    self.value = nil
  }

  mutating func append(item: Item) {
    if self.record != nil {
      self.record!.append(item)
    } else if case .Value(let value) = item where self.value == nil {
      self.value = value
    } else {
      var record = Record()
      if let value = self.value {
        record.append(Item.Value(value: value))
        self.value = nil
      }
      record.append(item)
      self.record = record
    }
  }

  var state: Value {
    if let value = self.value {
      return value
    } else if let record = self.record {
      return Value.Record(value: record)
    } else {
      return Value.Absent
    }
  }
}

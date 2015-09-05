public struct Record: CollectionType, ArrayLiteralConvertible, Hashable {
  public typealias Element = Item
  public typealias Index = Int

  private static let indexThreshold: Int = 8

  var items: [Item]
  var fields: [Value: Value]?

  init(items: [Item], fields: [Value: Value]?) {
    self.items = items
    self.fields = fields
  }

  public init(_ items: [Item]) {
    self.init(items: items, fields: nil)
  }

  public init(arrayLiteral items: Item...) {
    self.init(items: items, fields: nil)
    reindex()
  }

  public init(_ items: Item...) {
    self.init(items: items, fields: nil)
    reindex()
  }

  public init() {
    self.init(items: [], fields: nil)
  }

  public var isEmpty: Bool {
    return items.isEmpty
  }

  public var startIndex: Int {
    return items.startIndex
  }

  public var endIndex: Int {
    return items.endIndex
  }

  public var count: Int {
    return items.count
  }

  public var first: Item? {
    return items.first
  }

  public var last: Item? {
    return items.last
  }

  public func contains(key: Value) -> Bool {
    if let fields = self.fields {
      return fields.indexForKey(key) != nil
    } else {
      return items.contains { item in
        if case .Field(let field) = item {
          return key == field.key
        } else {
          return false
        }
      }
    }
  }

  public subscript(index: Int) -> Item {
    return items[index]
  }

  public subscript(key: Value) -> Value? {
    if let fields = self.fields {
      return fields[key]
    } else {
      for item in items {
        if case .Field(let field) = item where key == field.key {
          return field.value
        }
      }
      return nil
    }
  }

  public subscript(key: String) -> Value? {
    return self[Value.Text(key)]
  }

  public mutating func append(item: Item) {
    items.append(item)
    if case .Field(let field) = item {
      if var fields = self.fields {
        fields.updateValue(field.value, forKey: field.key)
        self.fields = fields
      } else {
        reindex()
      }
    }
  }

  public mutating func appendContentsOf<C: CollectionType where C.Generator.Element == Element>(newItems: C) {
    items.appendContentsOf(newItems)
    reindex()
  }

  public mutating func appendContentsOf<S: SequenceType where S.Generator.Element == Element>(newItems: S) {
    items.appendContentsOf(newItems)
    reindex()
  }

  mutating func reindex() {
    if items.count > Record.indexThreshold || self.fields != nil {
      var fields = Dictionary<Value, Value>()
      for item in items {
        if case .Field(let field) = item {
          fields.updateValue(field.value, forKey: field.key)
        }
      }
      self.fields = fields
    }
  }

  public var hashValue: Int {
    var h = 0x2494fd1f
    for item in items {
      h = MurmurHash3.mix(h, item.hashValue)
    }
    h = MurmurHash3.mash(h)
    return h
  }
}

public func ==(lhs: Record, rhs: Record) -> Bool {
  return lhs.items == rhs.items
}

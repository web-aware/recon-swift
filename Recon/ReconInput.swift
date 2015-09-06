public protocol ReconInput {
  var isEmpty: Bool { get }

  var isDone: Bool { get }

  var head: UnicodeScalar? { get }

  var tail: ReconInput { get }
}

public struct ReconInputEmpty: ReconInput {
  public var isEmpty: Bool {
    return true
  }

  public var isDone: Bool {
    return false
  }

  public var head: UnicodeScalar? {
    return nil
  }

  public var tail: ReconInput {
    fatalError("tail of empty input")
  }
}

public struct ReconInputDone: ReconInput {
  public var isEmpty: Bool {
    return true
  }

  public var isDone: Bool {
    return true
  }

  public var head: UnicodeScalar? {
    return nil
  }

  public var tail: ReconInput {
    fatalError("tail of done input")
  }
}

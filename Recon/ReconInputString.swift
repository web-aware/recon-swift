public struct ReconInputString: ReconInput {
  var scalars: String.UnicodeScalarView
  var index: String.UnicodeScalarView.Index

  public init(scalars: String.UnicodeScalarView, index: String.UnicodeScalarView.Index) {
    self.scalars = scalars
    self.index = index
  }

  public init(_ string: String) {
    let scalars = string.unicodeScalars
    let index = scalars.startIndex
    self.init(scalars: scalars, index: index)
  }

  public var isEmpty: Bool {
    return self.index >= self.scalars.endIndex
  }

  public var isDone: Bool {
    return false
  }

  public var head: UnicodeScalar? {
    if (self.index < self.scalars.endIndex) {
      return self.scalars[self.index]
    }
    else {
      return nil
    }
  }

  public var tail: ReconInput {
    if (self.index < self.scalars.endIndex) {
      return ReconInputString(scalars: self.scalars, index: self.index.successor())
    }
    else {
      return ReconInputEmpty()
    }
  }
}

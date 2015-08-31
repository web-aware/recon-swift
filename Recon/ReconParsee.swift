public enum ReconParsee {
  case Cont(ReconParser, ReconInput)

  case Done(Any, ReconInput)

  case Fail(String, ReconInput)

  var isCont: Bool {
    if case Cont = self {
      return true
    } else {
      return false
    }
  }

  var isDone: Bool {
    if case Done = self {
      return true
    } else {
      return false
    }
  }

  var isFail: Bool {
    if case Fail = self {
      return true
    } else {
      return false
    }
  }

  var value: Any? {
    if case Done(let value, _) = self {
      return value
    } else {
      return nil
    }
  }

  var remaining: ReconInput {
    switch self {
    case Cont(_, let remaining):
      return remaining
    case Done(_, let remaining):
      return remaining
    case Fail(_, let remaining):
      return remaining
    }
  }
}

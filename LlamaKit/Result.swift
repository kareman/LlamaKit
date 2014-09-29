/// Result
///
/// Container for a successful value (T) or a failure with an NSError
///

import Foundation

/// A success `Result` returning `value`
/// This form is preferred to `Result.Success(Box(value))` because it
// does not require dealing with `Box()`
public func success<T>(value: T) -> Result<T> {
  return .Success(Box(value))
}

/// A failure `Result` returning `error`
/// The default error is an empty one so that `failure()` is legal
/// To assign this to a variable, you must explicitly give a type.
/// Otherwise the compiler has no idea what `T` is. This form is preferred
/// to Result.Failure(error) because it provides a useful default.
/// For example:
///    let fail: Result<Int> = failure()
///
public func failure<T>(_ error: ErrorType = NSError(domain: "", code: 0, userInfo: nil)) -> Result<T> {
  return .Failure(error)
}

/// Container for a successful value (T) or a failure with an NSError
public enum Result<T> {
  case Success(Box<T>)
  case Failure(ErrorType)

  /// The successful value as an Optional
  public func value() -> T? {
    switch self {
    case .Success(let box): return box.unbox
    case .Failure: return nil
    }
  }

  /// The failing error as an Optional
  public func error() -> ErrorType? {
    switch self {
    case .Success: return nil
    case .Failure(let err): return err
    }
  }

  public func isSuccess() -> Bool {
    switch self {
    case .Success: return true
    case .Failure: return false
    }
  }

  /// Return a new result after applying a transformation to a successful value.
  /// Mapping a failure returns a new failure without evaluating the transform
  public func map<U>(transform: T -> U) -> Result<U> {
    switch self {
    case Success(let box):
      return .Success(Box(transform(box.unbox)))
    case Failure(let err):
      return .Failure(err)
    }
  }

  /// Return a new result after applying a transformation (that itself
  /// returns a result) to a successful value.
  /// Flat mapping a failure returns a new failure without evaluating the transform
  public func flatMap<U>(transform:T -> Result<U>) -> Result<U> {
    switch self {
    case Success(let value): return transform(value.unbox)
    case Failure(let error): return .Failure(error)
    }
  }
}

extension Result: Printable {
  public var description: String {
    switch self {
    case .Success(let box):
      return "Success: \(box.unbox)"
    case .Failure(let error):
      return "Failure: \(error)"
    }
  }
}

/// Failure coalescing
///    .Success(Box(42)) ?? 0 ==> 42
///    .Failure(NSError()) ?? 0 ==> 0
public func ??<T>(result: Result<T>, defaultValue: @autoclosure () -> T) -> T {
  switch result {
  case .Success(let value):
    return value.unbox
  case .Failure(let error):
    return defaultValue()
  }
}

/// Result
///
/// Container for a successful value (T) or a failure (E)
///


/// Container for a successful value (T) or a failure (E)
public enum Result<T,E> {
  case Success(Box<T>)
  case Failure(Box<E>)

  /// A successful `Result` returning `value`.
  /// This form is preferred to `Result.Success(Box(value))` because it
  /// does not require dealing with `Box()`.
  public static func success(value: T) -> Result<T,E> {
    return .Success(Box(value))
  }

  public static func failure(error: E) -> Result<T,E> {
    return .Failure(Box(error))
  }

  /// The successful value as an Optional
  public var value: T? {
    switch self {
    case .Success(let box): return box.unbox
    case .Failure: return nil
    }
  }

  /// The failing error as an Optional
  public var error: E? {
    switch self {
    case .Success: return nil
    case .Failure(let err): return err.unbox
    }
  }

  public var isSuccess: Bool {
    switch self {
    case .Success: return true
    case .Failure: return false
    }
  }

  /// Return a new result after applying a transformation to a successful value.
  /// Mapping a failure returns a new failure without evaluating the transform.
  public func map<U>(transform: T -> U) -> Result<U,E> {
    switch self {
    case Success(let box):
      return .Success(Box(transform(box.unbox)))
    case Failure(let err):
      return .Failure(err)
    }
  }

  /// Return a new result after applying a transformation (that itself
  /// returns a result) to a successful value.
  /// Calling with a failure returns a new failure without evaluating the transform.
  public func flatMap<U>(transform:T -> Result<U,E>) -> Result<U,E> {
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
      return "Failure: \(error.unbox)"
    }
  }
}

/// Failure coalescing
///    .Success(Box(42)) ?? 0 ==> 42
///    .Failure(NSError()) ?? 0 ==> 0
public func ??<T,E>(result: Result<T,E>, defaultValue: @autoclosure () -> T) -> T {
  switch result {
  case .Success(let value):
    return value.unbox
  case .Failure(let error):
    return defaultValue()
  }
}

/// Due to current swift limitations, we have to include this Box in Result.
/// Swift cannot handle an enum with associated data where one is of unknown size.
final public class Box<T> {
  public let unbox: T
  public init(_ value: T) { self.unbox = value }
}

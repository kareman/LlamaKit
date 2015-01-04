//
// Result+Foundation.swift
// LlamaKit
//

/// Additions to Result for using it with Cocoa and Foundation.
/// In other words; the .Failure value is an NSError.

import Foundation

/// Dictionary keys for default errors
public let ErrorFileKey = "LMErrorFile"
public let ErrorLineKey = "LMErrorLine"

private func defaultError(userInfo: [NSObject: AnyObject]) -> NSError {
  return NSError(domain: "", code: 0, userInfo: userInfo)
}

private func defaultError(message: String, file: String = __FILE__, line: Int = __LINE__) -> NSError {
  return defaultError([NSLocalizedDescriptionKey: message, ErrorFileKey: file, ErrorLineKey: line])
}

private func defaultError(file: String = __FILE__, line: Int = __LINE__) -> NSError {
  return defaultError([ErrorFileKey: file, ErrorLineKey: line])
}

public func failure<T>(message: String, file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: message, ErrorFileKey: file, ErrorLineKey: line]
  return Result.failure(defaultError(userInfo))
}

/// A failure `Result` returning `error`
/// The default error is an empty one so that `failure()` is legal
/// To assign this to a variable, you must explicitly give a type.
/// Otherwise the compiler has no idea what `T` is. This form is preferred
/// to Result.Failure(error) because it provides a useful default.
/// For example:
///    let fail: Result<Int> = failure()
///
public func failure<T>(file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  let userInfo: [NSObject : AnyObject] = [ErrorFileKey: file, ErrorLineKey: line]
  return Result.failure(defaultError(userInfo))
}

/// Construct a `Result` using a block which receives an error parameter.
/// Expected to return non-nil for success.

public func try<T>(f: NSErrorPointer -> T?, file: String = __FILE__, line: Int = __LINE__) -> Result<T,NSError> {
  var error: NSError?
  return f(&error).map(Result.success) ?? Result.failure(error ?? defaultError(file: file, line: line))
}

public func try(f: NSErrorPointer -> Bool, file: String = __FILE__, line: Int = __LINE__) -> Result<(),NSError> {
  var error: NSError?
  return f(&error) ? Result.success(()) : Result.failure(error ?? defaultError(file: file, line: line))
}

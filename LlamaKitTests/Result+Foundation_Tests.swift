//
//  Result+Foundation_Tests.swift
//  LlamaKit
//
//  Created by Kåre Morstøl on 15.12.14.
//  Copyright (c) 2014 Rob Napier. All rights reserved.
//

import LlamaKit
import XCTest

class Result_Foundation_Tests: XCTestCase {

  func testFailureIsNotSuccess() {
    let f: Result<Bool, NSError> = failure()
    XCTAssertFalse(f.isSuccess)
  }


  private func makeTryFunction<T>(x: T, _ succeed: Bool = true)(error: NSErrorPointer) -> T {
    if !succeed {
      error.memory = NSError(domain: "domain", code: 1, userInfo: [:])
    }
    return x
  }

  func testTryTSuccess() {
    XCTAssertEqual(try(makeTryFunction(42 as Int?)) ?? 43, 42)
  }

  func testTryTFailure() {
    let result = try(makeTryFunction(nil as Int?, false))
    XCTAssertEqual(result ?? 43, 43)
    XCTAssert(result.description.hasPrefix("Failure: Error Domain=domain Code=1 "))
  }

  func testTryBoolSuccess() {
    XCTAssert(try(makeTryFunction(true)).isSuccess)
  }

  func testTryBoolFailure() {
    let result = try(makeTryFunction(false, false))
    XCTAssertFalse(result.isSuccess)
    XCTAssert(result.description.hasPrefix("Failure: Error Domain=domain Code=1 "))
  }

  
  func testDescriptionFailure() {
    let x: Result<String, NSError> = failure()
    XCTAssert(x.description.hasPrefix("Failure: Error Domain= Code=0 "))
  }
}

//
// LlamaKitTests.swift
// LlamaKitTests
//
// Created by Rob Napier on 9/9/14.
// Copyright (c) 2014 Rob Napier. All rights reserved.
//

import LlamaKit
import XCTest

struct TestError: Printable, Equatable {
  let description: String

  init (_ description: String) {
    self.description = description
  }
}

func == (left: TestError, right: TestError) -> Bool {
   return left.description == right.description
}


class ResultTests: XCTestCase {
  let err = TestError("err")
  let err2 = TestError("err2")

  func testSuccessIsSuccess() {
    let s = Result<Int,TestError>.success(42)
    XCTAssertTrue(s.isSuccess)
  }

  func testSuccessReturnsValue() {
    let s: Result<Int,TestError> = Result.success(42)
    XCTAssertEqual(s.value!, 42)
  }

  func testSuccessReturnsNoError() {
    let s: Result<Int,TestError> = Result.success(42)
    XCTAssert(s.error == nil)
  }

  func testEmptyFailureIsNotSuccess() {
    let f: Result<Bool, ()> = Result.failure()
    XCTAssertFalse(f.isSuccess)
  }

  func testFailureIsNotSuccess() {
    let f: Result<Bool, TestError> = Result.failure(self.err)
    XCTAssertFalse(f.isSuccess)
  }

  func testFailureReturnsError() {
    let f: Result<Int, TestError> = Result.failure(self.err)
    XCTAssertEqual(f.error!, self.err)
  }

  func testFailureReturnsNoValue() {
    let f: Result<Int, TestError> = Result.failure(self.err)
    XCTAssertNil(f.value)
  }


  func testMapSuccessUnaryOperator() {
    let x: Result<Int, TestError> = Result.success(42)
    let y = x.map(-)
    XCTAssertEqual(y.value!, -42)
  }

  func testMapFailureUnaryOperator() {
    let x: Result<Int, TestError> = Result.failure(self.err)
    let y = x.map(-)
    XCTAssertNil(y.value)
    XCTAssertEqual(y.error!, self.err)
  }

  func testMapSuccessNewType() {
    let x: Result<String, TestError> = Result.success("abcd")
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.value!, 4)
  }

  func testMapFailureNewType() {
    let x: Result<String, TestError> = Result.failure(self.err)
    let y = x.map { countElements($0) }
    XCTAssertEqual(y.error!, self.err)
  }


  func doubleSuccess(x: Int) -> Result<Int, TestError> {
    return Result.success(x * 2)
  }

  func doubleFailure(x: Int) -> Result<Int, TestError> {
    return Result.failure(self.err)
  }

  func testFlatMapSuccessSuccess() {
    let x: Result<Int, TestError> = Result.success(42)
    let y = x.flatMap(doubleSuccess)
    XCTAssertEqual(y.value!, 84)
  }

  func testFlatMapSuccessFailure() {
    let x: Result<Int, TestError> = Result.success(42)
    let y = x.flatMap(doubleFailure)
    XCTAssertEqual(y.error!, self.err)
  }

  func testFlatMapFailureSuccess() {
    let x: Result<Int, TestError> = Result.failure(self.err2)
    let y = x.flatMap(doubleSuccess)
    XCTAssertEqual(y.error!, self.err2)
  }

  func testFlatMapFailureFailure() {
    let x: Result<Int, TestError> = Result.failure(self.err2)
    let y = x.flatMap(doubleFailure)
    XCTAssertEqual(y.error!, self.err2)
  }


  func testDescriptionSuccess() {
    let x: Result<Int, TestError> = Result.success(42)
    XCTAssertEqual(x.description, "Success: 42")
  }

  func testDescriptionFailure() {
    let x: Result<String, TestError> = Result.failure(self.err)
    XCTAssert(x.description.hasPrefix("Failure: err"))
  }

  
  func testCoalesceSuccess() {
    let r: Result<Int, TestError> = Result.success(42)
    let x = r ?? 43
    XCTAssertEqual(x, 42)
  }

  func testCoalesceFailure() {
    let x = Result.failure() ?? 43
    XCTAssertEqual(x, 43)
  }
}

import Dependencies
import Foundation
import Sharing
import XCTest

/// Category A behavioral parity tests for swift-sharing on Android.
///
/// These tests verify that the Android code path (no KVO, no-op subscription)
/// behaves equivalently to the Apple path for the public API contract.
/// They run on both platforms without any `#if os(Android)` guards.
final class AndroidParityTests: XCTestCase {

  // MARK: - AppStorage read/write

  func testAppStorageBoolReadWrite() {
    @Shared(.appStorage("parity_bool")) var flag = false
    XCTAssertFalse(flag)

    $flag.withLock { $0 = true }
    XCTAssertTrue(flag)

    $flag.withLock { $0 = false }
    XCTAssertFalse(flag)
  }

  func testAppStorageIntReadWrite() {
    @Shared(.appStorage("parity_int")) var count = 0
    XCTAssertEqual(count, 0)

    $count.withLock { $0 = 42 }
    XCTAssertEqual(count, 42)

    $count.withLock { $0 += 1 }
    XCTAssertEqual(count, 43)
  }

  func testAppStorageDoubleReadWrite() {
    @Shared(.appStorage("parity_double")) var value = 0.0
    XCTAssertEqual(value, 0.0)

    $value.withLock { $0 = 3.14 }
    XCTAssertEqual(value, 3.14, accuracy: 0.001)
  }

  func testAppStorageStringReadWrite() {
    @Shared(.appStorage("parity_string")) var name = ""
    XCTAssertEqual(name, "")

    $name.withLock { $0 = "Blob" }
    XCTAssertEqual(name, "Blob")

    $name.withLock { $0 = "Blob, Jr." }
    XCTAssertEqual(name, "Blob, Jr.")
  }

  // MARK: - Default values

  func testAppStorageDefaultValue() {
    // A key that has never been set should return the default
    @Shared(.appStorage("parity_unset_key_\(UUID())")) var value = 99
    XCTAssertEqual(value, 99)
  }

  func testAppStorageDefaultBoolIsFalse() {
    @Shared(.appStorage("parity_unset_bool_\(UUID())")) var flag = false
    XCTAssertFalse(flag)
  }

  // MARK: - In-memory isolation

  func testInMemoryIsolation() {
    let key1 = "parity_iso_\(UUID())"
    let key2 = "parity_iso_\(UUID())"

    @Shared(.inMemory(key1)) var a = 0
    @Shared(.inMemory(key2)) var b = 0

    $a.withLock { $0 = 10 }
    XCTAssertEqual(a, 10)
    XCTAssertEqual(b, 0, "Writes to one key must not affect another key")
  }

  func testInMemorySharedAcrossReferences() {
    let key = "parity_shared_\(UUID())"

    @Shared(.inMemory(key)) var first = 0
    $first.withLock { $0 = 42 }

    @Shared(.inMemory(key)) var second = 0
    XCTAssertEqual(second, 42, "Same inMemory key should share state across references")
  }

  // MARK: - No-op subscription (write + readback without crash)

  func testWriteReadbackNoCrash() {
    @Shared(.inMemory("parity_noop_\(UUID())")) var value = "initial"
    XCTAssertEqual(value, "initial")

    // Rapid writes should not crash even without KVO subscription on Android
    for i in 0..<100 {
      $value.withLock { $0 = "iteration_\(i)" }
    }
    XCTAssertEqual(value, "iteration_99")
  }

  // MARK: - SharedReader

  func testSharedReaderFromShared() {
    let key = "parity_reader_\(UUID())"
    @Shared(.inMemory(key)) var writable = 0
    let reader = SharedReader($writable)

    $writable.withLock { $0 = 55 }
    XCTAssertEqual(reader.wrappedValue, 55, "SharedReader should reflect Shared writes")
  }

  // MARK: - DynamicMember lookup

  func testDynamicMemberLookup() {
    struct Info: Equatable {
      var name: String = ""
      var age: Int = 0
    }

    @Shared(.inMemory("parity_member_\(UUID())")) var info = Info()
    $info.name.withLock { $0 = "Blob" }
    $info.age.withLock { $0 = 42 }

    XCTAssertEqual(info.name, "Blob")
    XCTAssertEqual(info.age, 42)
  }
}

// MARK: - Category B: SwiftUI Integration (un-guarded code)

#if canImport(SwiftUI)
  import SwiftUI

  /// Tests verifying that un-guarded SwiftUI integrations work correctly.
  /// These exercise the same code paths used on Android via SkipSwiftUI.
  @MainActor
  final class SharedSwiftUIParityTests: XCTestCase {
    func testSharedConformsToDynamicProperty() {
      // Verify @Shared has DynamicProperty conformance (un-guarded in Shared.swift)
      // by confirming the update() method exists on the type.
      @Shared(.inMemory("dp_test_\(UUID())")) var value = 0
      // DynamicProperty.update() is callable — this would fail to compile
      // if the DynamicProperty conformance were guarded.
      _value.update()
      XCTAssertEqual(value, 0)
    }

    func testSharedReaderConformsToDynamicProperty() {
      // Verify @SharedReader also has DynamicProperty conformance.
      let key = "dp_reader_test_\(UUID())"
      @Shared(.inMemory(key)) var source = 42
      let reader = SharedReader($source)
      // SharedReader.update() must be callable
      reader.update()
      XCTAssertEqual(reader.wrappedValue, 42)
    }

    func testSharedBindingConversion() {
      // Verify Binding(Shared(...)) works — the SharedBinding.swift code.
      @Shared(.inMemory("binding_test_\(UUID())")) var count = 0

      let binding = Binding($count)

      // Read through binding
      XCTAssertEqual(binding.wrappedValue, 0)

      // Write through binding updates the shared value
      binding.wrappedValue = 99
      XCTAssertEqual(count, 99)

      // Write through shared updates binding
      $count.withLock { $0 = 42 }
      XCTAssertEqual(binding.wrappedValue, 42)
    }

    func testSharedBindingWithDynamicMember() {
      // Verify Binding works with @Shared's dynamic member lookup.
      struct Profile: Equatable {
        var name: String = ""
        var score: Int = 0
      }

      @Shared(.inMemory("binding_member_\(UUID())")) var profile = Profile()

      let nameBinding = Binding($profile.name)
      nameBinding.wrappedValue = "Blob"
      XCTAssertEqual(profile.name, "Blob")
    }
  }
#endif

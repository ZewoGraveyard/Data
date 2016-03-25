// Data.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import C7
@_exported import OperatingSystem

public protocol ByteType {}
extension UInt8: ByteType {}
extension Int8: ByteType {}

extension Data {
    public init(string: String) {
        self.init([Byte](string.utf8))
    }
}

public struct DataError: ErrorProtocol, CustomStringConvertible {
    public let description: String
}

extension Data {
    public init() {
        self.bytes = []
    }

    public init<T: ByteType>(pointer: UnsafePointer<T>, length: Int) {
        var bytes: [UInt8] = [UInt8](repeating: 0, count: length)
        memcpy(&bytes, pointer, length)
        self.bytes = bytes
    }

    public init(_ convertible: DataConvertible) {
        self.bytes = convertible.data.bytes
    }

    public init<S: Sequence where S.Iterator.Element == Byte>(_ bytes: S) {
        self.bytes = [Byte](bytes)
    }

    public init<C: Collection where C.Iterator.Element == Byte>(_ bytes: C) {
        self.bytes = [Byte](bytes)
    }
}

extension Data: MutableCollection {
    public func makeIterator() -> IndexingIterator<[Byte]> {
        return bytes.makeIterator()
    }

    public var startIndex: Int {
        return bytes.startIndex
    }

    public var endIndex: Int {
        return bytes.endIndex
    }

    public var count: Int {
        return bytes.count
    }

    public subscript(index: Int) -> Byte {
        get {
            return bytes[index]
        }

        set(byte) {
            bytes[index] = byte
        }
    }

    public subscript (bounds: Range<Int>) -> Data {
        get {
            return Data(bytes[bounds])
        }

        set(data) {
            bytes[bounds] = ArraySlice<Byte>(data.bytes)
        }
    }
}

extension Data: Equatable {}

public func ==(lhs: Data, rhs: Data) -> Bool {
    return lhs.bytes == rhs.bytes
}

extension Data: ArrayLiteralConvertible {
    public init(arrayLiteral bytes: Byte...) {
        self.init(bytes)
    }
}

extension Data: StringLiteralConvertible {
    public init(stringLiteral string: String) {
        self.init(string: string)
    }

    public init(extendedGraphemeClusterLiteral string: String){
        self.init(string: string)
    }

    public init(unicodeScalarLiteral string: String){
        self.init(string: string)
    }
}

extension Data {
	public func hexString(delimiter delimiter: Int = 0) -> String {
		var string = ""
		for (index, value) in enumerated() {
			if delimiter != 0 && index > 0 && index % delimiter == 0 {
				string += " "
			}
			string += (value < 16 ? "0" : "") + String(value, radix: 16)
		}
		return string
	}

    public var hexDescription: String {
		return hexString(delimiter: 2)
    }
}

extension Data: CustomStringConvertible {
    public var description: String {
        if let string = try? String(data: self) {
            return string
        }

        return debugDescription
    }
}

extension Data: CustomDebugStringConvertible {
    public var debugDescription: String {
        return hexDescription
    }
}

extension Data: NilLiteralConvertible {
    public init(nilLiteral: Void) {
        self.init([])
    }
}

extension Data {
    internal func convert<T>() -> T {
        return bytes.withUnsafeBufferPointer {
            return UnsafePointer<T>($0.baseAddress).pointee
        }
    }

    internal init<T>(value: T) {
        var value = value
        self.bytes = withUnsafePointer(&value) {
            Array(UnsafeBufferPointer(start: UnsafePointer<Byte>($0), count: sizeof(T)))
        }
    }

    public func withUnsafeBufferPointer<R>(@noescape body: (UnsafeBufferPointer<Byte>) throws -> R) rethrows -> R {
        return try bytes.withUnsafeBufferPointer(body)
    }

    public mutating func withUnsafeMutableBufferPointer<R>(@noescape body: (inout UnsafeMutableBufferPointer<Byte>) throws -> R) rethrows -> R {
        return try bytes.withUnsafeMutableBufferPointer(body)
    }

    public static func bufferWithSize(size: Int) -> Data {
        return Data([UInt8](repeating: 0, count: size))
    }

    public mutating func replaceBytesInRange<C: Collection where C.Iterator.Element == Byte>(subRange: Range<Int>, with newBytes: C) {
        bytes.replaceSubrange(subRange, with: newBytes)
    }

    public mutating func reserveCapacity(minimumCapacity: Int) {
        bytes.reserveCapacity(minimumCapacity)
    }

    public mutating func appendByte(newByte: Byte) {
        bytes.append(newByte)
    }

    public mutating func appendBytes<S: Sequence where S.Iterator.Element == Byte>(newBytes: S) {
        bytes.append(contentsOf: newBytes)
    }

    public mutating func insertByte(newByte: Byte, atIndex i: Int) {
        bytes.insert(newByte, at: i)
    }

    public mutating func insertBytes<S : Collection where S.Iterator.Element == Byte>(newBytes: S, at i: Int) {
        bytes.insert(contentsOf: newBytes, at: i)
    }

    public mutating func removeByteAtIndex(index: Int) -> Byte {
        return bytes.remove(at: index)
    }

    public mutating func removeFirstByte() -> Byte {
        return bytes.removeFirst()
    }

    public mutating func removeFirstBytes(n: Int) {
        bytes.removeFirst(n)
    }

    public mutating func removeBytesInRange(subRange: Range<Int>) {
        bytes.removeSubrange(subRange)
    }

    public mutating func removeAllBytes(keepCapacity keepCapacity: Bool = true) {
        bytes.removeAll(keepingCapacity: keepCapacity)
    }

    public init(count: Int, repeatedValue: Byte) {
        self.init([Byte](repeating: repeatedValue ,count: count))
    }

    public var capacity: Int {
        return bytes.capacity
    }

    public var isEmpty: Bool {
        return bytes.isEmpty
    }

    public mutating func popLastByte() -> Byte? {
        return bytes.popLast()
    }
}

public func +=<S : Sequence where S.Iterator.Element == Byte>(lhs: inout Data, rhs: S) {
    return lhs.bytes += rhs
}

public func +=(lhs: inout Data, rhs: Data) {
    return lhs.bytes += rhs.bytes
}

public func +=(lhs: inout Data, rhs: DataConvertible) {
    return lhs += rhs.data
}

@warn_unused_result
public func +(lhs: Data, rhs: Data) -> Data {
    return Data(lhs.bytes + rhs.bytes)
}

@warn_unused_result
public func +(lhs: Data, rhs: DataConvertible) -> Data {
    return lhs + rhs.data
}

@warn_unused_result
public func +(lhs: DataConvertible, rhs: Data) -> Data {
    return lhs.data + rhs
}

extension String: DataConvertible {
    public init(data: Data) throws {
        struct Error: ErrorProtocol {}
        var string = ""
        var decoder = UTF8()
        var generator = data.makeIterator()
        var finished = false

        while !finished {
            let decodingResult = decoder.decode(&generator)
            switch decodingResult {
            case .scalarValue(let char): string.append(char)
            case .emptyInput: finished = true
            case .error:
                throw Error()
            }
        }

        self.init(string)
    }

    public var data: Data {
        return Data(string: self)
    }
}

// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2016 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

import CoreFoundation

public struct NSAttributedStringKey : RawRepresentable, Equatable, Hashable {
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public var hashValue: Int {
        return rawValue.hashValue
    }
}

open class NSAttributedString: NSObject, NSCopying, NSMutableCopying, NSSecureCoding {
    
    private let _cfinfo = _CFInfo(typeID: CFAttributedStringGetTypeID())
    fileprivate var _string: NSString
    fileprivate var _attributeArray: CFRunArrayRef
    
    public required init?(coder aDecoder: NSCoder) {
        NSUnimplemented()
    }
    
    open func encode(with aCoder: NSCoder) {
        NSUnimplemented()
    }
    
    static public var supportsSecureCoding: Bool {
        return true
    }
    
    open override func copy() -> Any {
        return copy(with: nil)
    }
    
    open func copy(with zone: NSZone? = nil) -> Any {
        NSUnimplemented()
    }

    open override func mutableCopy() -> Any {
        return mutableCopy(with: nil)
    }
    
    open func mutableCopy(with zone: NSZone? = nil) -> Any {
        NSUnimplemented()
    }

    /// The character contents of the receiver as an NSString object.
    open var string: String {
        return _string._swiftObject
    }

    /// Returns the attributes for the character at a given index.
    open func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedStringKey : Any] {
        let rangeInfo = RangeInfo(
            rangePointer: range,
            shouldFetchLongestEffectiveRange: false,
            longestEffectiveRangeSearchRange: nil)
        return _attributes(at: location, rangeInfo: rangeInfo)
    }

    /// The length of the receiver’s string object.
    open var length: Int {
        return CFAttributedStringGetLength(_cfObject)
    }

    /// Returns the value for an attribute with a given name of the character at a given index, and by reference the range over which the attribute applies.
    open func attribute(_ attrName: NSAttributedStringKey, at location: Int, effectiveRange range: NSRangePointer?) -> Any? {
        let rangeInfo = RangeInfo(
            rangePointer: range,
            shouldFetchLongestEffectiveRange: false,
            longestEffectiveRangeSearchRange: nil)
        return _attribute(attrName, atIndex: location, rangeInfo: rangeInfo)
    }

    /// Returns an NSAttributedString object consisting of the characters and attributes within a given range in the receiver.
    open func attributedSubstring(from range: NSRange) -> NSAttributedString { NSUnimplemented() }

    /// Returns the attributes for the character at a given index, and by reference the range over which the attributes apply.
    open func attributes(at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange) -> [NSAttributedStringKey : Any] {
        let rangeInfo = RangeInfo(
            rangePointer: range,
            shouldFetchLongestEffectiveRange: true,
            longestEffectiveRangeSearchRange: rangeLimit)
        return _attributes(at: location, rangeInfo: rangeInfo)
    }

    /// Returns the value for the attribute with a given name of the character at a given index, and by reference the range over which the attribute applies.
    open func attribute(_ attrName: NSAttributedStringKey, at location: Int, longestEffectiveRange range: NSRangePointer?, in rangeLimit: NSRange) -> Any? {
        let rangeInfo = RangeInfo(
            rangePointer: range,
            shouldFetchLongestEffectiveRange: true,
            longestEffectiveRangeSearchRange: rangeLimit)
        return _attribute(attrName, atIndex: location, rangeInfo: rangeInfo)
    }

    /// Returns a Boolean value that indicates whether the receiver is equal to another given attributed string.
    open func isEqual(to other: NSAttributedString) -> Bool { NSUnimplemented() }

    /// Returns an NSAttributedString object initialized with the characters of a given string and no attribute information.
    public init(string: String) {
        _string = string._nsObject
        _attributeArray = CFRunArrayCreate(kCFAllocatorDefault)
        
        super.init()
        addAttributesToAttributeArray(attrs: nil)
    }

    /// Returns an NSAttributedString object initialized with a given string and attributes.
    public init(string: String, attributes attrs: [NSAttributedStringKey : Any]? = nil) {
        _string = string._nsObject
        _attributeArray = CFRunArrayCreate(kCFAllocatorDefault)

        super.init()
        addAttributesToAttributeArray(attrs: attrs)
    }

    /// Returns an NSAttributedString object initialized with the characters and attributes of another given attributed string.
    public init(attributedString: NSAttributedString) {
        NSUnimplemented()
    }

    /// Executes the block for each attribute in the range.
    open func enumerateAttributes(in enumerationRange: NSRange, options opts: NSAttributedString.EnumerationOptions = [], using block: ([NSAttributedStringKey : Any], NSRange, UnsafeMutablePointer<ObjCBool>) -> Swift.Void) {
        _enumerate(in: enumerationRange, reversed: opts.contains(.reverse)) { currentIndex, stop in
            var attributesEffectiveRange = NSRange(location: NSNotFound, length: 0)
            let attributesInRange: [NSAttributedStringKey : Any]
            if opts.contains(.longestEffectiveRangeNotRequired) {
                attributesInRange = attributes(at: currentIndex, effectiveRange: &attributesEffectiveRange)
            } else {
                attributesInRange = attributes(at: currentIndex, longestEffectiveRange: &attributesEffectiveRange, in: enumerationRange)
            }
            
            var shouldStop: ObjCBool = false
            block(attributesInRange, attributesEffectiveRange, &shouldStop)
            stop.pointee = shouldStop
            
            return attributesEffectiveRange
        }
    }

    /// Executes the block for the specified attribute run in the specified range.
    open func enumerateAttribute(_ attrName: NSAttributedStringKey, in enumerationRange: NSRange, options opts: NSAttributedString.EnumerationOptions = [], using block: (Any?, NSRange, UnsafeMutablePointer<ObjCBool>) -> Swift.Void) {
        _enumerate(in: enumerationRange, reversed: opts.contains(.reverse)) { currentIndex, stop in
            var attributeEffectiveRange = NSRange(location: NSNotFound, length: 0)
            let attributeInRange: Any?
            if opts.contains(.longestEffectiveRangeNotRequired) {
                attributeInRange = attribute(attrName, at: currentIndex, effectiveRange: &attributeEffectiveRange)
            } else {
                attributeInRange = attribute(attrName, at: currentIndex, longestEffectiveRange: &attributeEffectiveRange, in: enumerationRange)
            }
            
            var shouldStop: ObjCBool = false
            block(attributeInRange, attributeEffectiveRange, &shouldStop)
            stop.pointee = shouldStop
            
            return attributeEffectiveRange
        }
    }

}

private extension NSAttributedString {
    
    struct AttributeEnumerationRange {
        let startIndex: Int
        let endIndex: Int
        let reversed: Bool
        var currentIndex: Int
        
        var hasMore: Bool {
            if reversed {
                return currentIndex >= endIndex
            } else {
                return currentIndex <= endIndex
            }
        }
        
        init(range: NSRange, reversed: Bool) {
            let lowerBound = range.location
            let upperBound = range.location + range.length - 1
            self.reversed = reversed
            startIndex = reversed ? upperBound : lowerBound
            endIndex = reversed ? lowerBound : upperBound
            currentIndex = startIndex
        }
        
        mutating func advance(step: Int = 1) {
            if reversed {
                currentIndex -= step
            } else {
                currentIndex += step
            }
        }
    }
    
    struct RangeInfo {
        let rangePointer: NSRangePointer?
        let shouldFetchLongestEffectiveRange: Bool
        let longestEffectiveRangeSearchRange: NSRange?
    }
    
    func _attributes(at location: Int, rangeInfo: RangeInfo) -> [NSAttributedStringKey : Any] {
        var cfRange = CFRange()
        return withUnsafeMutablePointer(to: &cfRange) { (cfRangePointer: UnsafeMutablePointer<CFRange>) -> [NSAttributedStringKey : Any] in
            // Get attributes value using CoreFoundation function
            let value: CFDictionary
            if rangeInfo.shouldFetchLongestEffectiveRange, let searchRange = rangeInfo.longestEffectiveRangeSearchRange {
                value = CFAttributedStringGetAttributesAndLongestEffectiveRange(_cfObject, location, CFRange(searchRange), cfRangePointer)
            } else {
                value = CFAttributedStringGetAttributes(_cfObject, location, cfRangePointer)
            }
            
            // Convert the value to [String : AnyObject]
            let dictionary = unsafeBitCast(value, to: NSDictionary.self)
            var results = [NSAttributedStringKey : Any]()
            for (key, value) in dictionary {
                guard let stringKey = (key as? NSString)?._swiftObject else {
                    continue
                }
                results[NSAttributedStringKey(stringKey)] = value
            }
            
            // Update effective range and return the results
            rangeInfo.rangePointer?.pointee.location = cfRangePointer.pointee.location
            rangeInfo.rangePointer?.pointee.length = cfRangePointer.pointee.length
            return results
        }
    }
    
    func _attribute(_ attrName: NSAttributedStringKey, atIndex location: Int, rangeInfo: RangeInfo) -> Any? {
        var cfRange = CFRange()
        return withUnsafeMutablePointer(to: &cfRange) { (cfRangePointer: UnsafeMutablePointer<CFRange>) -> AnyObject? in
            // Get attribute value using CoreFoundation function
            let attribute: AnyObject?
            if rangeInfo.shouldFetchLongestEffectiveRange, let searchRange = rangeInfo.longestEffectiveRangeSearchRange {
                attribute = CFAttributedStringGetAttributeAndLongestEffectiveRange(_cfObject, location, attrName.rawValue._cfObject, CFRange(searchRange), cfRangePointer)
            } else {
                attribute = CFAttributedStringGetAttribute(_cfObject, location, attrName.rawValue._cfObject, cfRangePointer)
            }
            
            // Update effective range and return the result
            rangeInfo.rangePointer?.pointee.location = cfRangePointer.pointee.location
            rangeInfo.rangePointer?.pointee.length = cfRangePointer.pointee.length
            return attribute
        }
    }
    
    func _enumerate(in enumerationRange: NSRange, reversed: Bool, using block: (Int, UnsafeMutablePointer<ObjCBool>) -> NSRange) {
        var attributeEnumerationRange = AttributeEnumerationRange(range: enumerationRange, reversed: reversed)
        while attributeEnumerationRange.hasMore {
            var stop: ObjCBool = false
            let effectiveRange = block(attributeEnumerationRange.currentIndex, &stop)
            attributeEnumerationRange.advance(step: effectiveRange.length)
            if stop.boolValue {
                break
            }
        }
    }
    
    func addAttributesToAttributeArray(attrs: [NSAttributedStringKey : Any]?) {
        guard _string.length > 0 else {
            return
        }
        
        let range = CFRange(location: 0, length: _string.length)
        var attributes: [String : Any] = [:]
        if let attrs = attrs {
            attrs.forEach { attributes[$0.rawValue] = $1 }
        }
        CFRunArrayInsert(_attributeArray, range, attributes._cfObject)
    }
}

extension NSAttributedString: _CFBridgeable {
    internal var _cfObject: CFAttributedString { return unsafeBitCast(self, to: CFAttributedString.self) }
}

extension NSAttributedString {

    public struct EnumerationOptions: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        public static let reverse = EnumerationOptions(rawValue: 1 << 1)
        public static let longestEffectiveRangeNotRequired = EnumerationOptions(rawValue: 1 << 20)
    }

}


open class NSMutableAttributedString : NSAttributedString {
    
    open func replaceCharacters(in range: NSRange, with str: String) { NSUnimplemented() }
    open func setAttributes(_ attrs: [NSAttributedStringKey : Any]?, range: NSRange) { NSUnimplemented() }
    
    open var mutableString: NSMutableString {
        return _string as! NSMutableString
    }

    open func addAttribute(_ name: NSAttributedStringKey, value: Any, range: NSRange) {
        CFAttributedStringSetAttribute(_cfMutableObject, CFRange(range), name.rawValue._cfObject, _SwiftValue.store(value))
    }

    open func addAttributes(_ attrs: [NSAttributedStringKey : Any], range: NSRange) { NSUnimplemented() }
    
    open func removeAttribute(_ name: NSAttributedStringKey, range: NSRange) { NSUnimplemented() }
    
    open func replaceCharacters(in range: NSRange, with attrString: NSAttributedString) { NSUnimplemented() }
    open func insert(_ attrString: NSAttributedString, at loc: Int) { NSUnimplemented() }
    open func append(_ attrString: NSAttributedString) { NSUnimplemented() }
    open func deleteCharacters(in range: NSRange) { NSUnimplemented() }
    open func setAttributedString(_ attrString: NSAttributedString) { NSUnimplemented() }
    
    open func beginEditing() { NSUnimplemented() }
    open func endEditing() { NSUnimplemented() }
    
    public override init(string str: String) {
        super.init(string: str)
        _string = NSMutableString(string: str)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        NSUnimplemented()
    }
    
}

extension NSMutableAttributedString {
    internal var _cfMutableObject: CFMutableAttributedString { return unsafeBitCast(self, to: CFMutableAttributedString.self) }
}

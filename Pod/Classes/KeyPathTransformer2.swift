//
//  KeyPathTransformer2.swift
//  Pods
//
//  Created by Gabriel Coman on 27/03/2016.
//
//

import UIKit
import Dollar

infix operator => { associativity right precedence 100 }

public func => <T> (left: AnyObject?, right: (Int, Transform<T>) -> () ) {
    if let array = left as? [AnyObject] {
        $.each(array) { (i, _) in
            if let element = array[i] as? [String:T] {
                let trans = Transform<T>(element)
                right(i, trans)
            } else {
                print("Could not convert callback parameter")
            }
        }
    }
}

public func => <T> (left: AnyObject?, right: (Int, T)->() ) {
    print("going normal route")
    if let array = left as? [AnyObject] {
        $.each(array) { (i, _) in
            if let element = array[i] as? T {
                right(i, element)
            } else {
                print("Could not convert callback parameter")
            }
        }
    } else {
        print("Left hand operand not an array or is a nil value")
    }
}

public final class Transform <T>: NSObject {
    private var source: [String:T] = [:];
    private var destination: [String:AnyObject] = [:];
    
    public init(_ source: [String:T]) {
        super.init()
        self.source = source
    }
    
    public static func create(_ source:[String:T], _ callback:(inout Transform)->()) -> Transform {
        var transform = Transform<T>(source)
        callback(&transform)
        return transform
    }
    
    public subscript (key: String) -> AnyObject? {
        get {
            let result = get(source, from: key)
            if let result = result as? [AnyObject] {
                return $.flatten(result)
            }
            return result
        }
        set (value) {
            if let val = value {
                set(&destination, to: key, val: val)
            }
        }
    }
    
    public func result() -> [String:AnyObject] {
        return destination
    }
}

// module function that does a "keypath" get on a dictionary
func get<T>(dict: [String:T], from: String) -> AnyObject? {
    var inner: [String:AnyObject] = [:]
    for key in dict.keys {
        if let value = dict[key] as? AnyObject {
            inner[key] = value
        }
    }
    if let value = (inner as NSDictionary).valueForKeyPath(from) {
        if let value = value as? AnyObject {
            return value
        }
    }
    return nil
}

// module function that does a "keypath" set on a dictionary
func set<T>(inout dict: [String:T], to: String, val: T) {
    var keys = to.componentsSeparatedByString(".") as [String]
    let first = keys.first as String!
    if keys.count == 1 {
        dict[first] = val
    } else {
        keys.removeFirst()
        let rejoined = keys.joinWithSeparator(".")
        
        var subdict: [String:T] = [:]
        
        if dict[first] != nil, let settable = dict[first] as? [String:T] {
            subdict = settable
        }
        
        set(&subdict, to: rejoined, val: val)
        if let settable = subdict as? T {
            dict[first] = settable
        }
    }
}

//
// module function that does a "keypath" set on a dictionary
func set<T>(inout dict: [String:T?], to: String, val: T) {
    var keys = to.componentsSeparatedByString(".") as [String]
    let first = keys.first as String!
    
    if keys.count == 1 {
        dict[first] = val
    } else {
        keys.removeFirst()
        let rejoined = keys.joinWithSeparator(".")
        
        var subdict: [String:T] = [:]
        
        if dict[first] != nil, let settable = dict[first] as? [String:T] {
            subdict = settable
        }
        
        set(&subdict, to: rejoined, val: val)
        if let settable = subdict as? T {
            dict[first] = settable
        }
    }
}



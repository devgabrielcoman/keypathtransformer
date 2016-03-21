//
//  KeyPathTransformer2.swift
//  Pods
//
//  Created by Gabriel Coman on 20/03/2016.
//
//

import UIKit
import Dollar

infix operator <- { associativity left precedence 140 }
infix operator => { associativity left precedence 140 }
infix operator +> { associativity left precedence 100 }
infix operator <> { associativity left precedence 100 }

public func <- <T>(left: Dictionary<String, T>, right: String) -> T? {
    return get(left, from: right)
}

public func +> <T>(left: KeyPathTransformer<T>, right: (T, String) ) {
    left.add(value: right.0, to: right.1)
}

public func => <A, B> (left: A, right: B) -> (A, B) {
    return (left, right)
}

public func => <A, T>(left: A, right: (T)->()) -> (A, (T)->()) {
    return (left, right)
}

public func => <A, T>(left: (A, A), right: (Int, Dictionary<String, T>) -> (Dictionary<String, T>)) -> ((A, A), (Int, Dictionary<String, T>) -> (Dictionary<String, T>)) {
    return (left, right)
}

public func <> <T>(left: KeyPathTransformer<T>, right: (String, String) ) {
    left.apply(from: right.0, to: right.1)
}

public func <> <T>(left: KeyPathTransformer<T>, right: (String, (Int, T)->())){
    left.traverse(right.0, callback: right.1)
}

public func <> <T>(left: KeyPathTransformer<T>, right: ((String, String), (Int, Dictionary<String, T>) -> (Dictionary<String, T>))) {
    left.apply(right.0, callback: right.1)
}


public class KeyPathTransformer <T>: NSObject {

    private var dictToTransform: Dictionary<String, T> = [:]
    private var dictTransformed: Dictionary<String, T> = [:]
    
    public init(_ dict: Dictionary<String, T>) {
        super.init()
        dictToTransform = dict
    }
    
    public func transform() -> Dictionary<String, T> {
        return dictTransformed
    }
    
    public func add(value _value: T, to _to: String) {
        set(&dictTransformed, to: _to, val: _value)
    }
    
    public func apply(from _from: String, to _to: String) {
        if let value = get(dictToTransform, from: _from) {
            set(&dictTransformed, to: _to, val: value)
        }
    }
    
    public func apply (rule: (String, String), callback: (Int, Dictionary<String, T>) -> (Dictionary<String, T>)) {
        let source = rule.0
        let destination = rule.1
        var result: [Dictionary<String, T>] = []
        
        if let array = get(dictToTransform, from: source) as? [Dictionary<String, T>] {
            let flattened = $.flatten(array)
            $.each(flattened) { (i, _) in
                result.append(callback(i, flattened[i]))
            }
        }
        
        if let result = result as? T {
            set(&dictTransformed, to: destination, val: result)
        }
    }

    public func traverse(keyPath: String, callback: (Int, T)->() ) {
        if let array = get(dictToTransform, from: keyPath) as? [T] {
            let flattened = $.flatten(array)
            $.each(flattened) { (i, _) in
                callback(i, flattened[i])
            }
        }
    }

}

// FUNCTIONS THAT ACTUALLY WORK ON ALL TYPES !!!
//
func get<T>(dict: Dictionary<String, T>, from: String) -> T? {
    var inner: Dictionary<String, AnyObject> = [:]
    for key in dict.keys {
        if let value = dict[key] as? AnyObject {
            inner[key] = value
        }
    }
    if let value = (inner as NSDictionary).valueForKeyPath(from) {
        if let value = value as? T {
            return value
        }
    }
    return nil
}

//
// generic setter function
func set<T>(inout dict: Dictionary<String, T>, to: String, val: T) {
    var keys = to.componentsSeparatedByString(".") as [String]
    let first = keys.first as String!
    if keys.count == 1 {
        dict[first] = val
    } else {
        keys.removeFirst()
        let rejoined = keys.joinWithSeparator(".")
        
        var subdict: Dictionary<String,  T> = [:]
        
        if dict[first] != nil, let settable = dict[first] as? Dictionary<String, T> {
            subdict = settable
        }
        
        set(&subdict, to: rejoined, val: val)
        if let settable = subdict as? T {
            dict[first] = settable
        }
    }
}

func set<T>(inout dict: Dictionary<String, T?>, to: String, val: T) {
    var keys = to.componentsSeparatedByString(".") as [String]
    let first = keys.first as String!
    
    if keys.count == 1 {
        dict[first] = val
    } else {
        keys.removeFirst()
        let rejoined = keys.joinWithSeparator(".")
        
        var subdict: Dictionary<String,  T> = [:]
        
        if dict[first] != nil, let settable = dict[first] as? Dictionary<String, T> {
            subdict = settable
        }
        
        set(&subdict, to: rejoined, val: val)
        if let settable = subdict as? T {
            dict[first] = settable
        }
    }
}


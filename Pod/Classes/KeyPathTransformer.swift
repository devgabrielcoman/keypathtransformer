//
//  KeyPathTransformer.swift
//  Pods
//
//  Created by Gabriel Coman on 20/03/2016.
//
//  KeyPathTransformer is a simple library that defines a set of operators 
//  and functions that make it easy to transform one dictionary into another
//  dictionary.
//

import UIKit
import Dollar

//
// define a set of operators to allow users to work with
// KeyPathTransformer more easily
infix operator <- { associativity left precedence 140 }
infix operator => { associativity left precedence 140 }
infix operator +> { associativity left precedence 100 }
infix operator <> { associativity left precedence 100 }

//
// the <- operator returns the object (left) found at a KeyPath (right)
// @usage: mydict <- "employee_name"
// @usage: mydict <- "employee.details.name"
public func <- <T>(left: Dictionary<String, T>, right: String) -> T? {
    return get(left, from: right)
}

//
// the +> operator is used on a transform to add new values
// @usage: transform +> 32.5 => "employee_name"
// @usage: transform +> "credit_card" => "employee.details.payment"
public func +> <T>(left: KeyPathTransformer<T>, right: (T, String) ) {
    left.add(value: right.0, to: right.1)
}

//
// the => operator in this case returns a tuple from it's left and right parameters
// @usage "date_birth" => "birdthdate" (e.g. becomes ("date_birth", "birthdate")
public func => <A, B> (left: A, right: B) -> (A, B) {
    return (left, right)
}

//
// the => operator in this case returns a tuple from A and a function
// @usage "payment_history" => { (i, history) in ... }
public func => <A, T>(left: A, right: (T)->()) -> (A, (T)->()) {
    return (left, right)
}

//
// the => operator in this case returns a complex tuple between:
// - another tuple of A 
// - a complex callback function
// @usage "payment_history" => "payments" => { (i, payment) in ... }
public func => <A, T>(left: (A, A), right: (Int, Dictionary<String, T>) -> (Dictionary<String, T>)) -> ((A, A), (Int, Dictionary<String, T>) -> (Dictionary<String, T>)) {
    return (left, right)
}

// 
// the <> operator in this case applies a transform on a tuple
// @usage transform <> "payment_history" => "payments"
// @usage transform <> "education" => "details.education"
public func <> <T>(left: KeyPathTransformer<T>, right: (String, String) ) {
    left.apply(from: right.0, to: right.1)
}

// 
// the <> operator in this case applies a complex transform between
// - a KeyPathTransformer object
// - a complex tuple consisting of
// -- another tuple
// -- a complex function
// @usage transform <> "payment_history" => "payments" => { (i, payment) in ... }
public func <> <T>(left: KeyPathTransformer<T>, right: ((String, String), (Int, Dictionary<String, T>) -> (Dictionary<String, T>))) {
    left.apply(right.0, callback: right.1)
}

// the <> operator in this case applies a complex transform between
// - a KeyPathTransformer object
// - a complex tuple consisting of
// -- a string
// -- a callback functon
// @usage transform <> "payment_history" => { (i, payment) in ... }
public func <> <T>(left: KeyPathTransformer<T>, right: (String, (Int, T)->())){
    left.traverse(right.0, callback: right.1)
}

// 
// the KeyPathTransformer generic class definition
public class KeyPathTransformer <T>: NSObject {

    // the source dictionary
    private var dictToTransform: Dictionary<String, T> = [:]
    // the destination dictionary
    private var dictTransformed: Dictionary<String, T> = [:]
    
    // normal init
    public override init() {
        // do nothing
    }
    
    // custom init
    public init(_ dict: Dictionary<String, T>) {
        super.init()
        dictToTransform = dict
    }
    
    //
    // function that should be called at the end of the transform to get the
    // transformed dictionary
    public func transform() -> Dictionary<String, T> {
        return dictTransformed
    }
    
    //
    // transform function that's actually called by the +> operator
    public func add(value _value: T, to _to: String) {
        set(&dictTransformed, to: _to, val: _value)
    }
    
    //
    // transform function that's actually called by the <> operator
    public func apply(from _from: String, to _to: String) {
        if let value = get(dictToTransform, from: _from) {
            set(&dictTransformed, to: _to, val: value)
        }
    }
    
    //
    // transform function that's actually called by the <> operator with complex
    // callback to traverse and change the dictionary
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

    //
    // transform function that's actually called by the <> operator to tranverse
    // a dictionary structure
    public func traverse(keyPath: String, callback: (Int, T)->() ) {
        if let array = get(dictToTransform, from: keyPath) as? [T] {
            let flattened = $.flatten(array)
            $.each(flattened) { (i, _) in
                callback(i, flattened[i])
            }
        }
    }

}

//
// module function that does a "keypath" get on a dictionary
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
// module function that does a "keypath" set on a dictionary
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

//
// module function that does a "keypath" set on a dictionary
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


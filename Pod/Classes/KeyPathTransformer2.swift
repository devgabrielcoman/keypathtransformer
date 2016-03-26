//
//  KeyPathTransformer2.swift
//  Pods
//
//  Created by Gabriel Coman on 22/03/2016.
//
//

import UIKit
import Dollar

//infix operator <- { associativity left precedence 140 }
//infix operator |> { associativity left precedence 150 }
//infix operator => { associativity left precedence 140 }
//infix operator +> { associativity left precedence 100 }
//infix operator <> { associativity left precedence 100 }
//
//public func => <T> (left: T, right: String) -> (T, String) {
//    return (left, right)
//}
//
//public func => <T> (left: T, right: String) -> (AnyObject, String) {
//    return (left as! AnyObject, right)
//}
//
//public func => <A, T>(left: A, right: (T)->()) -> (A, (T)->()) {
//    return (left, right)
//}
//
//public func |> <T> (inout left: Dictionary<String, T>, inout right: Dictionary<String, T>) -> (Dictionary<String, T>, Dictionary<String, T>){
//    return (left, right)
//}
//
//public func <- <T> (left: Dictionary<String, T>, right: String) -> T? {
//    return get(left, from: right)
//}
//
//public func +> <T> (inout left: Dictionary<String, T>, right: (T, String)) {
//    set(&left, to: right.1, val: right.0)
//}
//
//public func <> <T, A> (inout left: Dictionary<String, T>, right: (key: String, callback: (Int,A)->()) ) {
//    if let array = get(left, from: right.key) as? [A] {
//        let flattened = $.flatten(array)
//        $.each(flattened) { (i, _) in
//            right.callback(i, flattened[i])
//        }
//    }
//}
//
//public func <> <T> (inout left: (source: Dictionary<String, T>, dest: Dictionary<String,T>), right: (source: String, dest: String)) {
//    if let value = get(left.source, from: right.source) {
//        set(&left.dest, to: right.dest, val: value)
//    }
//}
//
////
//// module function that does a "keypath" get on a dictionary
//func get<T>(dict: Dictionary<String, T>, from: String) -> T? {
//    var inner: Dictionary<String, AnyObject> = [:]
//    for key in dict.keys {
//        if let value = dict[key] as? AnyObject {
//            inner[key] = value
//        }
//    }
//    if let value = (inner as NSDictionary).valueForKeyPath(from) {
//        if let value = value as? T {
//            return value
//        }
//    }
//    return nil
//}
//
////
//// module function that does a "keypath" set on a dictionary
//func set<T>(inout dict: Dictionary<String, T>, to: String, val: T) {
//    var keys = to.componentsSeparatedByString(".") as [String]
//    let first = keys.first as String!
//    if keys.count == 1 {
//        dict[first] = val
//    } else {
//        keys.removeFirst()
//        let rejoined = keys.joinWithSeparator(".")
//        
//        var subdict: Dictionary<String,  T> = [:]
//        
//        if dict[first] != nil, let settable = dict[first] as? Dictionary<String, T> {
//            subdict = settable
//        }
//        
//        set(&subdict, to: rejoined, val: val)
//        if let settable = subdict as? T {
//            dict[first] = settable
//        }
//    }
//}
//
////
//// module function that does a "keypath" set on a dictionary
//func set<T>(inout dict: Dictionary<String, T?>, to: String, val: T) {
//    var keys = to.componentsSeparatedByString(".") as [String]
//    let first = keys.first as String!
//    
//    if keys.count == 1 {
//        dict[first] = val
//    } else {
//        keys.removeFirst()
//        let rejoined = keys.joinWithSeparator(".")
//        
//        var subdict: Dictionary<String,  T> = [:]
//        
//        if dict[first] != nil, let settable = dict[first] as? Dictionary<String, T> {
//            subdict = settable
//        }
//        
//        set(&subdict, to: rejoined, val: val)
//        if let settable = subdict as? T {
//            dict[first] = settable
//        }
//    }
//}

//func del<T>(inout dict: Dictionary<String, T>, to: String) {
//    var keys = to.componentsSeparatedByString(".") as [String]
//    let first = keys.first as String!
//    
//    if keys.count == 1 {
//        dict[first] = nil
//    } else {
//        keys.removeFirst()
//        let rejoined = keys.joinWithSeparator(".")
//        var subdict: Dictionary<String, T> = [:]
//        
//        if dict[first] != nil, let settable = dict[first] as? Dictionary<String, T> {
//            subdict = settable
//        }
//        del(&subdict, to: rejoined)
//    }
//}

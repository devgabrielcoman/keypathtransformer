//
//  KeyPathTransformer3.swift
//  Pods
//
//  Created by Gabriel Coman on 26/03/2016.
//
//

import UIKit
import Dollar

infix operator <- { associativity left precedence 170 }
infix operator +> { associativity right precedence 140 }
infix operator <> { associativity left precedence 140 }
infix operator => { associativity right precedence 100 }

public func <- <T> (left: [String:T], right: String) -> T? {
    return get(left, from: right)
}

public func +> <T, A> (left: String, right: T) -> (String, A) {
    return (left, right as! A)
}

public func <> <T, A> (left: String, right: ()->(T)) -> (String, A) {
    return (left, right() as! A)
}

public func <> <T> (left: String, right: (Int, T)->()) -> (String, (Int, T)->()) {
    return (left, right)
}

public func => <T> (inout left: [String:T], right: (String, T)) {
    set(&left, to: right.0, val: right.1)
}

public func => <T, A> (left: [String:T], right: (String, (Int, A)->())) {
    let dict = left
    let keyPath = right.0
    let callback = right.1
    
    if let array = get(dict, from: keyPath) as? [AnyObject] {
        let flattened = $.flatten(array)
        $.each(flattened) { (i, _) in
            callback(i, flattened[i] as! A)
        }
    }

}

// module function that does a "keypath" get on a dictionary
func get<T>(dict: [String:T], from: String) -> T? {
    var inner: [String:AnyObject] = [:]
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

/**
 
 var dict1 = [String, AnyObject]()
 
 // adding values to "emp.name"
 dict1 => "emp.name" +> dict2 <- "abc.def.ghf"
 dict1 => "emp.salary" +> 23.5
 
 // adding a dictionary to "geo", v1
 dict1 => "geo" <> {
    return {
        "longitude": dict2 <- "longitude",
        "latitude: dict2 <- "latitude"
    }
 }
 
 // adding a dictionary to "geo", v2
 dict1 => "geo" <> {
    var dict2 = [String, AnyObject]()
    dict2 => "longitude" +> 33.5
    dict2 => "latitude" +> 125.5
    return dict2
 }
 
 // or ... cheaply
 dict1 => "geo" +> [
    "longitude": dict2 <- "longitude",
    "latitude: dict2 <- "latitude"
 ]
 
 // both could be written as
 dict1 => "geo.longitude" +> dict2 <- "longitude"
 dict1 => "geo.latitude" +> dict2 <- "latitude"
 
 // going over some values from array "notes"
 // operator => should either return value or return array callback
 dict2 => "notes" { (i, value: [String, AnyObject]) in
    dict1 => value.name +> dict2 <- value.grade
 }
 
 dict1 => "education" <> {
    var array: [AnyObject] = []
    dict2 => "history.grades" { (i, grade: [String, AnyObject]) in
        array.append({
            "college_name":  grade <- "name",
            "start_date": grade <- "dates.start",
            "end_date": grade <- "dates.end"
        })
    }
    return array
 }
 
 */
//
//  KeyPath.swift
//  Pods
//
//  Created by Gabriel Coman on 28/03/2016.
//
//

import UIKit

//
// Function that performs a "KeyPath get" on a dictionary
// e.g. get(myDict, from: "employee.details.name"
//
// @param: a dictionary with Key as String and any type of value
// @param: a KeyPath value as String
// @return: AnyObject optional
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

//
// Function that performs a "KeyPath set" on a dictionary
// e.g. set(myDict, to: "employee.details.name", val: "John")
//
// @param: dictionary reference 
// @param: a KeyPath value as String
// @param: the value to be set
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
// Same thing as above, only for dictionaries containing optionals
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
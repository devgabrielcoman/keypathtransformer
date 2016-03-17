//
// Dictionary+KeyPath.swift
// Pods
//
// Created by Gabriel Coman on 12/03/2016.
//
// This is a private extension to the Dictionary type that adds a form of
// really simple Key-Path-Coding, similar to what NSDictionary has.
// It does so by casting to NSDictionary for "get" operations, which should
// allow it to obtain all the NSDictionary power.
// For "set" however it just tries to create the appropriate dictionary or
// array structure
//

//
//
import UIKit
import Dollar

public extension Dictionary where Key: StringLiteralConvertible , Value: AnyObject {
    
    //
    // the "get" at keyPath function simply casts a Dictionary as a NSDictionary
    // and lets Cocoa work its magic
    func get(keyPath: String) -> AnyObject? {
        if let dict = (self as? AnyObject) as? Dictionary<String, AnyObject> {
            return (dict as NSDictionary).valueForKeyPath(keyPath)
        }
        return nil
    }
    
    //
    // The "set" value at keyPath function tries to create the structure that's
    // required of it by the keyPath parameter, as best it can.
    // It's implied that the keypath is valid, and the checking is fair but minimal
    // no correction is applied
    mutating func set (val: AnyObject?, keyPath: String) {
        var keys = keyPath.componentsSeparatedByString(".")
        guard let first = keys.first as? Key else { print("Unable to use string as key on type: \(Key.self)"); return }
        keys.removeAtIndex(0)
        
        if keys.isEmpty, let settable = val as? Value {
            self[first] = settable
        } else {
            let rejoined = keys.joinWithSeparator(".")
            var subdict: [String : AnyObject] = [:]
            if let sub = self[first] as? [String : AnyObject] {
                subdict = sub
            }
            subdict.set(val, keyPath: rejoined)
            if let settable = subdict as? Value {
                self[first] = settable
            } else {
                print("Unable to set value: \(subdict) to dictionary of type: \(self.dynamicType)")
            }
        }
    }
    
    //
    // *** WARN ***
    // This is deprecated and not included for now, but
    // might be included in a future release, alongside some other new functionality
//    mutating func setInArray(val: AnyObject, inArray keyPathForArray: String, atKeyPath keyPathInsideArray: String) {
//        var initial = self.get(keyPathForArray) as! [Dictionary]
//        let values = val as! [AnyObject]
//        
//        if initial.count == 0 {
//            $.each(values) { (i, object) in
//                var dict: Dictionary = [:]
//                dict.set(object, keyPath: keyPathInsideArray)
//                initial.append(dict)
//            }
//        }
//        else {
//            $.each(initial) { (i, _) in
//                initial[i].set(val[i], keyPath: keyPathInsideArray)
//            }
//        }
//        
//        self.set(initial as! AnyObject, keyPath: keyPathForArray)
//    }
}

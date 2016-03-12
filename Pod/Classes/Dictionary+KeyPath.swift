//
//  Dictionary+KeyPath.swift
//  Pods
//
//  Created by Gabriel Coman on 12/03/2016.
//
//

import UIKit
import Dollar

extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    func get(keyPath: String) -> AnyObject? {
        if let dict = (self as? AnyObject) as? Dictionary<String, AnyObject> {
            return (dict as NSDictionary).valueForKeyPath(keyPath)
        }
        return nil
    }
    
    mutating func set(val: AnyObject, keyPath: String) {
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
}
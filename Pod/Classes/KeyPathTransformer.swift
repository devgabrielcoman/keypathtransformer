//
//  KeyPathTransformer.swift
//  Pods
//
//  Created by Gabriel Coman on 12/03/2016.
//
//

import UIKit
import Dollar

// define new operator
infix operator => { associativity left precedence 140 } // 1
public func =><T>(left: T, right: T) -> (T, T) {
    return (left, right)
}
public func =>(left: AnyObject?, right: String) -> (AnyObject?, String) {
    return (left, right)
}

// define the KeyPath Transform class
public class KeyPathTransformer: NSObject {
    
    // references to two dictionaries
    private var dictToTransform: Dictionary<String, AnyObject> = [:]
    private var dictTransformed: Dictionary<String, AnyObject> = [:]
    
    public init(_ dict: Dictionary<String, AnyObject>) {
        super.init()
        dictToTransform = dict
    }
    
    public func add(set: (AnyObject?, String)) {
        let value = set.0
        let keyPath = set.1
        
        if let value = value {
            dictTransformed.set(value, keyPath: keyPath)
        }
    }
    
    public func apply(rule: (String, String)) {
        let source = rule.0
        let destination = rule.1
        
        if let val = dictToTransform.get(source) {
            dictTransformed.set(val, keyPath: destination)
        }
    }
    
    public func applyArray(rule: (String, String), callback: (Dictionary<String, AnyObject>) -> (Dictionary<String, AnyObject>)) {
        let source = rule.0
        let destination = rule.1
        var result: [Dictionary<String, AnyObject>] = []
        
        if let array = dictToTransform.get(source) as? Array<AnyObject> {
            let flattened = $.flatten(array)
            if let flattened = flattened as? [Dictionary<String, AnyObject>] {
                $.each(flattened) { (i, _) in
                    result.append(callback(flattened[i]))
                }
            }
        }
        
        dictTransformed.set(result, keyPath: destination)
    }
    
    public func transform () -> Dictionary<String, AnyObject> {
        return dictTransformed
    }
}

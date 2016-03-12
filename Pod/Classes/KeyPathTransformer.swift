//
//  KeyPathTransformer.swift
//  Pods
//
//  Created by Gabriel Coman on 12/03/2016.
//
//

import UIKit
import Dollar

public class KeyPathTransformer: NSObject {
    
    private var dictToTransform: Dictionary<String, AnyObject> = [:]
    private var dictTransformed: Dictionary<String, AnyObject> = [:]
    
    public init(_ dict: Dictionary<String, AnyObject>) {
        super.init()
        dictToTransform = dict
    }
    
    public func applyRule(source: String, _ dest: String) {
        if let val = dictToTransform.get(source) {
            dictTransformed.set(val, keyPath: dest)
        }
    }
    
    public func applyRuleArray(source: String, _ dest: String, callback: (Dictionary<String, AnyObject>) -> (Dictionary<String, AnyObject>)) {
        var result: [Dictionary<String, AnyObject>] = []
        if let array = dictToTransform.get(source) as? [Dictionary<String, AnyObject>] {
            
            $.each(array) { (i, _) in
                result.append(callback(array[i]))
            }
        }
        dictTransformed.set(result, keyPath: dest)
    }
    
    public func transform () -> Dictionary<String, AnyObject> {
        return dictTransformed
    }
}

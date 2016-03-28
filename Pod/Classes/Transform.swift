//
//  Transform.swift
//  Pods
//
//  Created by Gabriel Coman on 28/03/2016.
//
//

import UIKit
import Dollar

//
// The Transform class holds two dictionaries - a source and a destination one
// Ideally it's used as a way to elegantly use the Operators and KeyPath functions
// defined in this module to allow users to quckly convert one dictionary to 
// another
public final class Transform <T>: NSObject {
    // the source and destination private variables
    private var source: [String:T] = [:];
    private var destination: [String:AnyObject] = [:];
    
    // normal override init
    public override init() {
        super.init()
    }
    
    // classic init with a source dictionary
    public init(_ source: [String:T], copySourceIntoDest:Bool = false) {
        super.init()
        self.source = source
        if copySourceIntoDest {
            copySourceIntoDestination()
        }
    }
    
    // static factory function that creates a new instance, and also has a
    // setup callback
    public static func create(_ source:[String:T], _ callback:(inout Transform)->()) -> Transform {
        var transform = Transform<T>(source)
        callback(&transform)
        return transform
    }
    
    // redefinition of the subscript operator on the Transform class
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
    
    // in case you want to copy the source dict into the dest dict
    private func copySourceIntoDestination () {
        for key in source.keys {
            if let value = source[key] as? AnyObject {
                destination[key] = value
            }
        }
    }
    
    // function to get results from
    public func result() -> [String:AnyObject] {
        return destination
    }
}

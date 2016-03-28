//
//  Operators.swift
//  Pods
//
//  Created by Gabriel Coman on 28/03/2016.
//
//

import UIKit
import Dollar

//
// define the "Transform Selector" (=>) operator, which will be defined in two
// ways further down
infix operator => { associativity right precedence 100 }

//
// The first use-case operates on an object that should actually be an array
// and returns a callback with parameters Int (index) and a generic
public func => <T> (left: AnyObject?, right: (Int, T)->() ) {
    if let array = left as? [AnyObject] {
        $.each(array) { (i, _) in
            if let element = array[i] as? T {
                right(i, element)
            } else {
                print("Could not convert callback parameter")
            }
        }
    } else {
        print("Left hand operand not an array or is a nil value")
    }
}

//
// The second use-case is similar, but the second callback parameter is
// actually a transform; 
// it can only be applied on arrays of dictionaries of type [String:T]
public func => <T> (left: AnyObject?, right: (Int, Transform<T>) -> () ) {
    if let array = left as? [AnyObject] {
        $.each(array) { (i, _) in
            if let element = array[i] as? [String:T] {
                let trans = Transform<T>(element)
                right(i, trans)
            } else {
                print("Could not convert callback parameter")
            }
        }
    } else {
        print("Left hand operand not an array or is a nil value")
    }
}
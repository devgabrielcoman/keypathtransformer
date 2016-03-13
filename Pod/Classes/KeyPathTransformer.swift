//
// KeyPathTransformer.swift
// Pods
//
// Created by Gabriel Coman on 12/03/2016.
//
// KeyPathTransformer is a library that defines a special set of operators to
// ease the work of transforming from one Dictionary (or NSDictionary) structure
// to another.
//  
// The goal is to be able to do, as quickly and securely as possible,
// transforms of the following type:
//  
// Given an original dictionary:
//
//      var dict = ["name": "John Applebee", "age": 23]
//  
// transform it into:
//
//      var dict2 = ["employee_name": "John Appleebee", "employee_age": 23]
//
// or any combinations thereof.
//
//

//
// import libraries
// here UIKit is important but Dollar is used to add shorthand code instead of 
// "for-loops"
import UIKit
import Dollar

////////////////////////////////////////////////////////////////////////////////
// Declare a bunch of useful typealiases to make the madness smaller
////////////////////////////////////////////////////////////////////////////////

public typealias traverseCallback = (Dictionary<String, AnyObject>) -> ()
public typealias applyCallback = (Dictionary<String, AnyObject>) -> (Dictionary<String, AnyObject>)

////////////////////////////////////////////////////////////////////////////////
// The following operator describes a transform
////////////////////////////////////////////////////////////////////////////////

// 
// The "Describe Transform" operator
// At it's core it serves two main purposes:
// 
// 1. Describe how a transform should look, e.g.:
//
//      "name" => "details.employee_name"
//
// 2. Assign a callback for more complex processing, if the fields being transformed 
// are arrays or other more complex structures e.g. :
//
//      "employee" => "recruits" ==> { (namesDictionary) -> (Dictionary) in
//          "name" => "recruit_name"
//          "age"  => "recruit_age"
//          ...
//      }
//
infix operator => { associativity left precedence 140 }

//
// This generic version is used for transforms between one dictionary field to
// another; the left hand side and right hand side parameters all 
// all generic <T> parameters;
// In real life, they should be of String or NSString type
// This operator returns a simple tuple of type (T, T)
public func => <A> (left: A, right: A) -> (A, A) {
    return (left, right)
}

//
// This generic version is used for transforms in which a new field is added to
// the transformed dictionary, which did not exist in the original one
// In this case it take two generic A and B parameters;
// In real life A can be any value (Int, Float?, complex object) and
// B should be a String or NSString type
// This operator returns a simple tuple of type (A, B)
public func => <A, B> (left: A, right: B) -> (A, B) {
    return (left, right)
}

//
// This is a more complex version of the "Describe Transform" operator, which acts
// as a way of making it a "ternary operator"
// Simply put, when you do something like:
//
//      "name" => "employee_name" => { (dictionary) -> (dictionary in .... }
//
// the left-type associativity means that "name" => "employee_name" get first
// transformed into a tuple of ("name", "employee_name"), and then that
// tuple becomes the left-hand side parameter to the operator below.
// The right hand side parameter is of course a function that takes a dictionary
// as parameter (callback parameter) and returns another dictionary
//
// The whole operator returns a tuple between the original tuple and the function parameter
public func => <A>(left: (A, A), right: applyCallback) -> ((A, A), applyCallback) {
    return (left, right)
}

//
// This is a version of the operator that works with a String keyPath and a simple
// callback function, that takes one dictionary as parameter
// The left and right parameters are returned as a tuple of (String, Callback)
// It's to be used with the traverse function
public func => <A>(left: A, right: traverseCallback) -> (A, traverseCallback) {
    return (left, right)
}

////////////////////////////////////////////////////////////////////////////////
// The following two operator actually execute the transform
////////////////////////////////////////////////////////////////////////////////

//
// The second operator defined is the "Execute Addition" operator.
infix operator +> { associativity left precedence 100 }

//
// This operator takes a left-hand side operator of type Keypath transform,
// and a right-hand side operator of type tupe (AnyObject?, String).
//
// Its main purpose is to call the KeyPathTransformer function add() to set a new
// value in the dictionary that is to be transformed.
//
// Because of the nature of the left and right parameters and the precedence given
// each opearator, the final operation will look something like:
//
//      var transform = KeyPathTransformer(myDictionary)
//      transform +> "Jonh Wood" => "employee_name"
//
// which literally tells the transform to add a new field to the dictionary that's
// going to be created / transformed, called "employee_name" and set its value
// to "John Wood";
public func +> (left: KeyPathTransformer, right: (AnyObject?, String) ) {
    left.add(right)
}

//
// Finally this is the "Execute Transform" operator
infix operator <> { associativity left precedence 100 }

// 
// In the most simple case the "Execute Transform" operator takes a 
// left-hand side parameter of KeyPathTransformer type and a
// right-hand side parameter of tuple type
// Which means you will be able to do a chaining such as this:
//
//      var transform = KeyPathTransformer(myDictionary)
//      transform <> "name" => "employee_name"
//
// Basically the transforms checks to see if the original dictionary, myDictionary, 
// has a field named "name" and translates its value to a new field, called "employee_name", 
// in the destination dictionary
public func <> (left: KeyPathTransformer, right: (String, String) ) {
    left.apply(right)
}

//
// This "Execute Transform" operator actually works with the traverse KeyPathTransformer
// function;
// It's this library's shorthand version of a for-loop or a $.each functionpublic func apply

public func <> (left: KeyPathTransformer, right: (String, traverseCallback)){
    left.traverse(right.0, callback: right.1)
}

//
// This is the same thing as above, only this allows you to add as right-hand
// side parameter a tuple consisiting of another tuple (describing the transform) and
// a callback function, that takes a dictionary as parameter (accessible from the callback) 
// and expects a new dictionary as return type, possibly from another transform.
//
// This is usefull when transforming arrays of elements, like this:
//
//      var transform = KeyPathTransform(myDictionary)
//      transform <> "employees" => "recruits" => { (employee) -> (Dictionary) in 
//          var employeeTransform = KeyPathTransform(employee)
//
//          employeeTransform <> "name" => "rec_name"
//          employeeTransform <> "age" => "details.age"
//
//          return employeeTransform
//      }
//
public func <> (left: KeyPathTransformer, right: ((String, String), applyCallback)) {
    left.apply(right.0, callback: right.1)
}

////////////////////////////////////////////////////////////////////////////////
// Define a new class called KeyPathTransformer, which will contain the 
// background function needed to actually perform the transformation.
// Users shouldn't use this class' function directly, but by using the operators
// defined above
////////////////////////////////////////////////////////////////////////////////

public class KeyPathTransformer: NSObject {
    
    //
    // Maintain two dictionaries 
    // dictToTransform is the original one, which does not get mutated in any way
    // dictTransformed is the dictionary that's being mutated, one operation after the other
    private var dictToTransform: Dictionary<String, AnyObject> = [:]
    private var dictTransformed: Dictionary<String, AnyObject> = [:]
    
    // 
    // constructor takes one parameter, of type dictionary
    public init(_ dict: Dictionary<String, AnyObject>) {
        super.init()
        dictToTransform = dict
    }
    
    //
    // Behind the "+>" operator is the add function, which simply sets a 
    // certain value at a certain keypath, both specified as the first and second
    // parameters in a tuple
    // Note that the "set()" function is defined in the aux file Dictionary+KeyPath.
    // Without it setting values at key paths in Swift Dictionaries is a lot harder
    public func add(set: (AnyObject?, String)) {
        let value = set.0
        let keyPath = set.1
        
        if let value = value {
            dictTransformed.set(value, keyPath: keyPath)
        }
    }
    
    //
    // This is the simple form of the apply() function, which is what powers the
    // "<>" operator.
    // This simply takes one value from the source "dictToTransform" and sets it
    // at a different key in the destination "dictTransformed" dictionary.
    // This operation is of course not executed if the source dictionary does not
    // contain that key
    public func apply(rule: (String, String)) {
        let source = rule.0
        let destination = rule.1
        
        if let val = dictToTransform.get(source) {
            dictTransformed.set(val, keyPath: destination)
        }
    }
    
    //
    // This more complex form of the above function tries to apply the same
    // rule as above, but instead of simply mapping one key in the source dictionary
    // to a new key in the destination dictionary while maintaining the value, 
    // this looks at the "callback" function to transform the destination value
    // as well.
    public func apply(rule: (String, String), callback: applyCallback) {
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
    
    //
    // This function just traverses a dictionary array and each time it does so
    // it calles a callback with the array element (dictionary) as parameter
    // Its intended purpose is to allow splitting of an array of distinct elements
    // into a dictionary's main body
    public func traverse(keyPath: String, callback: traverseCallback) {
        if let array = dictToTransform.get(keyPath) as? Array<AnyObject> {
            let flattened = $.flatten(array)
            if let flattened = flattened as? [Dictionary<String, AnyObject>] {
                $.each(flattened) { (i, _) in
                    callback(flattened[i])
                }
            }
        }
    }
    
    // 
    // finally, this function returns the destination "dictTransformed"
    public func transform () -> Dictionary<String, AnyObject> {
        return dictTransformed
    }
}

KeyPathTransformer
==================

.. image:: https://img.shields.io/cocoapods/v/KeyPathTransformer.svg?style=flat
.. image:: https://img.shields.io/badge/language-swift2.2-f48041.svg?style=flat
.. image:: https://img.shields.io/badge/platform-ios-lightgrey.svg
.. image:: https://img.shields.io/badge/license-GNU-blue.svg


A collection of functions and extensions allowing more advance key-path magic in Swift.

Install
^^^^^^^

Installing the library is done via `CocoaPods <http://cocoapods.org/>`_:

You will need to modify your **Podfile** to add the library.

.. code-block:: shell

	use_frameworks!

	target 'MyProject' do
	  pod 'KeyPathTransformer'
	end

Import
^^^^^^

You can include the library into any file by adding the following line at the top of your .swift file:

.. code-block:: swift

	import KeyPathTransformer

Definitions
^^^^^^^^^^^

Using **KeyPathTransformer** you can perform more powerful key-path operations on dictionaries.
The simplest operations involve creating a **Transform** object and assigning or retrieving different values in it.

A Transform is similar to a classic swift NSDictionary or Dictionary<H,V> object, but has the advantage that
you can assign and select from it using key-path operators.

For example, this is valid syntax:

.. code-block:: swift

	transform["details.location.address"] = "11 Gwendwr Road"
	print(transform["employee.personalDetails.name"])

The main **Transform** is defined as a subclass of NSObject over a generic parameter

.. code-block:: swift

	public final class Transform <T>: NSObject

that defines:

* A constructor without parameters. You can only add values to this transform.

.. code-block:: swift

	public override init()

* A constructor with a source dictionary. You can add values to the transform and apply operations on the existing data. You can also specify if you want to add source values into the transformation result.

.. code-block:: swift

	public init(_ source: [String:T], copySourceIntoDest:Bool = false)

* A result function, that returns the final, transformed dictionary

.. code-block:: swift

	public func result() -> [String:AnyObject]

Examples: Assign
^^^^^^^^^^^^^^^^

A simple, complete example

.. code-block:: swift

	let transform = Transform<AnyObject>()

	transform["name"] = "John"
	transform["age"] = 23

	let result = transform.result() as NSDictionary

will have the following result:

.. code-block:: swift

	{
	  age = 23;
	  name = John;
	}

A more complex example

.. code-block:: swift

	let transform = Transform<AnyObject>()

	transform["name"] = "John Locke"
	transform["details.age"] = 23
	transform["details.birth"] = "11 Gwendwr Road"

	let result = transform.result() as NSDictionary

will have the following result:

.. code-block:: swift

	{
	  name = "John Locke";
	  details =     {
	    age = 23;
	    birth = "11 Gwendwr Road";
	  };
	}


Examples: Transform
^^^^^^^^^^^^^^^^^^^

To do a basic transform operation, assume you have the following dictionary:

.. code-block:: swift

	let source = [
	  "name": "John",
	  "address": "11 Gwendwr Road",
	  "age": 23
	]

and you want to transform it into something like this:

.. code-block:: swift

	let expected = [
	  "id": 3105,
	  "details": [
		"age": 23,
		"name": "John",
		"location": [
		  "address": "11 Gwendwr Road"
		]
	  ]
	] as NSDictionary

Then you'll need to define the following transform:

.. code-block:: swift

	let transform = Transform<AnyObject>(source)

	transform["id"] = 3105
	transform["details.name"] = transform["name"]
	transform["details.location.address"] = transform["address"]
	transform["details.age"] = transform["age"]

	let result = transform.result() as NSDictionary

Notice that the transform constructor gets **source** as a parameter, so that you can both add values:

.. code-block:: swift

	transform["id"] = 3105

but also transform values from the source dictionary into the new result dictionary:

.. code-block:: swift

	transform["details.location.address"] = transform["address"]

The => operator
^^^^^^^^^^^^^^^

The KeyPathTransformer library defines a special operator, **=>** , that's used to cycle through dictionary arrays and get values.

For example, assume the following dictionary

.. code-block:: swift

	let source = [
	  "name": "John Appleseed",
	  "working_hours": [
		"09:00",
		"17:00"
	  ]
	]

then you can use the **=>** operator as follows

.. code-block:: swift

	let transform = Transform<AnyObject>(source)
	transform["working_hours"] => { (i, hour: String) in
	  if (i == 0) {
		transform["start_hour"] = hour
	  } else {
		transform["end_hour"] = hour
	  }
	}

to obtain the resulting dictionary:

.. code-block:: swift

	{
	  "name" = "John Appleseed";
	  "start_hour" = "09:00";
	  "end_hour" = "17:00";
	}

Notice that the **=>** operator works on an existing transform / dictionary field, that needs to be an Array of some sort.

More complex transforms
^^^^^^^^^^^^^^^^^^^^^^^

If you find that the normal assignments, transforms or the **=>** operator are not enough, you can also use a more complex
assignment callback.

The most simple example is

.. code-block:: swift

	transform["name"] = {
	  return "John"
	} ()

But a more appropriate example would be when trying to transform the following source dictionary

.. code-block:: swift

	let source = [
	  "history":[
		[
		  "name":"St. Martin's College",
		  "dates":[
			"start":2008,
			"end":2011
		  ]
		],
		[
		  "name":"Columbia University",
		  "dates":[
		    "start":2011,
			"end":2015
		  ]
		]
	  ]
	]

into the destination

.. code-block:: swift

 	let destination = [
	  "education": [
		[
		  "school_name": "St. Martin's College",
		  "start_date": 2008,
		  "end_date": 2011
		],
		[
		  "school_name": "Columbia University",
		  "start_date": 2011,
		  "end_date": 2015
		]
	  ]
	]

which would be achieved by this transform:

.. code-block:: swift

	let transform = Transform<AnyObject>(source)

	transform["education"] = {

	  // create an array of dictionaries
	  var array: [[String:AnyObject]] = []

	  // when cycling over an array of dictionaries, KeyPathTransformer will
	  // know to return array elements as transforms, not dictionaries
	  transform["history"] => { (i, history:Transform<AnyObject>) in

		history["school_name"] = history["name"]
		history["start_date"] = history["dates.start"]
		history["end_date"] = history["dates.end"]

		array.append(history.result())

	  }

	  // finally - "education" will be an array of dictionaries
      return array
    }()

    let result = transform.result()

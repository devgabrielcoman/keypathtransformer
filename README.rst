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

* A constructor with a source dictionary. You can add values to the transform and apply operations on the existing data.
You can also specify if you want to add source values into the transformation result.

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
	print(result)

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
	print(result)

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

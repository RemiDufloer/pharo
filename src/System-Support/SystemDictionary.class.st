"
I represent a special dictionary used as global namespace for class names :

	Smalltalk globals classNames.

and for traits too:

	Smalltalk globals traitNames.
	
and a few other globals:

	(Smalltalk globals keys
		reject: [ :k | 
			| g |
			g := Smalltalk globals at: k.
			g isBehavior or: [ g isTrait ] ]) collect: [ :k | k -> (Smalltalk globals at: k) class ].

As the above example let you guess, the global namespace of Smalltalk system is accessed through:

	Smalltalk globals.
"
Class {
	#name : 'SystemDictionary',
	#superclass : 'IdentityDictionary',
	#instVars : [
		'cachedClassNames',
		'cachedNonClassNames',
		'cachedBehaviors',
		'pseudoVariables'
	],
	#category : 'System-Support-Utilities',
	#package : 'System-Support',
	#tag : 'Utilities'
}

{ #category : 'cleanup' }
SystemDictionary class >> cleanUp [

	Smalltalk globals flushClassNameCache
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allBehaviors [
	"Return all the classes and traits defined in the Smalltalk SystemDictionary"

	^ cachedBehaviors ifNil: [
		  cachedBehaviors := self allClassesAndTraits flatCollect: [ :each | { each. each classSide } ] ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allBehaviorsDo: aBlock [
	"Execute a block on each class, metaclass, trait and trait class"

	self allBehaviors do: aBlock
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allClasses [
	"Return all the class defines in the Smalltalk SystemDictionary"

	^ self classNames collect: [:name | self at: name ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allClassesAndTraits [
	"Return all the classes and traits defined in the Smalltalk SystemDictionary"

	^ self classAndTraitNames collect: [:each | self at: each ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allClassesAndTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each class and trait in the system."

	^self classAndTraitNames do: [:each | aBlock value: (self at: each) ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allClassesDo: aBlock [
	"Evaluate the argument, aBlock, for each class in the system."

	^self classNames do: [:name | aBlock value: (self at: name) ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allMethods [
	"all methods, including copies from Traits"
	^ self allBehaviors flatCollect: [ :behavior | behavior methods ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allTraits [
	"Return all traits defined in the Smalltalk SystemDictionary"

	^ self traitNames collect: [:each | self at: each ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> allTraitsDo: aBlock [
	"Evaluate the argument, aBlock, for each trait in the system."

	^ self traitNames do: [ :name | aBlock value: (self at: name) ]
]

{ #category : 'accessing - dictionary access' }
SystemDictionary >> at: aKey put: anObject [
	"Override from Dictionary to check Undeclared and fix up
	references to undeclared variables."
	| index assoc |
	aKey isSymbol ifFalse: [ self error: 'Only symbols are accepted as keys in SystemDictionary' ].
	((self includesKey: aKey) not and: [ self undeclaredRegistry includesKey: aKey ]) ifTrue: [
 			| undeclared |
 			undeclared := self undeclaredRegistry associationAt: aKey.
 			"Undeclared variables record using methods in a property, remove. Boostrap might have used Associations"
 			(undeclared class == UndeclaredVariable) ifTrue: [undeclared removeProperty: #registeredMethods ifAbsent: [ ]]. 
 			"and change class to be Global" 
 			self add: (undeclared primitiveChangeClassTo: GlobalVariable new).
 			self undeclaredRegistry removeKey: aKey].
 	"code of super at:put:, not using Associations but GlobalVariable"
 	index := self findElementOrNil: aKey.
 	assoc := array at: index.
 	assoc
 		ifNil: [self atNewIndex: index put: (GlobalVariable key: aKey value: anObject). self flushClassNameCache]
 		ifNotNil: [assoc value: anObject].
 	^ anObject
]

{ #category : 'adding' }
SystemDictionary >> atNewIndex: index put: aGlobalVariable [

	aGlobalVariable isAssociation ifTrue: [ self error: 'Only global variables should be added to the SystemDictionary and not associations.' ].
	^ super atNewIndex: index put: aGlobalVariable
]

{ #category : 'accessing - variable lookup' }
SystemDictionary >> bindingOf: varName [
	"SystemDictionaries includes symbols only"

	^ super bindingOf: varName asSymbol
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> classAndTraitNames [
	"Answer a sorted collection of all class and trait (not including class-traits) names.
	Now traits are normal classes. So they are in same class list.
	Do not bother to sort"

	^self classNames
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> classNamed: className [

	^ self classOrTraitNamed: className
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> classNames [
	"Answer a sorted collection of all class names. Use the return value of #fillCaches to avoid concurrency issues."

	^cachedClassNames ifNil: [ self fillCaches at: 1 ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> classOrTraitNamed: aString [
	"aString is either a class or trait name or a class or trait name followed by ' class' or 'classTrait'
	respectively. Answer the class or metaclass it names."

	| meta baseName |
	(aString endsWith: ' class')
		ifTrue: [
			meta := true.
			baseName := aString copyFrom: 1 to: aString size - 6 ]
		ifFalse: [
			(aString endsWith: ' classTrait')
				ifTrue: [
					meta := true.
					baseName := aString copyFrom: 1 to: aString size - 11 ]
				ifFalse: [
					meta := false.
					baseName := aString ] ].
	^ self at: baseName asSymbol ifPresent: [ :global |
		  (global isBehavior or: [ global isTrait ]) ifTrue: [
			  meta
				  ifFalse: [ global ]
				  ifTrue: [ global classSide ] ] ]
]

{ #category : 'accessing' }
SystemDictionary >> codeChangeAnnouncer [
	"A code change announcer is an announcer to register to Class, Method, Package and Protocol announcement."

	"This should not be hardcoded in the futurebut I should have my own instance."

	^ SystemAnnouncer uniqueInstance
]

{ #category : 'accessing' }
SystemDictionary >> codeSupportAnnouncer [
	"A code support announcer is an announcer used for tooling support such as the breakpoints or AST cache."

	"This should not be hardcoded in the futurebut I should have my own instance."

	^ SystemAnnouncer uniqueInstance
]

{ #category : 'accessing' }
SystemDictionary >> environment [
	"For conversion from SmalltalkImage to SystemDictionary"

	^ self
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> fillCaches [
	"Fill cachedClassNames and cachedNonClassNames. Return an array with the calculated values."

	| classNames nonClassNames |
	classNames := OrderedCollection new: self size.
	nonClassNames := OrderedCollection new.
	self keysAndValuesDo: [ :key :value |
		"The key == value name test below addresses two separate issues:
			1) Obsolete classes, where key = #Foo and value name = 'AnObsoleteFoo'
			2) Aliases, i.e., Smalltalk at: #OtherName put: aClass"
		((value isKindOf: (self class environment at: #Class)) and: [ key == value name ])
			ifTrue: [ classNames add: key ]
			ifFalse: [ nonClassNames add: key ] ].
		"The expression (self class environment at: #Class) deserves some explanation.
		For bootstrapping we need to have a different Class when executing value isKindOf: Class :
		In such expression Class represents a kind of fixed point: the class of the class of the system.
		When bootstrapping we want the class Class of the current kernel defined in the current namespace.
		Since the current namespace should contains the class that describes itself as well as a new Class class.
		we are done :)."


	"The cached names are sorted to allow for a very efficient hasBindingThatBeginsWith: check"
	cachedClassNames := classNames sort.
	cachedNonClassNames := nonClassNames sort.
	^{ classNames. nonClassNames }
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> flushClassNameCache [
	"Force recomputation of the cached list of class names and non-class names."

	<script: 'Smalltalk flushClassNameCache'>
	cachedClassNames := cachedNonClassNames := cachedBehaviors := nil
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> forgetClass: aClass [
	"Delete the class, aClass, from the system.
	Note that this doesn't do everything required to dispose of a class - to do that use Class>>removeFromSystem."

	self organization removeClass: aClass.
	self removeKey: aClass name ifAbsent: [  ]
]

{ #category : 'testing' }
SystemDictionary >> hasBindingThatBeginsWith: aString [
	"Use the cached class and non-class names for better performance."

	| name searchBlock |
	(self pseudoVariables hasBindingThatBeginsWith: aString) ifTrue: [
		^ true ].
	searchBlock := [ :element |
	               (element beginsWith: aString)
		               ifTrue: [ 0 ]
		               ifFalse: [
			               aString < element
				               ifTrue: [ -1 ]
				               ifFalse: [ 1 ] ] ].
	name := self classNames findBinary: searchBlock ifNone: [ nil ].
	name ifNotNil: [ ^ true ].
	name := self nonClassNames findBinary: searchBlock ifNone: [ nil ].
	^ name isNotNil
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> hasClassNamed: aString [
	"Answer whether there is a class of the given name, but don't intern aString if it's not already interned."

	Symbol
		hasInterned: aString
		ifTrue: [ :aSymbol | ^ (self at: aSymbol ifAbsent: [ nil ]) isClass ].
	^ false
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> hasClassOrTraitNamed: aString [
	"Answer whether there is a class of the given name, but don't intern aString if it's not already interned."

	Symbol
		hasInterned: aString
		ifTrue: [ :aSymbol |
		^ (self at: aSymbol ifAbsent: [ nil ]) isClassOrTrait ].
	^ false
]

{ #category : 'accessing - variable lookup' }
SystemDictionary >> lookupVar: name [
	"Return a var with this name.  Return nil if none found"
	^self pseudoVariables at: name ifAbsent: [self bindingOf: name]
]

{ #category : 'accessing - system attributes' }
SystemDictionary >> maxIdentityHash [
	"Answer the maximum identityHash value supported by the VM."
	<primitive: 176>

	^self primitiveFailed
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> methods [
	"all methods, but without those installed by Traits"
	^ self allBehaviors flatCollect: [ :behavior | behavior localMethods ]
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> nonClassNames [
	"Answer a sorted collection of all non-class names. Use the return value of #fillCaches to avoid concurrency issues."

	^ cachedNonClassNames ifNil: [ self fillCaches at: 2 ]
]

{ #category : 'accessing' }
SystemDictionary >> organization [
	"Return the organizer for the receiver"

	^ self at: #SystemOrganization ifAbsent: [
		  self organization: PackageOrganizer new.
		  self at: #SystemOrganization ]
]

{ #category : 'accessing' }
SystemDictionary >> organization: anOrganization [
	"Return the organizer for the receiver"

	anOrganization environment: self.
	^ self at: #SystemOrganization put: anOrganization
]

{ #category : 'accessing - variable lookup' }
SystemDictionary >> outerScope [

	^ nil
]

{ #category : 'accessing' }
SystemDictionary >> poolUsers [
	"Answer a dictionary of pool name -> classes that refer to it.
	Also includes any globally know dictionaries (such as
	Smalltalk, Undeclared etc) which although not strictly
	accurate is potentially useful information"

	<script: 'Smalltalk globals poolUsers inspect'>

	| poolUsers |
	poolUsers := Dictionary new.
	self
		keysDo: [ :k |
			| pool refs |
			(((pool := self at: k) isKindOf: Dictionary) or: [ pool isKindOf: SharedPool class ])
				ifTrue: [
					refs := self systemNavigation allClasses
						select: [ :c | c sharedPools identityIncludes: pool ]
						thenCollect: [ :c | c name ].
					refs add: (self systemNavigation allReferencesTo: (self associationAt: k)).
					poolUsers at: k put: refs ] ].
	^ poolUsers
]

{ #category : 'printing' }
SystemDictionary >> printElementsOn: aStream [

	aStream nextPutAll: '(lots of globals)'
]

{ #category : 'accessing - variable lookup' }
SystemDictionary >> pseudoVariables [
	"We cache the variables for speed"

	^ pseudoVariables ifNil: [
		  pseudoVariables := PseudoVariable lookupDictionary ]
]

{ #category : 'accessing - classes and traits' }
SystemDictionary >> removeClassNamed: aName [
	"Invoked from fileouts: if there is currently a class in the system named aName, then remove it"

	self
		at: aName asSymbol
		ifPresent: [ :oldClass | oldClass removeFromSystem ]
]

{ #category : 'removing' }
SystemDictionary >> removeFromCaches: aKey [
	"In case we remove a key from the system dictionary, we do not need to flush all the caches. We can just remove it from the class name and non class name caches."

	cachedClassNames ifNotNil: [ :cache | cache remove: aKey ifAbsent: [  ] ].
	cachedNonClassNames ifNotNil: [ :cache | cache remove: aKey ifAbsent: [  ] ].
	cachedBehaviors := nil
]

{ #category : 'accessing - dictionary access' }
SystemDictionary >> removeKey: key ifAbsent: aBlock [

	self removeFromCaches: key.
	^ super removeKey: key ifAbsent: aBlock
]

{ #category : 'renaming' }
SystemDictionary >> renameClass: aClass from: oldName [

	| oldref |
	oldref := self associationAt: oldName.
	self removeKey: oldName.
	oldref key: aClass name.
	self add: oldref. "Old association preserves old refs"
	self flushClassNameCache.
	self class codeChangeAnnouncer classRenamed: aClass from: oldName to: aClass name.
	aClass subclassesDo: [ :subclass | self class codeChangeAnnouncer classParentOf: subclass renamedFrom: oldName to: aClass name ]
]

{ #category : 'renaming' }
SystemDictionary >> renameClassNamed: oldName as: newName [
	"Invoked from fileouts: if there is currently a class in the system named oldName, then rename it to newName. If anything untoward happens, report it in the Transcript."

	| oldClass |
	(oldClass := self at: oldName asSymbol ifAbsent: [ nil ]) ifNil: [
		SystemNotification signal:
			'Class-rename for ' , oldName , ' ignored because ' , oldName
			, ' does not exist.'.
		^ self ].
	oldClass rename: newName
]

{ #category : 'accessing - variable lookup' }
SystemDictionary >> resetPseudoVariables [
	"Lazy init in the accessor, resetting it will take new subclasses on PseudoVariable into account"

	^ pseudoVariables := nil
]

{ #category : 'accessing - class and trait names' }
SystemDictionary >> traitNames [
	"Answer a SortedCollection of all traits (not including class-traits) names."

	^ self classNames select: [ :name |
		  self
			  at: name
			  ifPresent: [ :global |
			  global isTrait and: [ global isObsolete not ] ]
			  ifAbsent: [ false ] ]
]

{ #category : 'accessing' }
SystemDictionary >> undeclaredRegistry [
	"For now we are referencing a global variable of the default environment of Pharo. But in the future each environments should have their undeclared registry, else we have memory leaks of the environments."

	^ Undeclared
]

{ #category : 'copying' }
SystemDictionary >> veryDeepCopyWith: deepCopier [
	"Return self. I can't be copied. Do not record me."
]

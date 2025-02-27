"
An instance side #initialize method should call super initialize (as a first message) to allow to first run initializations provided by superclasses during instantiation.

This is a common practice and good style even for direct subclasses of Object (where typically nothing is initialized by default during instantiation). This can avoid later side effects when the class is moved under a different superclass during refactorings.
"
Class {
	#name : 'ReShouldSendSuperInitializeAsFirstMessage',
	#superclass : 'ReAbstractRule',
	#traits : 'ReTSUnitGroupedRule',
	#classTraits : 'ReTSUnitGroupedRule classTrait',
	#category : 'SUnit-Rules-Base',
	#package : 'SUnit-Rules',
	#tag : 'Base'
}

{ #category : 'testing - interest' }
ReShouldSendSuperInitializeAsFirstMessage class >> checksMethod [

	^ true
]

{ #category : 'utilities' }
ReShouldSendSuperInitializeAsFirstMessage class >> parseTreeSearcher [

	^ RBParseTreeSearcher new
]

{ #category : 'utilities' }
ReShouldSendSuperInitializeAsFirstMessage class >> superInitializeNotCalledFirstIn: aCompiledMethod [
	"Return true if the method is an instance side initialize method and a call to super initialize is not the first message send."

	| searcher |
	aCompiledMethod isClassSide ifTrue: [ ^ false ].
	searcher := self parseTreeSearcher
		matchesAnyMethodOf:
			#('initialize             super initialize. `.@any' 'initialize | `@temps | super initialize. `.@any')
			do: [ :node :answer | true ];
		yourself.
	^ (searcher
		executeTree: aCompiledMethod ast
		initialAnswer: false) not
]

{ #category : 'running' }
ReShouldSendSuperInitializeAsFirstMessage >> basicCheck: aMethod [

	^ (aMethod isClassSide not) and: [ aMethod selector = #initialize and: [ self class superInitializeNotCalledFirstIn: aMethod ] ]
]

{ #category : 'accessing' }
ReShouldSendSuperInitializeAsFirstMessage >> group [

	^ 'Clean Code'
]

{ #category : 'accessing' }
ReShouldSendSuperInitializeAsFirstMessage >> name [

	^ 'Provide a call to super initialize as the first message in the instance side #initialize method'
]

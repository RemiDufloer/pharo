"
I am a transformation for moving a method from the class to one of its instance variable objects.

Moving a method moves it implementation to one or more classes and replaces the implementation in the original method by a delegation to one of the classes instance variable. 

I expect an option for selecting the type (classes) to which this method should be added.
A role typer RBRefactoryTyper is used to guess the possible classes used for this instance variables.
And an option for requesting the new method selector.

For all selected classes a method implementing the original method is created, and if the original code uses some references to self, a parameter needs to be added to provided the former implementor.

Usage:
| transformation |
transformation := (RBMoveMethodTransformation
				selector: aSelector
				class: aClass
				variable: aVariable)
				transform.
				
For example, moving the method #isBlack from class Color to its instvar #rgb for the type ""Integer"" creates a method 


```
Integer>>#isBlack
 ^ self = 0
```
and changes Colors implementation from: 
```
Color>>#isBlack
   ^ rgb = 0
```

to:

``` 
Color>>#isBlack
   ^ rgb isBlack
```
"
Class {
	#name : 'RBMoveMethodTransformation',
	#superclass : 'RBMethodTransformation',
	#instVars : [
		'variable',
		'moveToClasses',
		'parseTree',
		'hasOnlySelfReturns',
		'selfVariableName'
	],
	#category : 'Refactoring-Transformations-Model-Unused',
	#package : 'Refactoring-Transformations',
	#tag : 'Model-Unused'
}

{ #category : 'instance creation' }
RBMoveMethodTransformation class >> model: aRBSmalltalk selector: aSymbol class: aClass variable: aVariableName [
	^ self new
		model: aRBSmalltalk;
		selector: aSymbol class: aClass variable: aVariableName;
		yourself
]

{ #category : 'instance creation' }
RBMoveMethodTransformation class >> selector: aSymbol class: aClass variable: aVariableName [
	^ self new
		selector: aSymbol class: aClass variable: aVariableName;
		yourself
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> abstractVariables [

	self generateChangesFor: self abstractVariablesRefactoring.
	parseTree := self abstractVariablesRefactoring parseTree
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> abstractVariablesRefactoring [
	^RBAbstractVariablesTransformation
		model: self model
		abstractVariablesIn: parseTree
		from: class
		toAll: moveToClasses
		ignoring: variable
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> addSelfReturn [
	self hasOnlySelfReturns ifTrue: [^self].
	parseTree addSelfReturn
]

{ #category : 'preconditions' }
RBMoveMethodTransformation >> applicabilityPreconditions [

	^ {
		  (RBCondition definesSelector: selector in: class).
		  (RBCondition withBlock: [
			   self buildParseTree.
			   self checkForPrimitiveMethod.
			   self checkForSuperReferences.
			   self checkAssignmentsToVariable.
			   self getClassesToMoveTo.
			   self getArgumentNameForSelf.
			   self checkTemporaryVariableNames.
			   self getNewMethodName.
			   true ]) }
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> buildParseTree [

	parseTree := ( class parseTreeForSelector: selector ) copy.
	parseTree ifNil: [ self refactoringError: 'Could not parse method' ].
	parseTree doSemanticAnalysis
]

{ #category : 'testing' }
RBMoveMethodTransformation >> canReferenceVariable: aString in: aClass [
	(aClass definesVariable: aString) ifTrue: [^true].
	(self model includesGlobal: aString asSymbol) ifTrue: [^true].
	^(self poolVariableNamesFor: aClass) includes: aString
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> checkAssignmentsToVariable [
	| searcher |
	variable
		ifNotNil: [ searcher := self parseTreeSearcher.
			searcher
				matches: variable , ' := `@object'
				do: [ :aNode :answer | true ].
			(searcher executeTree: parseTree initialAnswer: false)
				ifTrue: [ self
						refactoringError:
							('Cannot move the method into <1s> since it is assigned'
								expandMacrosWith: variable) ] ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> checkForPrimitiveMethod [
	parseTree isPrimitive
		ifTrue: [self refactoringError: 'Cannot move primitive methods']
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> checkForSuperReferences [
	| searcher |
	searcher := self parseTreeSearcher.
	searcher
		matches: 'super `@message: `@args'
		do: [ :aNode :answer | true ].
	(searcher executeTree: parseTree initialAnswer: false)
		ifTrue: [ self
				refactoringError: 'Cannot move the method since it has a super message send.' ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> checkTemporaryVariableNames [
	| varNames |
	varNames := parseTree allDefinedVariables.
	selfVariableName ifNotNil: [varNames add: selfVariableName].
	varNames do:
			[:name |
			moveToClasses do:
					[:each |
					(self canReferenceVariable: name in: each)
						ifTrue:
							[self refactoringError: ('<1p> already defines a variable called <2s>'
										expandMacrosWith: each
										with: name)]]]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> compileDelegatorMethod [
	| statementNode delegatorNode tree |
	delegatorNode := RBMessageNode
		                 receiver: (RBVariableNode named: variable)
		                 selector: parseTree selector
		                 keywordsPositions: parseTree keywordsPositions
		                 arguments: (parseTree argumentNames collect: [ :each |
				                  each = selfVariableName
					                  ifTrue: [ RBVariableNode selfNode ]
					                  ifFalse: [ RBVariableNode named: each ] ]).
	self hasOnlySelfReturns ifFalse: [ delegatorNode := RBReturnNode value: delegatorNode ].
	statementNode := RBSequenceNode temporaries: #(  ) statements: (Array with: delegatorNode).
	(tree := class parseTreeForSelector: selector) body: statementNode.
	class compileTree: tree
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> compileNewMethods [
	moveToClasses
		do: [:each | each compile: parseTree newSource withAttributesFrom: (class methodFor: selector)]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getArgumentNameForSelf [
	self needsToReplaceSelfReferences ifFalse: [^self].

	[selfVariableName := self requestSelfArgumentName.
	(self checkInstanceVariableName: selfVariableName in: class)
		ifTrue:
			[self verifyTemporaryVariableDoesNotOverride
				ifFalse:
					[self
						refactoringWarning: 'The variable is already defined in one of the classes you''re moving the method to.<n>Try another?'
								expandMacros.
					selfVariableName := nil]]
		ifFalse:
			[self
				refactoringWarning: 'The variable name is not a valid Smalltalk temporary variable name<n>Try again?'
						expandMacros.
			selfVariableName := nil].
	selfVariableName isNil]
			whileTrue: []
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getClassForGlobalOrClassVariable [
	| definingClass type |
	definingClass := class whoDefinesClassVariable: (variable ifNil: ['']).
	definingClass ifNil: [
			type := (self model classNamed: variable)
				ifNotNil: [ :cls | cls classSide ]
				ifNil: [ self model classNamed: #Object ] ]
		ifNotNil: [ type := definingClass typeOfClassVariable: variable ].
	moveToClasses := self selectVariableTypesFrom: (Array with: type) selected: (Array with: type).
	moveToClasses ifNil: [ self refactoringError: 'Method not moved' ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getClassesForInstanceVariable [

	| definingClass typer types |

	definingClass := class whoDefinesInstanceVariable: variable.
	typer := RBRefactoryTyper newFor: self model.
	typer runOn: definingClass.
	types := typer typesFor: variable.
	types ifEmpty: [ types := OrderedCollection with: ( self model classNamed: #Object ) ].
	moveToClasses := self selectVariableTypesFrom: types selected: ( typer guessTypesFor: variable ).
	moveToClasses ifNil: [ self refactoringError: 'Method not moved' ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getClassesForTemporaryVariable [

	| types |

	types := RBRefactoryTyper typesFor: variable in: parseTree model: self model.
	types ifEmpty: [ types := OrderedCollection with: ( self model classNamed: #Object ) ].
	moveToClasses := self selectVariableTypesFrom: types selected: types.
	moveToClasses ifNil: [ self refactoringError: 'Method not moved' ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getClassesToMoveTo [
	self isMovingToArgument
		ifTrue: [self getClassesForTemporaryVariable]
		ifFalse:
			[self isMovingToInstVar
				ifTrue: [self getClassesForInstanceVariable]
				ifFalse: [self getClassForGlobalOrClassVariable]].
	moveToClasses ifEmpty: [self refactoringError: 'No classes selected, method not moved.']
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> getNewMethodName [

	| newSelector parameters alreadyDefined methodName newMethodName |

	self removeArgument.
	parameters := parseTree argumentNames asOrderedCollection.	"parameters remove: variable ifAbsent: []."
	self needsToReplaceSelfReferences
		ifTrue: [ parameters add: selfVariableName ].
	methodName := RBMethodName
		selector: ( self uniqueMethodNameFor: parameters size )
		arguments: parameters.

	[ newMethodName := self requestMethodNameFor: methodName.
	newMethodName ifNil: [ self refactoringError: 'Did not move method' ].
	newMethodName isValid
		ifTrue: [ newSelector := newMethodName selector ]
		ifFalse: [ self refactoringWarning: 'Invalid method name' ].
	parameters := newMethodName arguments.
	( self checkMethodName: newSelector in: class )
		ifFalse: [ self refactoringWarning: newSelector , ' is not a valid selector name.'.
			newSelector := nil
			].
	alreadyDefined := moveToClasses
		detect: [ :each | each hierarchyDefinesMethod: newSelector ]
		ifNone: [ nil ].
	alreadyDefined ifNotNil: [ self
				refactoringWarning:
					( '<1s> is already defined by <2p> or a super/subclass<n>Try another?'
						expandMacrosWith: newSelector
						with: alreadyDefined ).
			newSelector := nil
			].
	newSelector isNil
	] whileTrue: [  ].
	parseTree
		renameSelector: newSelector
		andArguments: ( parameters collect: [ :each | RBVariableNode named: each ] ) asArray
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> hasOnlySelfReturns [

	^ hasOnlySelfReturns
		ifNil: [ | searcher |

			searcher := self parseTreeSearcher.
			searcher
				matches: '^self' do: [ :aNode :answer | answer ];
				matches: '^`@object' do: [ :aNode :answer | false ].
			hasOnlySelfReturns := searcher executeTree: parseTree initialAnswer: true
			]
		ifNotNil: [ hasOnlySelfReturns ]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> hasSelfReferences [
	| searcher |
	searcher := self parseTreeSearcher.
	searcher matches: 'self' do: [ :aNode :answer | true ].
	self hasOnlySelfReturns
		ifTrue: [ searcher matches: '^self' do: [ :aNode :answer | answer ] ].
	^ searcher executeTree: parseTree initialAnswer: false
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> isMovingToArgument [
	^(parseTree arguments collect: [:each | each name]) includes: variable
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> isMovingToInstVar [
	^self isMovingToArgument not
		and: [(class whoDefinesInstanceVariable: variable) isNotNil]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> needsToReplaceSelfReferences [
	^self hasSelfReferences
		or: [self abstractVariablesRefactoring hasVariablesToAbstract]
]

{ #category : 'executing' }
RBMoveMethodTransformation >> privateTransform [
	self
		abstractVariables;
		addSelfReturn;
		replaceSelfReferences;
		replaceVariableReferences;
		compileNewMethods;
		compileDelegatorMethod
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> removeArgument [
	"Removes the excess argument if any.
	This argument is the variable which is
	referenced by self in the classes the
	method is moved to. "
	| removeIndex |
	removeIndex := parseTree argumentNames indexOf: variable.
	removeIndex = 0 ifFalse:
		[parseTree
			selector: ('' join: ((parseTree selector keywords asOrderedCollection)
									removeAt: removeIndex; yourself)) asSymbol
			keywordsPositions: ((parseTree keywordsPositions asOrderedCollection)
									removeAt: removeIndex; yourself) asIntegerArray
			arguments: ((parseTree arguments asOrderedCollection)
									removeAt: removeIndex; yourself) asArray]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> replaceSelfReferences [
	| replacer |
	self needsToReplaceSelfReferences ifTrue: [
		replacer := self parseTreeRewriter.
		replacer replace: 'self' with: selfVariableName.
		self hasOnlySelfReturns ifTrue:
			[replacer replace: '^self' with: '^self'].
		replacer executeTree: parseTree.
		parseTree := replacer tree]
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> replaceVariableReferences [
	| replacer |
	replacer := self parseTreeRewriter.
	replacer replace: variable with: 'self'.
	replacer executeTree: parseTree.
	parseTree := replacer tree
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> selector: aSymbol class: aClass variable: aVariableName [
	selector := aSymbol.
	class := self model classObjectFor: aClass.
	variable := aVariableName
]

{ #category : 'storing' }
RBMoveMethodTransformation >> storeOn: aStream [
	aStream nextPut: $(.
	self class storeOn: aStream.
	aStream
		nextPutAll: ' selector: #';
		nextPutAll: selector;
		nextPutAll: ' class: '.
	class storeOn: aStream.
	aStream
		nextPutAll: ' variable: ''';
		nextPutAll: variable;
		nextPutAll: ''')'
]

{ #category : 'private' }
RBMoveMethodTransformation >> uniqueMethodNameFor: anInteger [
	| before after index name |
	before := 'a'.
	after := ''.
	anInteger timesRepeat: [after := after , 'z:'].
	index := 0.

	[name := before , index printString , after.
	(Symbol findInterned: name) isNotNil]
			whileTrue: [index := index + 1].
	^name asSymbol
]

{ #category : 'transforming' }
RBMoveMethodTransformation >> verifyTemporaryVariableDoesNotOverride [
	(parseTree allDefinedVariables includes: selfVariableName)
		ifTrue: [ ^ false ].
	^ moveToClasses
		noneSatisfy: [ :each | each definesVariable: selfVariableName ]
]

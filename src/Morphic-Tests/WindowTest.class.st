Class {
	#name : #WindowTest,
	#superclass : #TestCase,
	#instVars : [
		'window'
	],
	#category : #'Morphic-Tests'
}

{ #category : #running }
WindowTest >> setUp [
	super setUp.
	
	window := Window newWindow: Morph new manageBy: WindowManager new.
]

{ #category : #tests }
WindowTest >> testMaximizeWindow [

	window open .
	window maximize .
	
	self assert: window isMaximized equals: true  .
]

{ #category : #tests }
WindowTest >> testMinimizeWindow [

	window open .
	
	window minimize .
	
	self assert: window isNotMinimized  equals: true  .
]

{ #category : #tests }
WindowTest >> testNewWindowDefaultsIsNotMaximize [

	window open .
	
	self assert: window isMaximized equals: false .
]

{ #category : #tests }
WindowTest >> testNewWindowDefaultsIsNotMinimized [

	window open .
	
	self assert: window isNotMinimized equals: true  .
]

{ #category : #tests }
WindowTest >> testRestoreWindow [

	window open .
	window restore .
	
	self assert: window isNotRestored  equals: false  .
]

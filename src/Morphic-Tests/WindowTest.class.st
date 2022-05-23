Class {
	#name : #WindowTest,
	#superclass : #AbstractWindowManagerTest,
	#instVars : [
		'window'
	],
	#category : #'Morphic-Tests'
}

{ #category : #running }
WindowTest >> setUp [

	super setUp.

	window := manager newWindowWithRoot: Morph new
]

{ #category : #tests }
WindowTest >> testMaximizeWindow [

	window open.
	window maximize.

	self assert: window isMaximized equals: true
]

{ #category : #tests }
WindowTest >> testMinimizeWindow [

	window open.

	window minimize.

	self assert: window isMinimized
]

{ #category : #tests }
WindowTest >> testNewWindowDefaultsIsNotMaximize [

	window open .
	
	self assert: window isMaximized equals: false .
]

{ #category : #tests }
WindowTest >> testNewWindowDefaultsIsNotMinimized [

	window open.

	self assert: window isNotMinimized
]

{ #category : #tests }
WindowTest >> testRestoreWindow [

	window open .
	window restore .
	
	self assert: window isNotRestored  equals: false  .
]

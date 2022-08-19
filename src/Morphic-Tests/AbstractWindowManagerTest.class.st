Class {
	#name : #AbstractWindowManagerTest,
	#superclass : #TestCase,
	#instVars : [
		'manager'
	],
	#category : #'Morphic-Tests'
}

{ #category : #running }
AbstractWindowManagerTest >> setUp [
	super setUp.
	manager := WindowManager new.
	
]

{ #category : #tests }
AbstractWindowManagerTest >> tearDown [ 

	manager ensureDeleteAll.
	super tearDown

	
]

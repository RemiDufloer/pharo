"
I represent a litlle world for an other window open out of the pharo window

I create a new world and i know my render, my state and my root.

    Instance Variables
	root:		MorphicRoot
	state:		WorldState
	submorph:		morphe
	worldRendered:		worldrendered


    Implementation Points
"
Class {
	#name : #MiniWorld,
	#superclass : #Morph,
	#instVars : [
		'worldRendered',
		'state',
		'root',
		'backgroundMorph'
	],
	#category : #'Morphic-Base'
}

{ #category : #'instance creation' }
MiniWorld class >> new: aObject [

	| world |
	world := self new.
	world root: aObject.
	^ world
]

{ #category : #structure }
MiniWorld >> activeHand [
	
	^ self worldState activeHand
]

{ #category : #stepping }
MiniWorld >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	"Add a new alarm with the given set of parameters"
	root addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime.
]

{ #category : #accessing }
MiniWorld >> addSubmorphs: aMorph [

	aMorph hResizing: #spaceFill.
	aMorph vResizing: #shrinkWrap.
	submorphs add: aMorph
]

{ #category : #'world simulation' }
MiniWorld >> backgroundMorph [

	^ backgroundMorph
]

{ #category : #'submorphs - add/remove' }
MiniWorld >> beCursorOwner [
]

{ #category : #initialization }
MiniWorld >> becomeActiveDuring: aBlock [
	
	aBlock value
]

{ #category : #'submorphs - add/remove' }
MiniWorld >> delete [
	self worldState worldRenderer deactivate.
]

{ #category : #'world state' }
MiniWorld >> displayWorld [

	state displayWorld: self .
]

{ #category : #'world simulation' }
MiniWorld >> fullRepaintNeeded [

	self worldState doFullRepaint.
]

{ #category : #'world simulation' }
MiniWorld >> handsDo: aBlock [

	^ self worldState handsDo: aBlock
]

{ #category : #accessing }
MiniWorld >> initialize [

	super initialize.
	submorphs := OrderedCollection new.
	worldRendered := OSWorldRenderer forWorld: self.
	state := WorldState  new.
	self layoutPolicy: StackLayout new.
	self hResizing: #spaceFill.
	self vResizing: #shrinkWrap.
]

{ #category : #'world simulation' }
MiniWorld >> open [

	self worldState worldRenderer: ((OSWorldRenderer forWorld: self)
		windowCloseAction: [self delete ]).
	self changed.
]

{ #category : #'world simulation' }
MiniWorld >> removeAlarm: aSelector for: aTarget [
	
	^ root removeAlarm: aSelector for: aTarget
]

{ #category : #'world simulation' }
MiniWorld >> resizeBackgroundMorph [

	" maybe not need"
	
	self backgroundMorph ifNotNil: [ self backgroundMorph extent: self extent ]
]

{ #category : #'world simulation' }
MiniWorld >> restoreMorphicDisplay [

	^ self worldRenderer restoreMorphicDisplay 
]

{ #category : #accessing }
MiniWorld >> root [

	^ root
]

{ #category : #accessing }
MiniWorld >> root: aObject [

	root := aObject .
]

{ #category : #'world simulation' }
MiniWorld >> startStepping: aMorph [

	self 
		startStepping: aMorph 
		at: Time millisecondClockValue 
		selector: #stepAt: 
		arguments: nil 
		stepTime: nil
]

{ #category : #stepping }
MiniWorld >> startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime [

	state
		startStepping: aMorph
		at: scheduledTime
		selector: aSelector
		arguments: args
		stepTime: stepTime
]

{ #category : #stepping }
MiniWorld >> stopStepping: aMorph [

	state stopStepping: aMorph
]

{ #category : #stepping }
MiniWorld >> stopStepping: aMorph selector: aSelector [

	state stopStepping: aMorph selector: aSelector
]

{ #category : #'world simulation' }
MiniWorld >> viewBox [

	^ self worldRenderer viewBox
]

{ #category : #'world simulation' }
MiniWorld >> viewBox: newViewBox [
	"I am now displayed within newViewBox; react."

	(self viewBox isNil or: [ self viewBox extent ~= newViewBox extent ])
		ifTrue: [ self worldState invalidate ].

	self position: newViewBox topLeft.
	fullBounds := bounds := newViewBox.
	self worldState handsDo: [ :hand | hand releaseKeyboardFocus ].
	self worldState doFullRepaint.
]

{ #category : #accessing }
MiniWorld >> world [

	^ self
]

{ #category : #accessing }
MiniWorld >> worldRenderer [ 

	^ worldRendered 
]

{ #category : #accessing }
MiniWorld >> worldState [

	^ state
]

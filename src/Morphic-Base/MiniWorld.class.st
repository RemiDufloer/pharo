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
	
	^ state activeHand
]

{ #category : #stepping }
MiniWorld >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	"Add a new alarm with the given set of parameters"
	state addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime.
]

{ #category : #'API - opening' }
MiniWorld >> addHand: aHandMorph [
	"Add the given hand to the list of hands for this world."

	aHandMorph owner ifNotNil: [ aHandMorph owner removeHand: aHandMorph ].
	state addHand: aHandMorph.
	aHandMorph privateOwner: self.
	^ aHandMorph
]

{ #category : #accessing }
MiniWorld >> addSubmorphs: aMorph [

	aMorph hResizing: #spaceFill.
	aMorph vResizing: #shrinkWrap.
	submorphs add: aMorph
]

{ #category : #background }
MiniWorld >> backgroundMorph [
	"Answer the background morph if any."
	
	^backgroundMorph
]

{ #category : #background }
MiniWorld >> backgroundMorph: aMorph [

	"Set the background morph.
	Probably best if locked prior to adding."

	self backgroundMorph ifNotNil: [ self backgroundMorph delete ].
	backgroundMorph := aMorph.
	aMorph
		ifNotNil: [ aMorph bounds: self bounds.
			self addMorphBack: aMorph
			]
]

{ #category : #cursor }
MiniWorld >> beCursorOwner [
	
]

{ #category : #initialization }
MiniWorld >> becomeActiveDuring: aBlock [
	
	aBlock value
]

{ #category : #'world state' }
MiniWorld >> currentCursor [
	^ state currentCursor
]

{ #category : #accessing }
MiniWorld >> currentCursor: aCursor [
	^ state currentCursor: aCursor
]

{ #category : #'world state' }
MiniWorld >> displayWorld [

	state displayWorld: self .
]

{ #category : #display }
MiniWorld >> fullRepaintNeeded [

	state doFullRepaint.
	self windowsSatisfying: [:w | w makeMeVisible. false]
]

{ #category : #'world state' }
MiniWorld >> handsDo: aBlock [

	^  state handsDo: aBlock
]

{ #category : #accessing }
MiniWorld >> initialize [

	super initialize.
	submorphs := OrderedCollection new.
	worldRendered := MorphicRootRenderer new: self.
	state := WorldState  new.
	self layoutPolicy: StackLayout new.
	self hResizing: #spaceFill.
	self vResizing: #shrinkWrap.
]

{ #category : #'API - opening' }
MiniWorld >> open [
	worldRendered:= OSWorldRenderer forWorld: self.
	self worldState worldRenderer: ((worldRendered)
		windowCloseAction: [self worldRenderer deactivate. ]).
	self changed.
	state activeHand: (self addHand: HandMorph new).
	 
	
]

{ #category : #'world simulation' }
MiniWorld >> removeAlarm: aSelector for: aTarget [
	
	^ state removeAlarm: aSelector for: aTarget
]

{ #category : #display }
MiniWorld >> resizeBackgroundMorph [

	"Resize the background morph to fit the world."

	self backgroundMorph ifNotNil: [ self backgroundMorph extent: self extent ]
]

{ #category : #display }
MiniWorld >> restoreMorphicDisplay [

	state worldRenderer restoreMorphicDisplay
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

{ #category : #'world state' }
MiniWorld >> viewBox: newViewBox [
	"I am now displayed within newViewBox; react."

	(self viewBox isNil or: [ self viewBox extent ~= newViewBox extent ])
		ifTrue: [ state invalidate ].

	self position: newViewBox topLeft.
	fullBounds := bounds := newViewBox.
	
	state handsDo: [ :hand | hand releaseKeyboardFocus ].
	self fullRepaintNeeded
]

{ #category : #'world state' }
MiniWorld >> windowsSatisfying: windowBlock [

	| windows |
	windows := OrderedCollection new.
	self submorphs do: [:m | 
		m embeddedWindowOrNil ifNotNil: [ 
			(windowBlock value: m) 
				ifTrue: [ windows addLast: m ] ] ].
		
	^ windows.
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

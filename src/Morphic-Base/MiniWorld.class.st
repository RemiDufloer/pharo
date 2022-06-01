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

{ #category : #'initialize-release' }
MiniWorld class >> doOneCycle [

	WorldState doDrawCycleWith: [ 
		| extraWorldsToDraw |
		extraWorldsToDraw := WorldMorph extraWorldListMutex  critical: [ 
			                     WorldMorph  extraWorldList ].
		extraWorldsToDraw do: [ :world | world doOneCycle ].

		(self currentWorld isNotNil and: [ 
			 (extraWorldsToDraw includes: self currentWorld) not ]) ifTrue: [ 
			self currentWorld doOneCycle ] ]
]

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

	state
		addAlarm: aSelector
		withArguments: argArray
		for: aTarget
		at: scheduledTime
]

{ #category : #'API - opening' }
MiniWorld >> addHand: aHandMorph [

	"Add the given hand to the list of hands for this world."

	aHandMorph owner ifNotNil: [ aHandMorph owner removeHand: aHandMorph ].
	state addHand: aHandMorph.
	aHandMorph privateOwner: self.
	^ aHandMorph
]

{ #category : #'submorphs - add/remove' }
MiniWorld >> addMorph: aMorph [

	"I will be the owner (and I will act as a world)"
	aMorph privateOwner: self.
	
	"check for the need of steppiong stepping"
	aMorph wantsSteps ifTrue: [ self  startStepping: aMorph ].

	self addSubmorphs: aMorph	.
]

{ #category : #'world state' }
MiniWorld >> addMorphFront: aMorph [

	^ self addMorphInFrontOfLayer: aMorph
]

{ #category : #'submorphs - add/remove' }
MiniWorld >> addMorphInFrontOfLayer: aMorph [

	"I will be the owner (and I will act as a world)"
	aMorph privateOwner: self.

	"check for the need of steppiong stepping"
	aMorph wantsSteps ifTrue: [ self  startStepping: aMorph ].

	submorphs addFirst: aMorph
]

{ #category : #accessing }
MiniWorld >> addSubmorphs: aMorph [

	"aMorph hResizing: #spaceFill.
	aMorph vResizing: #shrinkWrap."

	submorphs add: aMorph
]

{ #category : #background }
MiniWorld >> backgroundMorph [

	"Answer the background morph if any."

	^ backgroundMorph
]

{ #category : #background }
MiniWorld >> backgroundMorph: aMorph [

	"Set the background morph.
	Probably best if locked prior to adding."

	self backgroundMorph ifNotNil: [ self backgroundMorph delete ].
	backgroundMorph := aMorph.
	aMorph ifNotNil: [ 
		aMorph bounds: self bounds.
		self addMorphBack: aMorph ]
]

{ #category : #cursor }
MiniWorld >> beCursorOwner [
	"nil actually"
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

{ #category : #'submorphs - add/remove' }
MiniWorld >> delete [

	self worldState worldRenderer deactivate.
	WorldMorph removeExtraWorld: self.
]

{ #category : #settings }
MiniWorld >> displayScaleFactor [

	^ WorldMorph displayScaleFactor
]

{ #category : #display }
MiniWorld >> displayWorld [

	state displayWorld: self .
	self fullRepaintNeeded

]

{ #category : #state }
MiniWorld >> displayWorldSafely [

	state displayWorldSafely: self
]

{ #category : #display }
MiniWorld >> doOneCycle [

	self doOneCycleNow
]

{ #category : #display }
MiniWorld >> doOneCycleNow [

	"see the comment in doOneCycleNowFor:"

	state doOneCycleFor: self
]

{ #category : #display }
MiniWorld >> fullRepaintNeeded [

	state doFullRepaint.
	self windowsSatisfying: [ :w | 
		w makeMeVisible.
		false ]
]

{ #category : #'world state' }
MiniWorld >> handsDo: aBlock [

	^ state handsDo: aBlock
]

{ #category : #accessing }
MiniWorld >> initialize [

	super initialize.
	submorphs := OrderedCollection new.
	worldRendered := MorphicRootRenderer new: self.
	state := WorldState new.
	self layoutPolicy: StackLayout new.
	self color: Color veryLightGray
]

{ #category : #'API - opening' }
MiniWorld >> open [

	worldRendered := OSWorldRenderer forWorld: self.
	self worldState worldRenderer:
		(worldRendered windowCloseAction: [ self worldRenderer deactivate ]).
	state activeHand: (self addHand: HandMorph new).
	WorldMorph addExtraWorld: self
]

{ #category : #'world simulation' }
MiniWorld >> removeAlarm: aSelector for: aTarget [

	^ state removeAlarm: aSelector for: aTarget
]

{ #category : #display }
MiniWorld >> resizeBackgroundMorph [

	"Resize the background morph to fit the world."

	self backgroundMorph ifNotNil: [ 
		self backgroundMorph extent: self extent ]
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

{ #category : #stepping }
MiniWorld >> runLocalStepMethods [
	1haltOnce.
	state runLocalStepMethodsIn: self
]

{ #category : #'submorphs - add/remove' }
MiniWorld >> runStepMethods [

	state runStepMethodsIn: self
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
MiniWorld >> step [
	owner ifNotNil: [ ^ self runLocalStepMethods ].
	^ super step
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
	self submorphs do: [ :m | 
		m embeddedWindowOrNil ifNotNil: [ 
			(windowBlock value: m) ifTrue: [ windows addLast: m ] ] ].

	^ windows
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

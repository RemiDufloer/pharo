"
I represent root for all gtk morph.

I know my world my renderer and my state. All Gtk morph know me. If a Gtk morph need information for the world he ask me and me ask the world.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	activeHand:			<Object>
	container:			<Object>
	damageRecorder:		<Object>
	lastRequestedSize:	<Object>
	layeredMorphs:		<Object>
	morph:					<Object>
	morphResizable:		<Object>
	steps:					<Object>


    Implementation Points
"
Class {
	#name : #MorphicRoot,
	#superclass : #Object,
	#instVars : [
		'morph',
		'steps',
		'morphResizable',
		'lastRequestedSize',
		'damageRecorder',
		'container',
		'layeredMorphs',
		'activeHand',
		'miniWorld'
	],
	#category : #'Morphic-Base'
}

{ #category : #'world simulation' }
MorphicRoot >> activeHand [
	
	^ activeHand ifNil: [ 
		  activeHand := HandMorph new
			                privateOwner: self 	;
			                yourself ]		
]

{ #category : #'world simulation' }
MorphicRoot >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	
	^ container   addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime
]

{ #category : #'world simulation' }
MorphicRoot >> addMorphFront: aMorph [
	
	self addMorphInFrontOfLayer: aMorph
]

{ #category : #'world simulation' }
MorphicRoot >> addMorphInFrontOfLayer: aMorph [

	
	layeredMorphs add: aMorph.
	aMorph privateOwner: self.
	self invalidateRect: aMorph fullBounds
]

{ #category : #'world simulation' }
MorphicRoot >> beCursorOwner [
	
]

{ #category : #accessing }
MorphicRoot >> beMorphNotResizable [

	self morphResizable: false
]

{ #category : #'as yet unclassified' }
MorphicRoot >> beMorphResizable [

	self morphResizable: true
]

{ #category : #'world simulation' }
MorphicRoot >> bounds [ 

	^ self morph bounds
]

{ #category : #accessing }
MorphicRoot >> container: aGtkMorphView [ 
	container := aGtkMorphView
]

{ #category : #'world simulation' }
MorphicRoot >> convertWindowMouseEventPosition: aPoint [ 
	
	^ aPoint
]

{ #category : #'world simulation' }
MorphicRoot >> defer: aBlock [

	container defer:aBlock
]

{ #category : #'world simulation' }
MorphicRoot >> destroy [
	self stopStepping
]

{ #category : #private }
MorphicRoot >> extent: extent [

	lastRequestedSize := extent.
	self morph extent: extent
]

{ #category : #initialization }
MorphicRoot >> initialize [ 

miniWorld := MiniWorld new: self.
damageRecorder := DamageRecorder new.	
layeredMorphs := OrderedCollection new: 1.
]

{ #category : #private }
MorphicRoot >> intersectingMorphs: aMorph within: aRect [
	| morphs |
	
	aMorph fullBounds = aRect
		ifTrue: [ ^ { aMorph } ].
	morphs := OrderedCollection new.
	aMorph submorphsDo: [ :submorph | | bounds |
		bounds := submorph fullBounds.
		(bounds intersects: aRect) ifTrue: [
			((bounds ~= aRect) and: [ bounds containsRect: aRect ])
				ifTrue: [ morphs addAll: (self intersectingMorphs: submorph within: aRect) ]
				ifFalse: [ morphs add: submorph ] ] ].
		
	aRect
		allAreasOutsideList: (morphs collect: [ :each | each fullBounds ])
		do: [ :eachArea | ^ { aMorph } ].

	^ morphs reversed
]

{ #category : #private }
MorphicRoot >> intersectingMorphsWithin: aRect [
	| allMorphs intersectingMorphs |
	
	intersectingMorphs := OrderedCollection new.
	allMorphs := layeredMorphs copyWithFirst: self morph.
	allMorphs do: [ :eachMorph |
		eachMorph fullBounds = aRect ifTrue: [ ^ { eachMorph } ].
		
		intersectingMorphs := OrderedCollection new.
		eachMorph submorphsDo: [ :submorph | | bounds |
			bounds := submorph fullBounds.
			(bounds intersects: aRect) ifTrue: [
				((bounds ~= aRect) and: [ bounds containsRect: aRect ])
					ifTrue: [ intersectingMorphs addAll: (self intersectingMorphs: submorph within: aRect) ]
					ifFalse: [ intersectingMorphs add: submorph ] ] ] ].
	aRect
		allAreasOutsideList: (intersectingMorphs collect: [ :each | each fullBounds ])
		do: [ :eachArea | ^ { self morph } ].
	
	^ intersectingMorphs	reversed
]

{ #category : #invalidating }
MorphicRoot >> invalidRect: aRectangle from: aMorph [ 
	self invalidateRect: aRectangle
]

{ #category : #accessing }
MorphicRoot >> invalidate [

	self invalidate: true
]

{ #category : #private }
MorphicRoot >> invalidate: needQueue [

	damageRecorder doFullRepaint.
	needQueue ifTrue: [ container queueDraw ]
]

{ #category : #accessing }
MorphicRoot >> invalidateRect: damageRect [
	damageRecorder recordInvalidRect: damageRect.
	container queueDrawArea: damageRect
]

{ #category : #testing }
MorphicRoot >> isMorphResizable [

	^ morphResizable
]

{ #category : #keymapping }
MorphicRoot >> kmDispatcher [

^ container kmDispatcher
]

{ #category : #layout }
MorphicRoot >> layoutChanged [

	"Empty for now, should we keep it?"
]

{ #category : #accessing }
MorphicRoot >> morph [

	^ morph
]

{ #category : #accessing }
MorphicRoot >> morph: aMorph [
	| needQueue |

	needQueue := false.
	morph ifNotNil: [ 
		self stopStepping.
		"if we are replacing a morph, we will need to transmit to the new morph some properties. 
		 Also, we will need to force a queue"
		(self isMorphResizable and: [ aMorph extent < morph extent ]) 
			ifTrue: [ aMorph extent: morph extent ].
		needQueue := true ].
	
	morph := aMorph asMorph.
	"I will be the owner (and I will act as a world)"
	morph privateOwner: self.
	"in this view, position of the morph is always 0@0"
	morph position: 0@0.
	"check for the need of steppiong stepping"
	morph wantsSteps ifTrue: [ miniWorld  startStepping: morph ].

	container sizeRequest: aMorph extent.
	miniWorld  addSubmorphs: aMorph	.
	self invalidate: needQueue
	
	
]

{ #category : #private }
MorphicRoot >> morphResizable: aBoolean [

	morphResizable := aBoolean
]

{ #category : #private }
MorphicRoot >> needUpdate [
	^ damageRecorder updateIsNeeded
]

{ #category : #compatibility }
MorphicRoot >> paintMorph: aMorph [

	self worldRenderer
		displayWorldState: self world worldState
		ofWorld: self world
]

{ #category : #compatibility }
MorphicRoot >> paneColorOrNil [
	
	^ nil
]

{ #category : #accessing }
MorphicRoot >> popDamagedRectangles [

	| rectangles |
	rectangles := damageRecorder invalidRectsFullBounds: nil.
	damageRecorder reset.
	^ rectangles
]

{ #category : #'world simulation' }
MorphicRoot >> privateRemove: aMorph [
	
	^ aMorph
]

{ #category : #'world simulation' }
MorphicRoot >> processEvent: anEvent [
 
	^ self morph processEvent: anEvent
]

{ #category : #'world simulation' }
MorphicRoot >> removeAlarm: aSelector for: aTarget [
	
	^ container removeAlarm: aSelector for: aTarget
]

{ #category : #'world simulation' }
MorphicRoot >> removeMorph: aMorph [ 
	
	(layeredMorphs includes: aMorph) ifFalse: [ ^ self ].
	
	layeredMorphs remove: aMorph.
	
	self invalidateRect: aMorph fullBounds
]

{ #category : #'world simulation' }
MorphicRoot >> sizeRequest: anExtent [

	lastRequestedSize = anExtent ifTrue: [ ^ self ].
	super sizeRequest: anExtent. 
	lastRequestedSize := anExtent
]

{ #category : #'world simulation' }
MorphicRoot >> stopStepping [

	steps ifNil: [ ^ self ].
	steps do: [ :each | each cancel ].
	steps := nil
]

{ #category : #ui }
MorphicRoot >> theme [

	^ Smalltalk ui theme
]

{ #category : #'world simulation' }
MorphicRoot >> transformFrom: aMorph [ 
	^ IdentityTransform new
]

{ #category : #'world simulation' }
MorphicRoot >> viewBox [

	^ container viewBox
]

{ #category : #iterating }
MorphicRoot >> withAllOwnersDo: aBlock [
	
	aBlock value: self
]

{ #category : #accessing }
MorphicRoot >> world [
	
	^ miniWorld 
]

{ #category : #'world simulation' }
MorphicRoot >> worldRenderer [
	
	^ miniWorld worldRenderer 
]

{ #category : #'world simulation' }
MorphicRoot >> worldState [
	
	^ self world worldState .
]

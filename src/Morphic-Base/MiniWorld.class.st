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
		'root'
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
	
	^ root activeHand
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

{ #category : #initialization }
MiniWorld >> becomeActiveDuring: aBlock [
	
	aBlock value
]

{ #category : #'world state' }
MiniWorld >> displayWorld [

	state displayWorld: self .
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

{ #category : #'world simulation' }
MiniWorld >> removeAlarm: aSelector for: aTarget [
	
	^ root removeAlarm: aSelector for: aTarget
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

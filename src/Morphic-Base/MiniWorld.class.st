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
		'submorph',
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
	state addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime.
]

{ #category : #accessing }
MiniWorld >> addSubmorph: aMorph [

submorph add: aMorph
]

{ #category : #structure }
MiniWorld >> becomeActiveDuring: aBlock [
	
	aBlock value
]

{ #category : #accessing }
MiniWorld >> initialize [ 

submorph := OrderedCollection new.
worldRendered := MorphicRootRenderer new: self. 	
state := MiniWorldState new.
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

	state startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime
]

{ #category : #stepping }
MiniWorld >> stopStepping: aMorph [

	state stopStepping: aMorph
]

{ #category : #stepping }
MiniWorld >> stopStepping: aMorph selector: aSelector [

	state stopStepping: aMorph selector: aSelector.

	
]

{ #category : #accessing }
MiniWorld >> submorphs [

^ submorph 
]

{ #category : #accessing }
MiniWorld >> world [ 

^ self.
]

{ #category : #accessing }
MiniWorld >> worldRenderer [ 

	^ worldRendered 
]

{ #category : #accessing }
MiniWorld >> worldState [ 

^ state
]

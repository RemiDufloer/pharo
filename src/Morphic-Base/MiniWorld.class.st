Class {
	#name : #MiniWorld,
	#superclass : #Object,
	#instVars : [
		'submorph',
		'worldRendered'
	],
	#category : #'Morphic-Base'
}

{ #category : #accessing }
MiniWorld >> addSubmorph: aMorph [

submorph add: aMorph
]

{ #category : #accessing }
MiniWorld >> initialize [ 

submorph := OrderedCollection new.
worldRendered := MorphicRootRenderer new. 	
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
MiniWorld >> worldState [ 

^ self
]

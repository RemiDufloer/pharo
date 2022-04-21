Class {
	#name : #MorphicRootRenderer,
	#superclass : #OSWorldRenderer,
	#instVars : [
		'miniWorld'
	],
	#category : #'Morphic-Base'
}

{ #category : #'instance creation' }
MorphicRootRenderer class >> new: aMorph [
	| renderer |
	
	
	renderer := self new.
	renderer world: aMorph .
	^ 	renderer 	
]

{ #category : #accessing }
MorphicRootRenderer >> world: aMorph [

	world := aMorph 
	
]

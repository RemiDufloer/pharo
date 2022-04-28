"
I'm just a renderer for a specific world.

I know just my world.

For more information go to view my superclass .


    Instance Variables
	miniWorld:		<Object>


"
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

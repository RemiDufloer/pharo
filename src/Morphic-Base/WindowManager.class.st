Class {
	#name : #WindowManager,
	#superclass : #Morph,
	#instVars : [
		'allWorld'
	],
	#category : #'Morphic-Base'
}

{ #category : #'add/remove' }
WindowManager >> addWorld: aWorld [

	allWorld add: aWorld
]

{ #category : #accessing }
WindowManager >> allWorld [

	^ allWorld
]

{ #category : #'add/remove' }
WindowManager >> deleteAWorld: aWorld [

	allWorld delete: aWorld
]

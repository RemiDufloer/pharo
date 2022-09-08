"
A WorldMorph is a special morph that represents the world.
It is a paste up and it holds active hand.

A World, the entire Smalltalk screen, is a PasteUpMorph.  A World responds true to #isWorld.
"
Class {
	#name : #WorldMorph,
	#superclass : #PasteUpMorph,
	#classVars : [
		'AllowDropFiles',
		'CursorOwnerWorld',
		'ExtraWorldList',
		'ExtraWorldListMutex'
	],
	#classInstVars : [
		'displayScaleFactor'
	],
	#category : #'Morphic-Worlds'
}

{ #category : #'extra worlds' }
WorldMorph class >> addExtraWorld: aWorld [
	ExtraWorldListMutex critical: [
		ExtraWorldList := self extraWorldList copyWith: aWorld
	]
]

{ #category : #accessing }
WorldMorph class >> allowDropFiles: anObject [
	AllowDropFiles := anObject
]

{ #category : #setting }
WorldMorph class >> defaultWorldColor [

	^ Color r: 0.937 g: 0.937 b: 0.937
]

{ #category : #setting }
WorldMorph class >> displayScaleFactor [

	^ displayScaleFactor ifNil: [ displayScaleFactor := 1 ]
]

{ #category : #setting }
WorldMorph class >> displayScaleFactor: aNumber [

	displayScaleFactor := aNumber
]

{ #category : #setting }
WorldMorph class >> displayScaleFactorSettingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder range: #scaleFactor)
		parent: #appearance;
		order: 3;
		default: 1;
		label: 'Display scale factor';
		description: 'Specify scale factor for UI elements. This setting does not affect defined font sizes.';
		target: self;
		range: (0.5 to: 5 by: 0.5)
]

{ #category : #updating }
WorldMorph class >> doOneCycle [

	WorldState doDrawCycleWith: [ 
		| extraWorldsToDraw |
		extraWorldsToDraw := ExtraWorldListMutex critical: [ 
			                     self extraWorldList ].
		extraWorldsToDraw do: [ :world | world doOneCycle ].

		(self currentWorld isNotNil and: [ 
			 (extraWorldsToDraw includes: self currentWorld) not ]) ifTrue: [ 
			self currentWorld doOneCycle ] ]
]

{ #category : #'extra worlds' }
WorldMorph class >> extraWorldList [
	ExtraWorldList ifNil: [ ExtraWorldList := #() ].
	^ ExtraWorldList
]

{ #category : #accessing }
WorldMorph class >> extraWorldListMutex [

	^ ExtraWorldListMutex
]

{ #category : #'class initialization' }
WorldMorph class >> initialize [
	ExtraWorldListMutex := Semaphore forMutualExclusion.
]

{ #category : #'extra worlds' }
WorldMorph class >> removeExtraWorld: aWorld [
	ExtraWorldListMutex critical: [
		ExtraWorldList size traceCr.
		ExtraWorldList := self extraWorldList copyWithout: aWorld.
		ExtraWorldList size traceCr.
	].
	CursorOwnerWorld == aWorld ifTrue: [ CursorOwnerWorld := nil ].
]

{ #category : #accessing }
WorldMorph class >> scaleFactor [
	
	^ World scaleFactor
]

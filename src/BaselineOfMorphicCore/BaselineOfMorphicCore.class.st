"
This baseline is used to generate Pharo images from the local clone of pharo-project/pharo repository. 

Depends on:
- SUnit, Display, UnifiedFFI

Load type: 
- linear

Installs:
- minimal working Morphic subset without fonts support
"
Class {
	#name : #BaselineOfMorphicCore,
	#superclass : #BaselineOf,
	#classVars : [
		'Initialized'
	],
	#category : #BaselineOfMorphicCore
}

{ #category : #baseline }
BaselineOfMorphicCore >> baseline: spec [ 
    
	<baseline>

	| repository | 
	
	repository := self packageRepositoryURL.

	spec for: #common do: [
		spec postLoadDoIt: #'postload:package:'.

		spec baseline: 'Traits' with: [spec repository: repository].
		spec baseline: 'SUnit' with: [spec repository: repository].
		spec baseline: 'Display' with: [spec repository: repository].
		spec baseline: 'UnifiedFFI' with: [spec repository: repository].

		spec package: 'System-Object Events'.
		spec package: 'Collections-DoubleLinkedList'.
		spec package: 'System-Caching'.
		spec package: 'Graphics-Canvas'.
		spec package: 'FormCanvas-Core'.
		spec package: 'Tool-Registry'.
		spec package: 'Fonts-Abstract'.
		spec package: 'Text-Core'.
		spec package: 'Morphic-Core'.
	].
]

{ #category : #actions }
BaselineOfMorphicCore >> postload: loader package: packageSpec [

	"Ignore pre and post loads if already executed"
	Initialized = true ifTrue: [ ^ self ].
	
	IdentityTransform initialize.

	Cursor initTarget.
	EventManager initialize.

	Initialized := true.
]

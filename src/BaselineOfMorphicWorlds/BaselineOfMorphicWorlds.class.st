Class {
	#name : #BaselineOfMorphicWorlds,
	#superclass : #BaselineOf,
	#instVars : [
		'initializersEnabled'
	],
	#classVars : [
		'Initialized'
	],
	#category : #BaselineOfMorphicWorlds
}

{ #category : #baseline }
BaselineOfMorphicWorlds >> baseline: spec [

	<baseline>
	| repository |
	repository := self packageRepositoryURL.

	spec for: #common do: [ 
		spec preLoadDoIt: #preload:package:.
		spec postLoadDoIt: #postload:package:.

		spec baseline: 'Morphic' with: [ spec repository: repository ].
		spec package: 'Morphic-Worlds' ]
]

{ #category : #actions }
BaselineOfMorphicWorlds >> postload: loader package: packageSpec [

	"Ignore pre and post loads if already executed"
	Initialized = true ifTrue: [ ^ self ].

	SystemNotification signal: 'Starting postload action'.

	Smalltalk cleanOutUndeclared.
	Author fullName: self class name.

	UIManager default terminateUIProcess.
	MorphicUIManager new spawnNewProcess.
	Display newDepth: 32.

	"Install the right UIManager"
	UIManager default: UIManager forCurrentSystemConfiguration.

	PolymorphSystemSettings desktopLogoChanged.
	PolymorphSystemSettings desktopColor: Color white.

	UIManager default restoreDisplay.
	
	Author reset.
	MCMethodDefinition initializersEnabled: initializersEnabled.
	Initialized := true.
]

{ #category : #actions }
BaselineOfMorphicWorlds >> preload: loader package: packageSpec [

	"Ignore pre and post loads if already executed"
	Initialized = true ifTrue: [ ^ self ].

	SystemNotification signal: 'Starting preload action'.
	
	initializersEnabled := MCMethodDefinition initializersEnabled.
	MCMethodDefinition initializersEnabled: false.
	
	Author fullName: self class name
]

{ #category : #baseline }
BaselineOfMorphicWorlds >> project [
	
	| aProject |
	
	aProject := super project.
	aProject loadType: #atomic.
	^ aProject.
]

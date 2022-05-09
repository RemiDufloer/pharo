Class {
	#name : #Window,
	#superclass : #Object,
	#instVars : [
		'window',
		'backend',
		'manager'
	],
	#category : #'Morphic-Base'
}

{ #category : #'instance creation' }
Window class >> newWindow: aMorph manageBy: aManager [

	| newWindow |
	newWindow  := self new.
	newWindow window: aMorph.
	newWindow manager: aManager.
	^ newWindow 
	
]

{ #category : #'submorphs - add/remove' }
Window >> delete [

	window delete.
	backend delete.
	manager deleteAWindow: self
]

{ #category : #'submorphs - add/remove' }
Window >> manager: aWindowManager [ 
	manager := aWindowManager
]

{ #category : #'submorphs - add/remove' }
Window >> open [

	window openInExternalWindow.
	backend := window.
]

{ #category : #'submorphs - add/remove' }
Window >> openWithGtk [

	| presenter morph |
	presenter := SpPresenter new.
	presenter application: (SpApplication new useBackend: #Gtk).
	presenter layout: (SpPanedLayout newHorizontal
			 add: (morph := presenter newMorph);
			 yourself).
	morph morph: window.
	
	presenter open.
	
backend := presenter .
]

{ #category : #'submorphs - add/remove' }
Window >> window: aWindow [
	window := aWindow
]

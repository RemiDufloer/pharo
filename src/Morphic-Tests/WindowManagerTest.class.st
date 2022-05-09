Class {
	#name : #WindowManagerTest,
	#superclass : #TestCase,
	#category : #'Morphic-Tests'
}

{ #category : #tests }
WindowManagerTest >> testDeleteAWindow [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.

	newWindow delete.

	self assert: manager numberOfOpenWindows equals: 0
]

{ #category : #tests }
WindowManagerTest >> testDeleteAWindowAndTaskBarActualized [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.

	newWindow delete.

	self assert: manager taskBar submorphs size equals: 0
]

{ #category : #tests }
WindowManagerTest >> testNewWindowShouldBeSave [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager newWindowWithRoot: Morph new.

	self assert: manager numberOfWindows equals: 1.

	
]

{ #category : #tests }
WindowManagerTest >> testNewWindowShouldBeSaveAndTaskBarHaveAnewWidget [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager newWindowWithRoot: Morph new.

	self assert: manager taskBar submorphs size equals: 1
]

{ #category : #tests }
WindowManagerTest >> testOpenNewWindowShouldBeSave [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot:
		             ClyFullBrowserMorph onDefaultEnvironment.

	self assert: manager numberOfOpenWindows equals: 1.
	"newWindow delete"
]

{ #category : #tests }
WindowManagerTest >> testOpenWithBackendGtkNewWindowShouldBeSave [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowBackendGtkWithRoot: Morph new.

	self assert: manager numberOfOpenWindows equals: 1

	"newWindow delete"
]

{ #category : #tests }
WindowManagerTest >> testWindowMaximize [

	| manager presenter morph |
	manager := WindowManager new.
	presenter := SpPresenter new.
	presenter application: (SpApplication new useBackend: #Gtk).
	presenter layout: (SpPanedLayout newHorizontal
			 add: (morph := presenter newMorph);
			 yourself).
	manager addWindow: presenter.
	self assert: presenter owner isMaximized equals: false.
	manager windowMaximize: presenter.
	self assert: presenter owner isMaximized equals: true.
	manager deleteAWindow: presenter
]

{ #category : #tests }
WindowManagerTest >> testWindowMinimize [

	| manager newWorld presenter morph |
	manager := WindowManager new.
	newWorld := MiniWorld new.
	presenter := SpPresenter new.
	presenter application: (SpApplication new useBackend: #Gtk).
	presenter layout: (SpPanedLayout newHorizontal
			 add: (morph := presenter newMorph);
			 yourself).	

	manager addWindow: presenter.
	manager windowMaximize: presenter.
	self assert: presenter owner isMinimized equals: false.	
	manager windowMinimize: presenter.
	self assert: presenter owner isMinimized equals: true.
	manager deleteAWindow: presenter.
]

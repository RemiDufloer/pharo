Class {
	#name : #WindowManagerTest,
	#superclass : #TestCase,
	#category : #'Morphic-Tests'
}

{ #category : #tests }
WindowManagerTest >> testAddWindow [

	| manager |
	manager := WindowManager new.
	manager addWindowWithRoot: Morph new.

	self assert: manager numberOfOpenWindows equals: 1

]

{ #category : #tests }
WindowManagerTest >> testAllWindowState [

	| manager newWorld presenter morph |
	manager := WindowManager new.
	newWorld := MiniWorld new.
	presenter := SpPresenter new.
	presenter application: (SpApplication new useBackend: #Gtk).
	presenter layout: (SpPanedLayout newHorizontal 
			 add: (morph := presenter newMorph);
			 yourself).

	manager addWindow: presenter.
	self assert: manager allWorld size equals: 1 .
	self assert: manager allWindowState size equals: 1 .			
	
]

{ #category : #tests }
WindowManagerTest >> testCreation [ 

	| manager |
	
	manager := WindowManager new.
	self assert: manager allWorld size equals: 0.
	
]

{ #category : #tests }
WindowManagerTest >> testDeleteAWindow [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager addWindowWithRoot: Morph new.

	newWindow delete.
	
	self assert: manager numberOfOpenWindows equals: 0
]

{ #category : #tests }
WindowManagerTest >> testTaskBar [

	| manager |
	
	manager := WindowManager new.
	self assert: manager taskBar submorphCount equals: 0.
	
]

{ #category : #tests }
WindowManagerTest >> testTaskBarAdd [

	| manager presenter morph |
	
	manager := WindowManager new.
	presenter := SpPresenter new.
	presenter application: (SpApplication new useBackend: #Gtk).
	presenter layout: (SpPanedLayout newHorizontal
			 add: (morph := presenter newMorph);
			 yourself).
	manager addWindow: presenter.
	self assert: manager taskBar submorphCount equals: 1.
	
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

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
	
	newWindow delete .

	self assert: manager taskBar submorphs size equals: 0
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindow [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	
	manager closeAllWindow.

	self assert: manager numberOfOpenWindows equals: 0.
	

]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToLeftOfAWindow [

	| manager newWindow |
	manager := WindowManager new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToLeft .

	self assert: manager numberOfOpenWindows equals: 1.
	
	newWindow delete.
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToLeftOfAWindowWhenDontHaveWindowOnLeft [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToLeft .

	self assert: manager numberOfOpenWindows equals: 1.
	
	newWindow delete.
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToRightOfAWindow [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToRight .

	self assert: manager numberOfOpenWindows equals: 1.
	
	newWindow delete.
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToRightOfAWindowWhenDontHaveWindowOnRight [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToRight .

	self assert: manager numberOfOpenWindows equals: 1.
	
	newWindow delete.
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
	newWindow := manager newWindowWithRoot: SystemWindow  new.

	self assert: manager taskBar submorphs size equals: 1
]

{ #category : #tests }
WindowManagerTest >> testOpenNewWindowShouldBeSave [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowWithRoot:
		             ClyFullBrowserMorph onDefaultEnvironment.
	self assert: manager numberOfOpenWindows equals: 1.
	newWindow delete
]

{ #category : #tests }
WindowManagerTest >> testOpenWithBackendGtkNewWindowShouldBeSave [

	| manager newWindow |
	manager := WindowManager new.
	newWindow := manager openNewWindowBackendGtkWithRoot: SystemWindow  new.

	self assert: manager numberOfOpenWindows equals: 1

	"newWindow delete"
]

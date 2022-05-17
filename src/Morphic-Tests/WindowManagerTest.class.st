Class {
	#name : #WindowManagerTest,
	#superclass : #TestCase,
	#instVars : [
		'manager'
	],
	#category : #'Morphic-Tests'
}

{ #category : #running }
WindowManagerTest >> setUp [
	super setUp.
	manager := WindowManager new.
	
]

{ #category : #tests }
WindowManagerTest >> tearDown [ 

	manager ensureDeleteAll.
	super tearDown

	
]

{ #category : #tests }
WindowManagerTest >> testDeleteANonOpenWindowFails [

	| newWindow |
	newWindow := manager newWindowWithRoot: Morph new.

	[ 
	newWindow delete.
	self fail ]
		on: Error
		do: [ :err | 
			self
				assert: err messageText
				equals: 'Cannot delete non open window' ]
]

{ #category : #tests }
WindowManagerTest >> testDeleteAWindow [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.

	newWindow delete.

	self assert: manager numberOfOpenWindows equals: 0
]

{ #category : #tests }
WindowManagerTest >> testDeleteAWindowAndTaskBarActualized [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow delete.

	self assert: manager taskBar submorphs size equals: 0
]

{ #category : #tests }
WindowManagerTest >> testDeleteAll [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.

	manager deleteAll.

	self assert: manager numberOfOpenWindows equals: 0.
	self deny: manager isTaskBarOpen
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindow [

	| newWindow |
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

	| newWindow |
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToLeft .

	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToLeftOfAWindowWhenDontHaveWindowOnLeft [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToLeft .

	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToRightOfAWindow [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToRight .

	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testDeleteAllWindowToRightOfAWindowWhenDontHaveWindowOnRight [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.
	
	newWindow closeAllWindowToRight .

	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testNewWindowShouldBeSave [

	| newWindow |
	manager := WindowManager new.
	newWindow := manager newWindowWithRoot: Morph new.

	self assert: manager numberOfWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testNewWindowShouldBeSaveAndTaskBarHaveAnewWidget [

	| newWindow |
	newWindow := manager newWindowWithRoot: SystemWindow  new.

	self assert: manager taskBar submorphs size equals: 1
]

{ #category : #tests }
WindowManagerTest >> testOpenNewWindowShouldBeSave [

	| newWindow |
	newWindow := manager openNewWindowWithRoot:
		             ClyFullBrowserMorph onDefaultEnvironment.
	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testOpenWithBackendGtkNewWindowShouldBeSave [

	| newWindow |
	newWindow := manager openNewWindowBackendGtkWithRoot: SystemWindow  new.

	self assert: manager numberOfOpenWindows equals: 1
]

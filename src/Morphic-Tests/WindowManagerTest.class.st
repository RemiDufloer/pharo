Class {
	#name : #WindowManagerTest,
	#superclass : #AbstractWindowManagerTest,
	#category : #'Morphic-Tests'
}

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
WindowManagerTest >> testOpenNewWindowShouldBeSave [

	| newWindow |
	newWindow := manager openNewWindowWithRoot:
		             ClyFullBrowserMorph onDefaultEnvironment.
	self assert: manager numberOfOpenWindows equals: 1
]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeCreateAfterStartupWithGoodMorph [

	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.
	manager openNewWindowWithRoot: Morph new.

	manager saveAllRoot.
	manager saveAllAttributes.
	manager deleteAll.

	manager startupRoot.

	self assert: manager numberOfWindows equals: 3.

	manager startupOpenWithAttributes
]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeOpenAfterStartupWithGoodMorphWhenNoMorphIsSave [

	manager saveAllRoot.
	
	manager deleteAll.
	
	manager startupRoot.
	
	self assert: manager numberOfWindows  equals: 0.
	

	

]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeOpenAfterStartupWithGoodMorphWithGoodAttribus [

	| newWindow |
	newWindow := manager openNewWindowWithRoot: Morph new.


	manager saveAllRoot.
	manager saveAllAttributes.

	manager deleteAll.

	manager startupRoot.
	manager startupOpenWithAttributes.


	self
		assert: manager allWindow first attributs
		equals: newWindow attributs
]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeOpenAfterStartupWithtaskBar [

	
	manager deleteAll.
	
	manager startupTaskbar.
	
	self assert: manager isTaskBarOpen 
	

	

]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeSaveBeforeShutDownSaveAttributes [

	manager openNewWindowWithRoot: Morph new.
	manager saveAllAttributes.
	
	self assert: manager numberOfAttributesSave equals: 1.
	

	

]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeSaveBeforeShutDownSaveAttributesButNoRoot [

	manager saveAllAttributes.
	
	self assert: manager numberOfAttributesSave equals: 0.
	

	

]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeSaveBeforeShutDownSaveRoot [


   manager openNewWindowWithRoot:  Morph new.
   manager openNewWindowWithRoot: Morph new.

	manager saveAllRoot.
	
	self assert: manager numberOfRootSave equals: 2.
	

	

]

{ #category : #tests }
WindowManagerTest >> testWindowShouldBeSaveBeforeShutDownSaveRootButHaveNotRoot [

	manager saveAllRoot.
	
	self assert: manager numberOfRootSave equals: 0.
	

	

]

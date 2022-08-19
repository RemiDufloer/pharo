"
I manage the native window, when i was create i open a window with a taskbar, if you create a window, the window is add at the taskbar.


    Instance Variables
	allWindow:		<Object>
	allWindowState:		<Object>
	allWorld:		<Object>
	taskBar:		<Object>
	taskBarWindow:		<Object>


    Implementation Points
"
Class {
	#name : #MorphicWindowManager,
	#superclass : #Morph,
	#instVars : [
		'taskBar',
		'allWindow',
		'taskBarWindow',
		'rootSave',
		'allAttributes'
	],
	#category : #'Morphic-Base'
}

{ #category : #accessing }
MorphicWindowManager >> allAttributes [
	^ allAttributes
]

{ #category : #accessing }
MorphicWindowManager >> allSaveRoot [
	
	^ rootSave 
]

{ #category : #accessing }
MorphicWindowManager >> allWindow [ 

	^ allWindow 
]

{ #category : #accessing }
MorphicWindowManager >> closeAllWindow [

	
	(allWindow size) to: (1) by: (-1) do: [ :m | (allWindow at: m) delete  ].
	taskBar updateTasks .
]

{ #category : #accessing }
MorphicWindowManager >> closeAllWindowToLeft: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	(index - 1 )  to: 1 by: (-1) do: [ :m | (allWindow at: m) delete  ].
	taskBar updateTasks .
]

{ #category : #accessing }
MorphicWindowManager >> closeAllWindowToRight: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	allWindow size to: index + 1 by: -1 do: [ :m | 
	(allWindow at: m) delete ].
	taskBar updateTasks
]

{ #category : #accessing }
MorphicWindowManager >> closeWindow: aWindow [

	( allWindow  includes: aWindow )ifTrue:[allWindow remove: aWindow ].
	taskBar ifNotNil:  [taskBar  updateTasks] .
]

{ #category : #closing }
MorphicWindowManager >> deleteAll [

	self closeAllWindow.

	"Call doDelete because the taskbar window is not subscribed to manager"
	taskBarWindow doDelete.

]

{ #category : #accessing }
MorphicWindowManager >> ensureCloseAllWindow [

	allWindow size to: 1 by: -1 do: [ :m | 
		(allWindow at: m) ensureDelete ].
	taskBar updateTasks
]

{ #category : #closing }
MorphicWindowManager >> ensureDeleteAll [

	self ensureCloseAllWindow.

	"Call doDelete because the taskbar window is not subscribed to manager"
	taskBarWindow ensureDoDelete
]

{ #category : #accessing }
MorphicWindowManager >> initialize [

	allWindow := OrderedCollection new.
	self startupTaskbar .
]

{ #category : #testing }
MorphicWindowManager >> isTaskBarOpen [
	
	^ taskBarWindow isOpen
]

{ #category : #accessing }
MorphicWindowManager >> newWindowWithRoot: aMorph [

	| newWindow |
	newWindow := MorphicNativeWindow newWindow: aMorph manageBy: self.
	allWindow add: newWindow.
	^ newWindow
]

{ #category : #size }
MorphicWindowManager >> numberOfAttributesSave [
	
	^ allAttributes size
]

{ #category : #accessing }
MorphicWindowManager >> numberOfOpenWindows [

	^ allWindow size
]

{ #category : #accessing }
MorphicWindowManager >> numberOfRootSave [
	
	^ rootSave size 
]

{ #category : #accessing }
MorphicWindowManager >> numberOfWindows [
	^ allWindow size
]

{ #category : #accessing }
MorphicWindowManager >> openNewWindowBackendGtkWithRoot: aMorph [ 
	
	^ (self newWindowWithRoot: aMorph ) openWithGtk .
]

{ #category : #accessing }
MorphicWindowManager >> openNewWindowWithRoot: aMorph [ 

	| newWindow |
	newWindow := ( self newWindowWithRoot: aMorph ) open.
	taskBar updateTasks .
	^ newWindow
]

{ #category : #saving }
MorphicWindowManager >> saveAllAttributes [
	
	allAttributes := allWindow collect: [  :w | w attributsSave ].
]

{ #category : #saving }
MorphicWindowManager >> saveAllRoot [
	
	rootSave := allWindow collect: [ :m | m window ]
]

{ #category : #startup }
MorphicWindowManager >> startupOpenWithAttributes [
	
	1 to: allAttributes  size do: [ :a | (allWindow  at: a) openWithAttributes: (allAttributes at: a)  ]
]

{ #category : #'startup - shutdown' }
MorphicWindowManager >> startupRoot [
	
	1 to: rootSave size do: [ :r | self newWindowWithRoot:  (rootSave at: r) ]
]

{ #category : #startup }
MorphicWindowManager >> startupTaskbar [
	
	taskBarWindow := MorphicNativeWindow newWindow: (TaskbarMorphForManager newByManager: self) manageBy: self.
	taskBarWindow open.
	taskBar := taskBarWindow window
]

{ #category : #accessing }
MorphicWindowManager >> taskBar [

	^ taskBar 
]

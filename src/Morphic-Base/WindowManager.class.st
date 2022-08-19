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
	#name : #WindowManager,
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
WindowManager >> allAttributes [
	^ allAttributes
]

{ #category : #accessing }
WindowManager >> allSaveRoot [
	
	^ rootSave 
]

{ #category : #accessing }
WindowManager >> allWindow [ 

	^ allWindow 
]

{ #category : #accessing }
WindowManager >> closeAllWindow [

	
	(allWindow size) to: (1) by: (-1) do: [ :m | (allWindow at: m) delete  ].
	taskBar updateTasks .
]

{ #category : #accessing }
WindowManager >> closeAllWindowToLeft: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	(index - 1 )  to: 1 by: (-1) do: [ :m | (allWindow at: m) delete  ].
	taskBar updateTasks .
]

{ #category : #accessing }
WindowManager >> closeAllWindowToRight: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	allWindow size to: index + 1 by: -1 do: [ :m | 
	(allWindow at: m) delete ].
	taskBar updateTasks
]

{ #category : #accessing }
WindowManager >> closeWindow: aWindow [

	( allWindow  includes: aWindow )ifTrue:[allWindow remove: aWindow ].
	taskBar ifNotNil:  [taskBar  updateTasks] .
]

{ #category : #closing }
WindowManager >> deleteAll [

	self closeAllWindow.

	"Call doDelete because the taskbar window is not subscribed to manager"
	taskBarWindow doDelete.

]

{ #category : #accessing }
WindowManager >> ensureCloseAllWindow [

	allWindow size to: 1 by: -1 do: [ :m | 
		(allWindow at: m) ensureDelete ].
	taskBar updateTasks
]

{ #category : #closing }
WindowManager >> ensureDeleteAll [

	self ensureCloseAllWindow.

	"Call doDelete because the taskbar window is not subscribed to manager"
	taskBarWindow ensureDoDelete
]

{ #category : #accessing }
WindowManager >> initialize [

	allWindow := OrderedCollection new.
	self startupTaskbar .
]

{ #category : #testing }
WindowManager >> isTaskBarOpen [
	
	^ taskBarWindow isOpen
]

{ #category : #accessing }
WindowManager >> newWindowWithRoot: aMorph [

	| newWindow |
	newWindow := MorphicNativeWindow newWindow: aMorph manageBy: self.
	allWindow add: newWindow.
	^ newWindow
]

{ #category : #size }
WindowManager >> numberOfAttributesSave [
	
	^ allAttributes size
]

{ #category : #accessing }
WindowManager >> numberOfOpenWindows [

	^ allWindow size
]

{ #category : #accessing }
WindowManager >> numberOfRootSave [
	
	^ rootSave size 
]

{ #category : #accessing }
WindowManager >> numberOfWindows [
	^ allWindow size
]

{ #category : #accessing }
WindowManager >> openNewWindowBackendGtkWithRoot: aMorph [ 
	
	^ (self newWindowWithRoot: aMorph ) openWithGtk .
]

{ #category : #accessing }
WindowManager >> openNewWindowWithRoot: aMorph [ 

	| newWindow |
	newWindow := ( self newWindowWithRoot: aMorph ) open.
	taskBar updateTasks .
	^ newWindow
]

{ #category : #saving }
WindowManager >> saveAllAttributes [
	
	allAttributes := allWindow collect: [  :w | w attributsSave ].
]

{ #category : #saving }
WindowManager >> saveAllRoot [
	
	rootSave := allWindow collect: [ :m | m window ]
]

{ #category : #startup }
WindowManager >> startupOpenWithAttributes [
	
	1 to: allAttributes  size do: [ :a | (allWindow  at: a) openWithAttributes: (allAttributes at: a)  ]
]

{ #category : #'startup - shutdown' }
WindowManager >> startupRoot [
	
	1 to: rootSave size do: [ :r | self newWindowWithRoot:  (rootSave at: r) ]
]

{ #category : #startup }
WindowManager >> startupTaskbar [
	
	taskBarWindow := MorphicNativeWindow newWindow: (TaskbarMorphForManager newByManager: self) manageBy: self.
	taskBarWindow open.
	taskBar := taskBarWindow window
]

{ #category : #accessing }
WindowManager >> taskBar [

	^ taskBar 
]

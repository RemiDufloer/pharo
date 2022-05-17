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
		'allWorld',
		'allWindowState',
		'taskBar',
		'allWindow',
		'taskBarWindow'
	],
	#category : #'Morphic-Base'
}

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
	(allWindow size) to: (index + 1) by: (-1) do: [ :m | (allWindow at: m) delete  ].
	taskBar updateTasks .
]

{ #category : #accessing }
WindowManager >> closeWindow: aWindow [

	allWindow remove: aWindow.
	taskBar updateTasks .
]

{ #category : #closing }
WindowManager >> deleteAll [

	self closeAllWindow.

	"Call doDelete because the taskbar window is not subscribed to manager"
	taskBarWindow doDelete
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
	taskBarWindow := Window newWindow: (TaskbarMorphForManager newByManager: self) manageBy: self.
	taskBarWindow open.
	taskBar := taskBarWindow window
]

{ #category : #testing }
WindowManager >> isTaskBarOpen [
	
	^ taskBarWindow isOpen
]

{ #category : #accessing }
WindowManager >> newWindowWithRoot: aMorph [

	| newWindow |
	newWindow := Window newWindow: aMorph manageBy: self.
	allWindow add: newWindow.
	^ newWindow
]

{ #category : #accessing }
WindowManager >> numberOfOpenWindows [

	^ allWindow size
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

{ #category : #accessing }
WindowManager >> taskBar [

	^ taskBar 
]

"
Please comment me using the following template inspired by Class Responsibility Collaborator (CRC) design:

I represent a native window

I open a new window with a specific backend, i know my manager, i have all atributs for the window.

For the Collaborators Part: on github: @RemiDufloer

Internal Representation and Key Implementation Points.

    Instance Variables
	attributs:		the attributs of the window (title ect..)
	backend:		sdl or gtk
	manager:		aWindowManager
	osWindow:		osWindow
	window:		aMorph
			
"
Class {
	#name : #Window,
	#superclass : #Object,
	#traits : 'TShowInTaskbar',
	#classTraits : 'TShowInTaskbar classTrait',
	#instVars : [
		'window',
		'backend',
		'manager',
		'attributs',
		'osWindow'
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

{ #category : #closing }
Window >> allowedToClose [

	self flag: 'todo'.
	^ true
]

{ #category : #'submorphs - add/remove' }
Window >> attributs [

	^ attributs
]

{ #category : #'submorphs - add/remove' }
Window >> attributsSave [

	osWindow position.
	osWindow title.
	osWindow bounds.
	
	^ attributs 
]

{ #category : #accessing }
Window >> backend [

	^ backend
]

{ #category : #testing }
Window >> canBeMaximized [
	"Answer whether we are not we can be maximised."

	^ attributs  resizable  and: [ attributs maximized not ]
]

{ #category : #'submorphs - add/remove' }
Window >> closeAllWindowToLeft [

	manager closeAllWindowToLeft: self
]

{ #category : #'submorphs - add/remove' }
Window >> closeAllWindowToRight [

	manager closeAllWindowToRight: self
]

{ #category : #'submorphs - add/remove' }
Window >> delete [

	self doDelete.
	manager closeWindow: self
]

{ #category : #'submorphs - add/remove' }
Window >> doDelete [

	"Low-level deletion method.
	Do not use directly, otherwise the connection with the manager would be lost.

	Use #delete instead"

	self isOpen ifFalse: [ self error: 'Cannot delete non open window' ].
	self ensureDoDelete
]

{ #category : #'submorphs - add/remove' }
Window >> ensureDelete [

	self ensureDoDelete.
	manager closeWindow: self
]

{ #category : #'submorphs - add/remove' }
Window >> ensureDoDelete [

	"Low-level deletion method.
	Do not use directly, otherwise the connection with the manager would be lost.

	Use #ensureDelete instead.
	
	Do not fail if the window is not open"

	self isOpen ifFalse: [ ^ self ].

	window delete.
	backend delete
]

{ #category : #testing }
Window >> isClosed [
	
	^ self isOpen not
]

{ #category : #testing }
Window >> isMaximized [ 

	^ attributs maximized 
]

{ #category : #testing }
Window >> isMinimized [

	^ attributs minimized
]

{ #category : #testing }
Window >> isNotMinimized [

	^ attributs minimized not
]

{ #category : #testing }
Window >> isNotRestored [
	"Answer whether we are maximised or minimised."

	^attributs  minimized or: [attributs maximized]
]

{ #category : #testing }
Window >> isOpen [
	
	osWindow ifNil: [ ^ false ].
	^ osWindow isVisible
]

{ #category : #'submorphs - add/remove' }
Window >> manager [
	^ manager 
]

{ #category : #'submorphs - add/remove' }
Window >> manager: aWindowManager [ 
	manager := aWindowManager
]

{ #category : #'window management' }
Window >> maximize [

	osWindow maximize
]

{ #category : #'window management' }
Window >> minimize [

	osWindow minimize
]

{ #category : #'submorphs - add/remove' }
Window >> open [
	backend := window openInExternalWindow.
	backend manager: manager .
	attributs := self backend worldState worldRenderer osWindow initialAttributes.
	osWindow := self backend worldState worldRenderer osWindow.
	
]

{ #category : #open }
Window >> openWithAttributs: aAttributs [ 
	

	backend := window openInExternalWindowWithAttributs: aAttributs .
	attributs := self backend worldState worldRenderer osWindow initialAttributes.
	osWindow := self backend worldState worldRenderer osWindow.
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

	backend := presenter
]

{ #category : #accessing }
Window >> osWindow [

^	osWindow
]

{ #category : #'window management' }
Window >> restore [

	osWindow restore
]

{ #category : #'taskbar-required' }
Window >> taskbarButtonIsActive [

	"true/false"
	
	^ true
]

{ #category : #'taskbar-public' }
Window >> taskbarButtonMenu: aMenu [

	| menu theme submenu  |
	theme :=  Smalltalk ui theme.	
	menu := theme newMenuIn: self for: self.
	
	menu
		addToggle: 'Restore' translated
		target: self
		selector: #restore
		getStateSelector: nil
		enablementSelector: #isNotRestored.
	menu lastItem
		icon: theme windowMaximizeForm;
		font: theme menuFont.
		
	menu
		addToggle: 'Minimize' translated
		target: self
		selector: #minimize
		getStateSelector: nil
		enablementSelector: #isNotMinimized.
	menu lastItem
		icon:  theme windowMinimizeForm;
		font: theme menuFont.
		
	menu
		addToggle: 'Maximize' translated
		target: self
		selector: #maximize
		getStateSelector: nil
		enablementSelector: #canBeMaximized.
	menu lastItem
		icon: theme windowMaximizeForm;
		font: theme menuFont.
		
	menu addLine.

	submenu := theme newMenuIn: self for: self.
	menu
		add: 'Close all'
		icon: theme windowCloseForm
		subMenu: submenu.
	submenu
		addToggle: 'Close all' translated
		target: self manager
		selector: #closeAllWindow
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'windows to left' translated
		target: self
		selector: #closeAllWindowToLeft
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'windows to right' translated
		target: self
		selector: #closeAllWindowToRight
		getStateSelector: nil
		enablementSelector: true.
	submenu
		addToggle: 'close all debuggers' translated
		target: OupsDebuggerSystem
		selector: #closeAllDebuggers
		getStateSelector: nil
		enablementSelector: true.
	menu
		addToggle: 'Close' translated
		target: self
		selector: #delete
		getStateSelector: nil
		enablementSelector: #allowedToClose.
	menu lastItem
		icon: theme windowCloseForm;
		font: theme menuFont.

	^menu
]

{ #category : #'taskbar-required' }
Window >> taskbarLabel [
	"Answer the label to use for a taskbar button for the receiver."
	
	^ self attributs title
]

{ #category : #'taskbar-required' }
Window >> taskbarState [
	"Answer one of #minimized, #restored, #maximized or #active."
	
	^ self attributs minimized
		ifTrue: [#minimized]
		ifFalse: [self attributs maximized
			ifTrue: [#maximized]
			ifFalse: [self attributs  windowCentered
						ifTrue: [#active]
						ifFalse: [#restored]]]
]

{ #category : #'window management' }
Window >> theme [
	^ Smalltalk ui theme
]

{ #category : #getter }
Window >> window [
	^ window
]

{ #category : #'submorphs - add/remove' }
Window >> window: aWindow [
	window := aWindow
]

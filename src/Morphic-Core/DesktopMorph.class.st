Class {
	#name : #DesktopMorph,
	#superclass : #PasteUpMorph,
	#instVars : [
		'tools'
	],
	#classInstVars : [
		'displayScaleFactor'
	],
	#category : #'Morphic-Core-Worlds'
}

{ #category : #setting }
DesktopMorph class >> defaultWorldColor [

	^ Color r: 0.937 g: 0.937 b: 0.937
]

{ #category : #setting }
DesktopMorph class >> displayScaleFactor [

	^ displayScaleFactor ifNil: [ displayScaleFactor := 1 ]
]

{ #category : #setting }
DesktopMorph class >> displayScaleFactor: aNumber [

	displayScaleFactor := aNumber
]

{ #category : #setting }
DesktopMorph class >> displayScaleFactorSettingsOn: aBuilder [ 
	<systemsettings>
	
	(aBuilder range: #scaleFactor)
		parent: #appearance;
		order: 3;
		default: 1;
		label: 'Display scale factor';
		description: 'Specify scale factor for UI elements. This setting does not affect defined font sizes.';
		target: self;
		range: (0.5 to: 5 by: 0.5)
]

{ #category : #accessing }
DesktopMorph class >> scaleFactor [
	
	^ World scaleFactor
]

{ #category : #'event handling' }
DesktopMorph >> acceptDroppingMorph: dropped event: evt [

	"The supplied morph, known to be acceptable to the receiver, is now to be assimilated; the precipitating event is supplied"

	| aMorph |
	aMorph := self morphToDropFrom: dropped. "Add the given morph to this world and start stepping it if it wants to be."
	self addMorphFront: aMorph.
	(aMorph fullBounds intersects: self viewBox) ifFalse: [ 
		self inform: 'Dropped morph not in bounds'.
		aMorph position: self bounds center ].
	aMorph submorphsDo: [ :m | 
		(m isKindOf: HaloMorph) ifTrue: [ m delete ] ].
	self bringTopmostsToFront
]

{ #category : #menus }
DesktopMorph >> addStandardHaloMenuItemsTo: aMenu hand: aHandMorph [

	"Add standard halo items to the menu"

	self addWorldHaloMenuItemsTo: aMenu hand: aHandMorph
]

{ #category : #accessing }
DesktopMorph >> announcer [

	WorldAnnouncer ifNil: [ WorldAnnouncer := Announcer new ].
	^ WorldAnnouncer
]

{ #category : #cursor }
DesktopMorph >> beCursorOwner [

	owner beCursorOwner
]

{ #category : #'meta-actions' }
DesktopMorph >> buildMetaMenu: evt [

	| menu |
	menu := UIManager default newMenuIn: self for: self.
	self addStandardHaloMenuItemsTo: menu hand: evt hand.
	^ menu
]

{ #category : #'menu & halo' }
DesktopMorph >> contentsMenu: aMenu [

	"Build the menu used from PopUpContentsMenu:"

	| expanded collapsed |
	expanded := self windowsSatisfying: [ :w | w isCollapsed not ].
	collapsed := self windowsSatisfying: [ :w | w isCollapsed ].
	(expanded asSortedCollection: [ :w1 :w2 | 
		 w1 label caseInsensitiveLessOrEqual: w2 label ]) do: [ :w | 
		aMenu
			add: (self truncatedMenuLabelFor: w label)
			target: w
			selector: #activateAndForceLabelToShow.
		aMenu lastItem icon: w taskbarIcon.
		w model canDiscardEdits ifFalse: [ aMenu lastItem color: Color red ] ].
	aMenu addLine.
	(collapsed asSortedCollection: [ :w1 :w2 | 
		 w1 label caseInsensitiveLessOrEqual: w2 label ]) do: [ :w | 
		aMenu
			add: (self truncatedMenuLabelFor: w label)
			target: w
			selector: #collapseOrExpand.
		aMenu lastItem icon: w taskbarIcon.
		w model canDiscardEdits ifFalse: [ aMenu lastItem color: Color red ] ].
	aMenu addLine.
	((self submorphs reject: [ :sm | 
		  (expanded includes: sm) or: [ collapsed includes: sm ] ]) 
		 asSortedCollection: [ :w1 :w2 | 
		 w1 class name caseInsensitiveLessOrEqual: w2 class name ]) do: [ :w | 
		aMenu
			add: (self truncatedMenuLabelFor: w class name)
			target: w
			selector: #comeToFront.
		aMenu lastItem icon: w taskbarIcon ].

	^ aMenu
]

{ #category : #'menu & halo' }
DesktopMorph >> contentsMenuTitle [

	^ 'World contents' translated
]

{ #category : #'world menu' }
DesktopMorph >> discoveredWorldMenu [

	^ worldState discoveredWorldMenu
]

{ #category : #'event handling' }
DesktopMorph >> dispatchKeystroke: anEvent [

	"A keystroke was hit when no keyboard focus was set, so it is sent here to the world instead."

	| aChar ascii |
	aChar := anEvent keyCharacter.
	(ascii := aChar asciiValue) = 27 ifTrue: [ "escape key" 
		^ self invokeWorldMenuFromEscapeKey ].

	(self navigationKey: anEvent) ifTrue: [ ^ self ].

	(anEvent commandKeyPressed and: [ TextEditor cmdKeysInText ]) 
		ifTrue: [ ^ self dispatchCommandKeyInWorld: aChar event: anEvent ].

	"It was unhandled. Remember the keystroke."
	self lastKeystroke: anEvent keyString.
	self triggerEvent: #keyStroke.
	super dispatchKeystroke: anEvent
]

{ #category : #accessing }
DesktopMorph >> displayArea [

	^ owner worldState worldRenderer usableArea.
]

{ #category : #accessing }
DesktopMorph >> doOneCycle [ 

	^ owner doOneCycleNow  .
]

{ #category : #geometry }
DesktopMorph >> extent: aPoint [

	super extent: aPoint.
	owner worldState viewBox ifNotNil: [ owner worldState invalidate ]
]

{ #category : #'geometry - testing' }
DesktopMorph >> fullContainsPoint: pt [

	^ bounds containsPoint: pt
]

{ #category : #'world state' }
DesktopMorph >> haloMorphs [

	^ owner hands collect: [ :h | h halo ] thenSelect: [ :halo | halo notNil ]
]

{ #category : #initialization }
DesktopMorph >> initialize [

	| taskBarWindow |
	super initialize.
	self initializeTools.
	self color: Color veryLightGray.
	
	SystemAnnouncer uniqueInstance weak
		when: FullscreenAnnouncement
		send: #fullscreenChanged:
		to: self.
		
	MenubarMorph openInWorld: self.
	"taskBarWindow := TaskbarMorphForDesktop newWithDesktop: self.
	self addMorphFront: taskBarWindow.
	taskBarWindow intoWorld: self."
]

{ #category : #initialization }
DesktopMorph >> initializeTools [

	tools := PharoCommonTools new.
	tools world: self.
]

{ #category : #'world menu' }
DesktopMorph >> invokeWorldMenu: evt [
	"Put up the world menu, triggered by the passed-in event."
	| menu |
	
	"If the user does not want a world menu, do not invoke it."
	self class shouldShowWorldMenu ifFalse: [ ^ self ].
	
	self bringTopmostsToFront.
	"put up screen menu"
	
	(menu := self worldMenu  menuEntitled: 'World') popUpEvent: evt in: self.
	^ menu
]

{ #category : #'meta-actions' }
DesktopMorph >> isWorldMorph [

	^ true
]

{ #category : #menus }
DesktopMorph >> menubar [

	^ self submorphs detect: #isMenubar
]

{ #category : #'event handling' }
DesktopMorph >> mouseDown: evt [

	super mouseDown: evt.
	self currentWindow ifNotNil: [ :topWindow | 
		SystemWindow passivateTopWindow ]
]

{ #category : #accessing }
DesktopMorph >> scaleFactor: newScaleFactor [

	self setProperty: #scaleFactor toValue: newScaleFactor
]

{ #category : #initialization }
DesktopMorph >> tools [

	^ tools
]

{ #category : #'menu & halo' }
DesktopMorph >> truncatedMenuLabelFor: aWindowLabel [

	^ aWindowLabel truncateWithElipsisTo: 47
]

{ #category : #'halos and balloon help' }
DesktopMorph >> wantsDirectionHandles [

	^ false
]

{ #category : #'event handling' }
DesktopMorph >> wantsDropFiles: anEvent [
	"We check if the WorldMorph is configured to be able to receive droped files. During the deployment of an application this option might be disabled."
	
	^ self class allowDropFiles
]

{ #category : #private }
DesktopMorph >> wantsDroppedMorph: aMorph event: evt [
	^ true
]

{ #category : #'menu & halo' }
DesktopMorph >> wantsWindowEvent: anEvent [
	^ true
]

{ #category : #accessing }
DesktopMorph >> world [
 
	^ owner ifNil: [ ^ self  ]
]

{ #category : #'world menu' }
DesktopMorph >> worldMenu [

	| menu |
	menu := PragmaMenuBuilder pragmaKeyword: #worldMenu model: self.
	menu menuSpec.
	^ menu
]

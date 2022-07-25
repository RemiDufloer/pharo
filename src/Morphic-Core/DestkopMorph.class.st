Class {
	#name : #DestkopMorph,
	#superclass : #PasteUpMorph,
	#classInstVars : [
		'displayScaleFactor'
	],
	#category : #'Morphic-Core-Worlds'
}

{ #category : #'startup - shutdown' }
DestkopMorph class >> cleanUp [
	self currentWorld cleanseOtherworldlySteppers
]

{ #category : #setting }
DestkopMorph class >> defaultWorldColor [

	^ Color r: 0.937 g: 0.937 b: 0.937
]

{ #category : #setting }
DestkopMorph class >> displayScaleFactor [

	^ displayScaleFactor ifNil: [ displayScaleFactor := 1 ]
]

{ #category : #setting }
DestkopMorph class >> displayScaleFactor: aNumber [

	displayScaleFactor := aNumber
]

{ #category : #setting }
DestkopMorph class >> displayScaleFactorSettingsOn: aBuilder [ 
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
DestkopMorph class >> scaleFactor [
	
	^ World scaleFactor
]

{ #category : #accessing }
DestkopMorph class >> scaleFactor: aValue [
	
	World scaleFactor: aValue
]

{ #category : #operations }
DestkopMorph >> activateCursor: aCursor withMask: maskForm [

	worldState worldRenderer activateCursor: aCursor withMask: maskForm
]

{ #category : #menus }
DestkopMorph >> addStandardHaloMenuItemsTo: aMenu hand: aHandMorph [
	"Add standard halo items to the menu"

	self addWorldHaloMenuItemsTo: aMenu hand: aHandMorph
]

{ #category : #accessing }
DestkopMorph >> announcer [
	WorldAnnouncer ifNil: [ WorldAnnouncer := Announcer new ].
	^ WorldAnnouncer
]

{ #category : #cursor }
DestkopMorph >> beCursorOwner [
	owner beCursorOwner 
]

{ #category : #initialization }
DestkopMorph >> becomeActiveDuring: aBlock [
	"Make the receiver the ActiveWorld during the evaluation of aBlock.
	Note that this method does deliberately *not* use #ensure: to prevent
	re-installation of the world on project switches."

	| priorWorld |
	priorWorld := ActiveWorld.
	ActiveWorld := owner.
	aBlock
		on: Error
		do: [ :ex | 
			ActiveWorld := priorWorld.
			ex pass ]
]

{ #category : #'meta-actions' }
DestkopMorph >> buildMetaMenu: evt [
	| menu |
	menu := UIManager default newMenuIn: self for: self.
	self addStandardHaloMenuItemsTo: menu hand: evt hand.
	^ menu
]

{ #category : #'menu & halo' }
DestkopMorph >> contentsMenu: aMenu [
	"Build the menu used from PopUpContentsMenu:"

	| expanded collapsed |
	expanded := self windowsSatisfying: [ :w | w isCollapsed not ].
	collapsed := self windowsSatisfying: [ :w | w isCollapsed ].
	(expanded asSortedCollection: [ :w1 :w2 | w1 label caseInsensitiveLessOrEqual: w2 label ])
		do: [ :w | 
			aMenu add: (self truncatedMenuLabelFor: w label) target: w selector: #activateAndForceLabelToShow.
			aMenu lastItem icon: w taskbarIcon.
			w model canDiscardEdits 
				ifFalse: [ aMenu lastItem color: Color red ] ].
	aMenu addLine.
	(collapsed asSortedCollection: [ :w1 :w2 | w1 label caseInsensitiveLessOrEqual: w2 label ])
		do: [ :w | 
			aMenu add: (self truncatedMenuLabelFor: w label) target: w selector: #collapseOrExpand.
			aMenu lastItem icon: w taskbarIcon.
			w model canDiscardEdits
				ifFalse: [ aMenu lastItem color: Color red ] ].
	aMenu addLine.
	((self submorphs reject: [ :sm | (expanded includes: sm) or: [ collapsed includes: sm ] ])
		asSortedCollection: [ :w1 :w2 | w1 class name caseInsensitiveLessOrEqual: w2 class name ])
		do: [ :w | 
			aMenu add: (self truncatedMenuLabelFor: w class name) target: w selector: #comeToFront.
			aMenu lastItem icon: w taskbarIcon ].
		
	^ aMenu
]

{ #category : #'menu & halo' }
DestkopMorph >> contentsMenuTitle [
	^ 'World contents' translated
]

{ #category : #'world state' }
DestkopMorph >> defaultWorldColor [
	^ self class defaultWorldColor
]

{ #category : #'menu & halo' }
DestkopMorph >> deleteBalloonTarget: aMorph [
	"Delete the balloon help targeting the given morph"

	self handsDo: [ :h | h deleteBalloonTarget: aMorph ]
]

{ #category : #'world menu' }
DestkopMorph >> discoveredWorldMenu [
	^ worldState discoveredWorldMenu
]

{ #category : #accessing }
DestkopMorph >> displayArea [

	^ owner worldState worldRenderer usableArea.
]

{ #category : #geometry }
DestkopMorph >> extent: aPoint [
	super extent: aPoint.
	owner worldState  viewBox ifNotNil: [ 
		owner worldState invalidate ]
]

{ #category : #'geometry - testing' }
DestkopMorph >> fullContainsPoint: pt [
	^bounds containsPoint: pt
]

{ #category : #'world state' }
DestkopMorph >> haloMorphs [

	^ owner hands collect: [ :h | h halo ] thenSelect: [ :halo | halo notNil ]
]

{ #category : #initialization }
DestkopMorph >> initialize [ 
 	| taskBarWindow |
	super initialize.
	SystemAnnouncer uniqueInstance weak when: FullscreenAnnouncement send: #fullscreenChanged: to: self.
	MenubarMorph openInWorld: self.
	taskBarWindow := (TaskbarMorph  new) .
	taskBarWindow  setToAdhereToEdge: #bottomLeft.
	self addMorphFront:  taskBarWindow .
]

{ #category : #'meta-actions' }
DestkopMorph >> isWorldMorph [

	^ true
]

{ #category : #accessing }
DestkopMorph >> scaleFactor: newScaleFactor [
	self setProperty: #scaleFactor toValue: newScaleFactor
]

{ #category : #'menu & halo' }
DestkopMorph >> truncatedMenuLabelFor: aWindowLabel [
	^ aWindowLabel truncateWithElipsisTo: 47
]

{ #category : #copying }
DestkopMorph >> veryDeepCopyWith: deepCopier [
	"never copy the World"

	^ self
]

{ #category : #'halos and balloon help' }
DestkopMorph >> wantsDirectionHandles [

	^ false
]

{ #category : #'event handling' }
DestkopMorph >> wantsDropFiles: anEvent [
	"We check if the WorldMorph is configured to be able to receive droped files. During the deployment of an application this option might be disabled."
	
	^ self class allowDropFiles
]

{ #category : #private }
DestkopMorph >> wantsDroppedMorph: aMorph event: evt [
	
	^ true
]

{ #category : #'menu & halo' }
DestkopMorph >> wantsWindowEvent: anEvent [
	^ true
]

{ #category : #'world menu' }
DestkopMorph >> worldMenu [
	
	^ owner worldState  worldMenu
]

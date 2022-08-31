"
The state of a Morphic world.  (This needs some serious commenting!!)


The MinCycleLapse variable holds the minimum amount of time that a morphic cycle is allowed to take.  If a cycle takes less than this, then interCyclePause: will wait until the full time has been used up.
"
Class {
	#name : #WorldState,
	#superclass : #Object,
	#instVars : [
		'hands',
		'damageRecorder',
		'stepList',
		'lastStepTime',
		'lastStepMessage',
		'alarms',
		'lastAlarmTime',
		'activeHand',
		'currentCursor',
		'worldRenderer',
		'realWindowExtent'
	],
	#classVars : [
		'CanSurrenderToOS',
		'DebugShowDamage',
		'DeferredUIMessages',
		'DesktopMenuPragmaKeyword',
		'DesktopMenuTitle',
		'EasySelectingWorld',
		'LastCycleTime',
		'MinCycleLapse',
		'ServerMode',
		'ShowUpdateOptionInWorldMenu'
	],
	#category : #'Morphic-Worlds'
}

{ #category : #accessing }
WorldState class >> MinCycleLapse: milliseconds [
	"set the minimum amount of time that may transpire between two calls to doOneCycle"
	MinCycleLapse := milliseconds ifNotNil: [ milliseconds rounded ].
]

{ #category : #'deferred message' }
WorldState class >> addDeferredUIMessage: aValuable [
	"aValuable will be executed in the next UI rendering cycle"
	self deferredUIMessages nextPut: aValuable
]

{ #category : #'world menu' }
WorldState class >> browseWorldMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Browse)
		order: 10;
		help: 'Tools to explore and modify the image';
		with: [ 
			(aBuilder group: #Browsing)
				order: 1;
				withSeparatorAfter.
			(aBuilder group: #InputOutput)
				order: 2;
				withSeparatorAfter.
			(aBuilder group: #Testing)
				order: 3;
				withSeparatorAfter.
			(aBuilder group: #Searching)
				order: 4]
]

{ #category : #'testing os' }
WorldState class >> canSurrenderToOS: aBoolean [

	CanSurrenderToOS := aBoolean
]

{ #category : #accessing }
WorldState class >> debugShowDamage [
	^ DebugShowDamage ifNil: [DebugShowDamage := false]
]

{ #category : #accessing }
WorldState class >> debugShowDamage: aBoolean [
	DebugShowDamage := aBoolean
]

{ #category : #'world menu' }
WorldState class >> debugWorldMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Debug)
		order: 30;
		with: [
			(aBuilder group: #Breakpoints)
				order: 1;
				withSeparatorAfter.
			(aBuilder group: #Profiling)
				order: 2;
				withSeparatorAfter.
			(aBuilder group: #Counters)
				order: 3]
]

{ #category : #'deferred message' }
WorldState class >> defer: aValuable [
	"aValuable will be executed in the next UI rendering cycle"
	self addDeferredUIMessage: aValuable.
]

{ #category : #'deferred message' }
WorldState class >> deferredUIMessages [

	^DeferredUIMessages ifNil: [DeferredUIMessages := WaitfreeQueue  new].
]

{ #category : #settings }
WorldState class >> desktopMenuPragmaKeyword [
	"For compatibility with settings"
	
	^ self discoveredMenuPragmaKeyword
]

{ #category : #settings }
WorldState class >> desktopMenuPragmaKeyword: aString [
	DesktopMenuPragmaKeyword := aString
]

{ #category : #settings }
WorldState class >> desktopMenuTitle: aString [
	DesktopMenuTitle := aString
]

{ #category : #settings }
WorldState class >> discoveredMenuPragmaKeyword [
	^ DesktopMenuPragmaKeyword ifNil: [DesktopMenuPragmaKeyword := 'worldMenu']
]

{ #category : #settings }
WorldState class >> discoveredMenuTitle [
	^ DesktopMenuTitle ifNil: [DesktopMenuTitle := 'World']
]

{ #category : #'drawing cycle' }
WorldState class >> doDrawCycleWith: aBlock [
	aBlock ensure: [
		self doInterCycleWait
	]
]

{ #category : #'drawing cycle' }
WorldState class >> doInterCycleWait [
	| waitTime newCycleTime |
	newCycleTime := Time millisecondClockValue.
	waitTime := self serverMode
		ifTrue: [ 50 ]
		ifFalse: [
			| expectedEndTime lapse |
			lapse := self interCycleLapse.
			expectedEndTime := self lastDrawCycleTime + self interCycleLapse.
			"This minimum is required to prevent freezing the system during startup.
			The times two in the lapse is to allow some slack due to precision issues."
			expectedEndTime - newCycleTime min: (lapse*2).
		].
	waitTime > 0 ifTrue: [ (Delay forMilliseconds: waitTime) wait ].
	LastCycleTime := newCycleTime.
]

{ #category : #settings }
WorldState class >> easySelectingWorld [
	^ EasySelectingWorld ifNil: [EasySelectingWorld := false]
]

{ #category : #settings }
WorldState class >> easySelectingWorld: aBoolean [
	EasySelectingWorld := aBoolean
]

{ #category : #'world menu items' }
WorldState class >> helpOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Help)
		order: 99;
		help: 'Some help tools on Pharo.';
		with: [
			(aBuilder group: #HelpBrowser)
				order: 1;
				withSeparatorAfter.
			(aBuilder group: #PharoHelp)
				order: 2;
				withSeparatorAfter.
			(aBuilder item: #'About...')
				order: 99;
				iconName: #smallInfo;
				help: 'Informations about this version of Pharo.';
				action: [ Smalltalk aboutThisSystem ] ]
]

{ #category : #'class initialization' }
WorldState class >> initialize [
	"WorldState initialize"

	MinCycleLapse := 16.		"allows 60 frames per second..."
	DeferredUIMessages := nil.
]

{ #category : #'drawing cycle' }
WorldState class >> interCycleLapse [
	^ MinCycleLapse ifNil: [ MinCycleLapse := 16 ]
]

{ #category : #accessing }
WorldState class >> lastCycleTime [

	^LastCycleTime
]

{ #category : #'drawing cycle' }
WorldState class >> lastDrawCycleTime [
	^ LastCycleTime ifNil: [ LastCycleTime := Time millisecondClockValue ]
]

{ #category : #'world menu' }
WorldState class >> libraryWorldMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Tools)
		label: 'Library';
		order: 70;
		help: 'Third party tools and applications'
]

{ #category : #'world menu items' }
WorldState class >> mostUsedToolsOn: aBuilder [

	(aBuilder item: #Tools)
		withSeparatorAfter;
		order: 1
]

{ #category : #'world menu items' }
WorldState class >> pharoItemsOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Pharo)
		label: 'Pharo';
		icon: ((self iconNamed: #pharo) scaledToSize: 16 @ 16);
		order: 0;
		with: [
			(aBuilder group: #Saving)
				order: 98;
				with: [
					(aBuilder item: #Save)
						target: self;
						selector: #saveSession;
						help: 'Save the current version of the image on disk.';
						order: 1;
						keyText: 'S';
						iconName: #smallSaveIcon.
					(aBuilder item: #'Save as...')
						target: self;
						selector: #saveAs;
						help: 'Save the current version of the image on disk under a new name.';
						order: 2;
						iconName: #smallSaveAsIcon.
					(aBuilder item: #'Save and quit')
						target: self;
						selector: #saveAndQuit;
						help: 'Save the current image on disk, and quit Pharo.';
						order: 3;
						iconName: #smallQuitIcon.
					aBuilder	withSeparatorAfter ]. 
				(aBuilder item: #Quit)
					target: self;
					selector: #quitSession;
					help: 'Quit Pharo without saving the image on disk.';
					order: 99;
					iconName: #smallQuitIcon ]
]

{ #category : #'world menu items' }
WorldState class >> quitSession [
	| response |
	response := UIManager default 
						confirm: 'Save changes before quitting?' 
						trueChoice: 'Save' 
						falseChoice: 'Discard' 
						cancelChoice: 'Cancel'
						default: nil. 
	response ifNil: [ ^self ].
	response 
		ifTrue: [Smalltalk snapshot: true andQuit: true] 
		ifFalse: [Smalltalk snapshot: false andQuit: true]
]

{ #category : #'world menu items' }
WorldState class >> saveAndQuit [
	Cursor write showWhile: [
		Smalltalk snapshot: true andQuit: true
	]
]

{ #category : #'world menu items' }
WorldState class >> saveAs [
	| reference |
	reference := UIManager default
		chooseForSaveFileReference: 'Save Image as?'
		extensions: #('image') 
		path: Smalltalk imageFile nextVersion.

	reference ifNotNil: [ Smalltalk saveAs: reference parent / (reference basenameWithoutExtension: 'image') ]
]

{ #category : #'world menu items' }
WorldState class >> saveSession [
	Cursor write showWhile: [
		Smalltalk
			snapshot: true
			andQuit: false.
	]
]

{ #category : #'world menu items' }
WorldState class >> screenShotCommandOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Screenshot)
		parent: #System;
		target: aBuilder model world ;
		order: 99;
		selector: #makeAScreenshot;
		label: 'Screenshot';
		help: 'Take a screenshot';
		iconName: #smallScreenshotIcon
]

{ #category : #settings }
WorldState class >> serverMode [
	^ ServerMode ifNil: [ServerMode := false]
]

{ #category : #settings }
WorldState class >> serverMode: aBoolean [
	(aBoolean = true or: [aBoolean = false or: [aBoolean isNil]])
		ifTrue: [ServerMode := aBoolean]
]

{ #category : #settings }
WorldState class >> showUpdateOptionInWorldMenu [
	^ ShowUpdateOptionInWorldMenu ifNil: [ShowUpdateOptionInWorldMenu := true]
]

{ #category : #settings }
WorldState class >> showUpdateOptionInWorldMenu: aBoolean [
	ShowUpdateOptionInWorldMenu := aBoolean
]

{ #category : #'world menu' }
WorldState class >> sourcesWorldMenuOn: aBuilder [
	<worldMenu>
	(aBuilder item: #Sources)
		order: 50;
		help: 'Source Management Tools';
		with: [ 
			(aBuilder group: #Versioning)
				order: 1;
				withSeparatorAfter.
			(aBuilder group: #Packaging)
				order: 2;
				withSeparatorAfter.
			(aBuilder group: #Changes)
				order: 3;
				withSeparatorAfter.
			(aBuilder group: #Refactoring)
				order: 4 ]
]

{ #category : #'world menu' }
WorldState class >> startMessageTallyInWorld: aWorld [

	(self confirm: 'MessageTally will start now,
and stop when the cursor goes
to the top of the screen' translated) 
		ifFalse: [ ^ self ].

	TimeProfiler spyAllOn: [
		MorphicRenderLoop new doOneCycleWhile: [ 
			 aWorld  activeHand position y > 0 ] ]
]

{ #category : #'world menu' }
WorldState class >> startThenBrowseMessageTallyInWorld: aWorld [
	"Tally only the UI process"
	
	(self confirm: 'MessageTally the UI process until the
mouse pointer goes to the top of the screen')
		ifFalse: [ ^ self ].

	TimeProfiler onBlock: [
		MorphicRenderLoop new doOneCycleWhile: [ 
			aWorld  activeHand position y > 10 ] ]
]

{ #category : #'world menu' }
WorldState class >> systemOn: aBuilder [

	<worldMenu>
	| world |
	world := aBuilder model world.
	(aBuilder item: #System)
		order: 60;
		with: [ 
			(aBuilder group: #SystemTools)
				order: 1;
				withSeparatorAfter.
			(aBuilder group: #Startup)
				order: 2;
				withSeparatorAfter.
			(aBuilder group: #Image)
				order: 3;
				with: [ 
					(aBuilder item: #'Space left')
						help:
							'Do a garbage collection, and report results about the to the user.';
						order: 1;
						action: [ Smalltalk informSpaceLeftAfterGarbageCollection ].
					(aBuilder item: #'Do Image Cleanup')
						help:
							'Clean out any caches and other state that should be flushed when trying to get an image into a pristine state.';
						order: 2;
						action: [ Smalltalk cleanUp: true ].
					aBuilder withSeparatorAfter ].
			(aBuilder group: #World)
				order: 4;
				with: [ 
					(aBuilder item: #'Start drawing again')
						help: 'Resume the drawing after a draw error of the world.';
						order: 1;
						action: [ world resumeAfterDrawError ].
					(aBuilder item: #'Start stepping again')
						help: 'Resume stepping of Morph after an error has occured.';
						order: 2;
						action: [ world resumeAfterStepError ].
					(aBuilder item: #'Restore display')
						help: 'Restore Morphic display.';
						order: 3;
						action: [ world restoreMorphicDisplay ].
					aBuilder withSeparatorAfter ] ]
]

{ #category : #accessing }
WorldState class >> theme [
	^ Smalltalk ui theme
]

{ #category : #'world menu' }
WorldState class >> windowsOn: aBuilder [

	<worldMenu>
	| world |
	world := aBuilder model world.
	(aBuilder item: #Windows)
		order: 90;
		with: [ 
			(aBuilder item: #'Collapse all windows')
				action: [ world collapseAll ];
				help:
					'Reduce all open windows to collapsed forms that only show titles'
						translated.
			(aBuilder item: #'Expand all windows')
				iconName: #expandBoxIcon;
				action: [ world expandAll ];
				help:
					'Expand all collapsed windows back to their expanded forms'
						translated.
			(aBuilder item: #'Fit all windows')
				action: [ world fitAllVisibleWindows ];
				help: 'Fit all open windows as visible in World' translated.
			(aBuilder item: #'Close all debuggers')
				help: 'Close all opened debugger in the image.';
				action: [ OupsDebuggerSystem closeAllDebuggers ].
			(aBuilder item: #'Send top window to back (\)')
				action: [ SystemWindow sendTopWindowToBack ];
				help:
					'Make the topmost window become the backmost one, and activate the window just beneath it.'
						translated.
			(aBuilder item: #'Move windows onscreen')
				action: [ world bringWindowsFullOnscreen ];
				help: 'Make all windows fully visible on the screen' translated.
			(aBuilder item: #'Delete unchanged windows')
				action: [ world closeUnchangedWindows ];
				help:
					'Deletes all windows that do not have unsaved text edits.'
						translated.
			(aBuilder item: #'Delete all windows discarding edits')
				action: [ world closeAllWindowsDiscardingChanges ];
				help:
					'Deletes all windows even if they have unsaved text edits.'
						translated.
			(aBuilder item: #'Toggle full screen mode')
				action: [ Display toggleFullscreen ];
				help:
					'Turn full screen mode on when it is off, off when it is on.'
						translated ]
]

{ #category : #settings }
WorldState class >> worldMenuSettingOn: aBuilder [
	<systemsettings>
	(aBuilder setting: #desktopMenuPragmaKeyword)
		label: 'World menu pragma';
		ghostHelp: 'worldMenu';
		parent: #morphic;
		default: 'worldMenu';
		target: self;
		description: 'Define whitch pragma should be used to build the world menu. To disable the world menu, leave this input empty.'
]

{ #category : #settings }
WorldState class >> worldStateDebuggingSettingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #world)
		label: 'World state';
		parent: #debugging;
		description: 'World state debugging settings';
		with: [ 
			(aBuilder setting: #debugShowDamage)
				label: 'Flash damaged morphic region';
				target: WorldState;
				default: false;
				description:
					'If true, every changed region of the morphic display will be flashed black before updating.' ]
]

{ #category : #hands }
WorldState >> activeHand [
	^ activeHand
]

{ #category : #hands }
WorldState >> activeHand: aHand [
	activeHand := aHand
]

{ #category : #'events - alarms' }
WorldState >> addAlarm: aSelector withArguments: argArray for: aTarget at: scheduledTime [
	"Add a new alarm with the given set of parameters"
	self alarms add: 
		(MorphicAlarm 
			scheduledAt: scheduledTime
			receiver: aTarget
			selector: aSelector
			arguments: argArray).
]

{ #category : #hands }
WorldState >> addHand: aHandMorph [
	"Add the given hand to the list of hands for this world."

	hands := (hands copyWithout: aHandMorph) copyWith: aHandMorph.
]

{ #category : #alarms }
WorldState >> adjustAlarmTimes: nowTime [
	"Adjust the alarm times after some clock weirdness (such as roll-over, image-startup etc)"
	| deltaTime |
	deltaTime := nowTime - lastAlarmTime.
	self alarms do:[:alarm| alarm scheduledTime: alarm scheduledTime + deltaTime].
]

{ #category : #stepping }
WorldState >> adjustWakeupTimes: now [
	"Fix the wakeup times in my step list. This is necessary when this world has been restarted after a pause, say because some other view had control, after a snapshot, or because the millisecond clock has wrapped around. (The latter is a rare occurrence with a 32-bit clock!)"
	| deltaTime |
	deltaTime := now - lastStepTime.
	stepList do:[:entry| entry scheduledTime: entry scheduledTime + deltaTime].
	lastStepTime := now.
]

{ #category : #stepping }
WorldState >> adjustWakeupTimesIfNecessary [
	"Fix the wakeup times in my step list if necessary. This is needed after a snapshot, after a long pause (say because some other view had control or because the user was selecting from an MVC-style menu) or when the millisecond clock wraps around (a very rare occurrence with a 32-bit clock!)."

	| now |
	now := Time millisecondClockValue.
	((now < lastStepTime) or: [(now - lastStepTime) > 5000])
		 ifTrue: [self adjustWakeupTimes: now].  "clock slipped"
]

{ #category : #alarms }
WorldState >> alarmSortBlock [
	^[ :alarm1 :alarm2 | 
		alarm1 scheduledTime < alarm2 scheduledTime.
	]
]

{ #category : #alarms }
WorldState >> alarms [

	^alarms ifNil: [alarms := Heap sortBlock: self alarmSortBlock]
]

{ #category : #'update cycle' }
WorldState >> checkIfUpdateNeeded [

	damageRecorder updateIsNeeded ifTrue: [ ^true ].
		
	hands do: [:h | 
		(h hasChanged and: [h needsToBeDrawn]) ifTrue: [^true]].
	^false  "display is already up-to-date"
]

{ #category : #cleaning }
WorldState >> cleanStepList [
	"ensure that we have a cleaner block"
	^stepList sortBlock: self stepListSortBlock
]

{ #category : #stepping }
WorldState >> cleanseStepListForWorld: aWorld [
	"Remove morphs from the step list that are not in this World"

	| deletions morphToStep |
	deletions := nil.
	stepList do: [:entry |
		morphToStep := entry receiver.
		morphToStep world == aWorld ifFalse:[
			deletions ifNil: [deletions := OrderedCollection new].
			deletions addLast: entry]].

	deletions ifNotNil:[
		deletions do: [:entry|
			self stopStepping: entry receiver]].

	self alarms copy do:[:entry|
		morphToStep := entry receiver.
		(morphToStep isMorph and:[morphToStep world == aWorld]) 
			ifFalse:[self removeAlarm: entry selector for: entry receiver]].
]

{ #category : #'object filein' }
WorldState >> convertAlarms [
	
	alarms ifNotNil: [alarms sortBlock: self alarmSortBlock].	"ensure cleaner block"
]

{ #category : #accessing }
WorldState >> currentCursor [
	^ currentCursor
]

{ #category : #accessing }
WorldState >> currentCursor: anObject [
	currentCursor := anObject
]

{ #category : #accessing }
WorldState >> damageRecorder [

	^ damageRecorder
]

{ #category : #'deferred message' }
WorldState >> defer: aValuable [
	"aValuable will be executed in the next UI rendering cycle"
	self class defer: aValuable
]

{ #category : #'worldmenu building' }
WorldState >> discoveredMenuOn: aBuilder [

	^ aBuilder menuEntitled: self discoveredMenuTitle
]

{ #category : #settings }
WorldState >> discoveredMenuPragmaKeyword [
	^ self class discoveredMenuPragmaKeyword
]

{ #category : #settings }
WorldState >> discoveredMenuTitle [
	^ self class discoveredMenuTitle
]

{ #category : #'update cycle' }
WorldState >> displayWorld: aWorld [
	"Update this world's display."

	worldRenderer displayWorldState: self ofWorld: aWorld
]

{ #category : #'update cycle' }
WorldState >> displayWorldSafely: aWorld [
	"Update this world's display and keep track of errors during draw methods."

	[aWorld displayWorld] onErrorDo: [:err |
		"Handle a drawing error"
		| errCtx errMorph |
		errCtx := thisContext.
		[
			errCtx := errCtx sender.
			"Search the sender chain to find the morph causing the problem"
			[errCtx notNil and:[(errCtx receiver isMorph) not]] 
				whileTrue:[errCtx := errCtx sender].
			"If we're at the root of the context chain then we have a fatal drawing problem"
			errCtx ifNil:[^self handleFatalDrawingError: err description].
			errMorph := errCtx receiver.
			"If the morph causing the problem has already the #drawError flag set,
			then search for the next morph above in the caller chain."
			errMorph hasProperty: #errorOnDraw
		] whileTrue.
		errMorph setProperty: #errorOnDraw toValue: true.
		"Install the old error handler, so we can re-raise the error"
		err signal.
	].
]

{ #category : #canvas }
WorldState >> doFullRepaint [

	damageRecorder doFullRepaint
]

{ #category : #'update cycle' }
WorldState >> doOneCycleFor: aWorld [
	"Immediately do one cycle of the interaction loop.
	This should not be called directly, but only via doOneCycleFor:"

	self worldRenderer checkForNewScreenSize.

	"process user input events"
	self handsDo: [:h |
		self activeHand: h.
		h processEvents.
		self activeHand: nil.
	].

	"the default is the primary hand"
	self activeHand: self hands first.

	aWorld runStepMethods.		"there are currently some variations here"
	self displayWorldSafely: aWorld.
]

{ #category : #'update cycle' }
WorldState >> drawWorld: aWorld submorphs: submorphs invalidAreasOn: aCanvas [ 
	"Redraw the damaged areas of the given canvas and clear the damage list. Return a collection of the areas that
were redrawn."

	| rectList n morphs rects validList |
	rectList := damageRecorder invalidRectsFullBounds: aWorld viewBox.
	"sort by areas to draw largest portions first"
	rectList := rectList asArray sort: [:r1 :r2 | r1 area > r2 area].
	damageRecorder reset.
	n := submorphs size.
	morphs := OrderedCollection new: n * 2.
	rects := OrderedCollection new: n * 2.
	validList := OrderedCollection new: n * 2.
	rectList do: 
			[:dirtyRect | 
			dirtyRect allAreasOutsideList: validList
				do: 
					[:r | | mm rect i c remnantIntersects remnants rectToFill | 
					"Experimental top-down drawing --
			Traverses top to bottom, stopping if the entire area is filled.
			If only a single rectangle remains, then continue with the reduced rectangle."

					rectToFill := r.
					remnants := OrderedCollection with: r.
					i := 1.
					[remnants isEmpty or: [i > n]] whileFalse: 
							[mm := submorphs at: i.
							((remnantIntersects := remnants select: [:each | (mm fullBounds intersects: each)]) notEmpty and: [mm visible]) 
								ifTrue: 
									[morphs addLast: mm.
									
									rects addLast: (Rectangle merging: (remnantIntersects collect: [:each | mm fullBounds intersect: each])).
									remnants removeAll: remnantIntersects.
									remnantIntersects do: [:eachIntersect | remnants addAll: (mm areasRemainingToFill: eachIntersect)].
									remnants size = 1 ifTrue: [rectToFill := remnants first].
									remnants isEmpty ifTrue: [rectToFill := nil]].
							i := i + 1].
					"Now paint from bottom to top, but using the reduced rectangles."
					rectToFill 
						ifNotNil: [aWorld drawOn: (c := aCanvas copyClipRect: rectToFill)].
					[morphs isEmpty] whileFalse: 
							[(rect := rects removeLast) == rectToFill 
								ifFalse: [c := aCanvas copyClipRect: (rectToFill := rect)].
							c fullDrawMorph: morphs removeLast].
					morphs reset.
					rects reset.
					validList add: r]].
	^validList
]

{ #category : #'worldmenu building' }
WorldState >> fallbackMenuOn: menu [
	"Build the menu that is put up if something is going wrong with the menubuilder"
	
	menu addTitle: 'Fallback menu'.
	menu commandKeyHandler: self.
	menu addLine.
	menu
		defaultTarget: Smalltalk tools;
		addList: Smalltalk tools menuItems.
	menu addLine.
	menu add: 'Save'
		target: self class
		selector: #saveSession.
	menu add: 'Save as...'
		target: self class
		selector: #saveAs.
	menu add: 'Save and quit' 
		target: self class
		selector: #saveAndQuit.
	menu add: 'Quit' 
		target: self class
		selector: #quitSession.
]

{ #category : #'update cycle' }
WorldState >> handleFatalDrawingError: errMsg [
	"Handle a fatal drawing error."
	self worldRenderer deferUpdates: false. "Just in case"
	self primitiveError: errMsg.

	"Hm... we should jump into a 'safe' worldState here, but how do we find it?!"
]

{ #category : #hands }
WorldState >> hands [

	^ hands
]

{ #category : #hands }
WorldState >> handsDo: aBlock [

	^ hands do: aBlock
]

{ #category : #hands }
WorldState >> handsReverseDo: aBlock [

	^ hands reverseDo: aBlock
]

{ #category : #accessing }
WorldState >> icon: aForm [ 

	worldRenderer icon: aForm
]

{ #category : #initialization }
WorldState >> initialize [

	super initialize.
	hands := Array new.
	damageRecorder:= DamageRecorder new.
	stepList := Heap sortBlock: self stepListSortBlock.
	lastStepTime := 0.
	lastAlarmTime := 0.
]

{ #category : #canvas }
WorldState >> invalidate [
	self worldRenderer invalidate.
	damageRecorder 
		ifNil: [damageRecorder := DamageRecorder new]
		ifNotNil: [damageRecorder doFullRepaint]
]

{ #category : #hands }
WorldState >> is: hand overlappingDamagedAreaIn: damageList [
	| handBounds |
	handBounds := hand fullBounds.
	^ damageList anySatisfy: [ :r | r intersects: handBounds ]
]

{ #category : #settings }
WorldState >> isEasySelecting [
	^ self class easySelectingWorld
]

{ #category : #stepping }
WorldState >> isStepping: aMorph [
	"Return true if the given morph is in the step list."
	lastStepMessage ifNotNil:[(lastStepMessage receiver == aMorph) ifTrue:[^true]].
	stepList do:[:entry| entry receiver == aMorph ifTrue:[^true]].
	^ false
]

{ #category : #stepping }
WorldState >> isStepping: aMorph selector: aSelector [
	"Return true if the given morph is in the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph and:[lastStepMessage selector == aSelector])
			ifTrue:[^true]].
	stepList do:[:entry| (entry receiver == aMorph and:[entry selector == aSelector]) ifTrue:[^true]].
	^ false
]

{ #category : #stepping }
WorldState >> listOfSteppingMorphs [
	^stepList collect:[:entry| entry receiver].
]

{ #category : #'world menu' }
WorldState >> menuBuilder [

	^ (PragmaMenuBuilder
		   pragmaKeyword: self discoveredMenuPragmaKeyword
		   model: self)
		  menuSpec;
		  yourself
]

{ #category : #hands }
WorldState >> realWindowExtent [

	^ realWindowExtent
]

{ #category : #hands }
WorldState >> realWindowExtent: aValue [

	realWindowExtent := aValue
]

{ #category : #canvas }
WorldState >> recordDamagedRect: damageRect [

	damageRecorder ifNotNil: [damageRecorder recordInvalidRect: damageRect truncated]
]

{ #category : #alarms }
WorldState >> removeAlarm: aSelector for: aTarget [
	"Remove the alarm with the given selector"

	self alarms
		detect: [ :any | any receiver == aTarget and: [ any selector == aSelector ] ]
		ifFound: [ :alarm | self alarms remove: alarm ]
]

{ #category : #hands }
WorldState >> removeHand: aHandMorph [
	"Remove the given hand from the list of hands for this world."

	(hands includes: aHandMorph) ifFalse: [^self].
	hands := hands copyWithout: aHandMorph.
	activeHand == aHandMorph ifTrue: [activeHand := nil].
]

{ #category : #canvas }
WorldState >> resetDamageRecorder [

	damageRecorder reset
]

{ #category : #stepping }
WorldState >> runLocalStepMethodsIn: aWorld [ 
	"Run morph 'step' methods (LOCAL TO THIS WORLD) whose time has come. Purge any morphs that are no longer in this world.
	ar 3/13/1999: Remove buggy morphs from the step list so that they don't raise repeated errors."

	| now morphToStep stepTime priorWorld |
	now := Time millisecondClockValue.
	priorWorld := ActiveWorld.
	ActiveWorld := aWorld.

	self triggerAlarmsBefore: now.
	stepList isEmpty 
		ifTrue: 
			[ActiveWorld := priorWorld.
			^self].
	(now < lastStepTime or: [now - lastStepTime > 5000]) 
		ifTrue: [self adjustWakeupTimes: now].	"clock slipped"
	[stepList isEmpty not and: [stepList first scheduledTime < now]] 
		whileTrue: 
			[lastStepMessage := stepList removeFirst.
			morphToStep := lastStepMessage receiver.
			(morphToStep shouldGetStepsFrom: aWorld) 
				ifTrue: 
					[lastStepMessage value: now.
					lastStepMessage ifNotNil: 
							[stepTime := lastStepMessage stepTime ifNil: [morphToStep stepTime].
							lastStepMessage scheduledTime: now + (stepTime max: 1).
							stepList add: lastStepMessage]].
			lastStepMessage := nil].
	lastStepTime := now.
	ActiveWorld := priorWorld
]

{ #category : #stepping }
WorldState >> runStepMethodsIn: aWorld [
	"Perform periodic activity inbetween event cycles"
	
	| queue nextInQueue|
	"If available dispatch some deferred UI Message"
	queue := self class deferredUIMessages.
	[(nextInQueue := queue nextOrNil) isNil]
		whileFalse: [ nextInQueue value].
	self runLocalStepMethodsIn: aWorld.
	"The multi-threaded global Transcript needs to be updated periodically and synchronously with the UI."
	Transcript stepGlobal.
]

{ #category : #hands }
WorldState >> selectHandsToDrawForDamage: damageList [
	"Select the set of hands that must be redrawn because either (a) the hand itself has changed or (b) the hand intersects some damage rectangle."

	^ hands
		select: [ :hand | hand needsToBeDrawn and: [ hand hasChanged or: [ self is: hand overlappingDamagedAreaIn: damageList ] ] ]
]

{ #category : #settings }
WorldState >> serverMode [
	^ self class serverMode
]

{ #category : #'world menu' }
WorldState >> startMessageTally [

	self class startMessageTallyInWorld: self world
]

{ #category : #alarms }
WorldState >> startStepping: aMorph at: scheduledTime selector: aSelector arguments: args stepTime: stepTime [
	"Add the given morph to the step list. Do nothing if it is already being stepped."

	self stopStepping: aMorph selector: aSelector.
	self adjustWakeupTimesIfNecessary.
	stepList add:(
		StepMessage 
			scheduledAt: scheduledTime
			stepTime: stepTime
			receiver: aMorph
			selector: aSelector
			arguments: args)
]

{ #category : #'world menu' }
WorldState >> startThenBrowseMessageTally [

	self class startThenBrowseMessageTallyInWorld: self world
]

{ #category : #initialization }
WorldState >> stepListSize [
	^ stepList size
]

{ #category : #stepping }
WorldState >> stepListSortBlock [
	^[ :stepMsg1 :stepMsg2 | 
		stepMsg1 scheduledTime <= stepMsg2 scheduledTime
	]
]

{ #category : #stepping }
WorldState >> stopStepping: aMorph [
	"Remove the given morph from the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph) ifTrue:[lastStepMessage := nil]].
	stepList removeAll: (stepList select:[:stepMsg| stepMsg receiver == aMorph]).
]

{ #category : #stepping }
WorldState >> stopStepping: aMorph selector: aSelector [
	"Remove the given morph from the step list."
	lastStepMessage ifNotNil:[
		(lastStepMessage receiver == aMorph and:[lastStepMessage selector == aSelector])
			ifTrue:[lastStepMessage := nil]].
	stepList removeAll: (stepList select:[:stepMsg| stepMsg receiver == aMorph and:[stepMsg selector == aSelector]]).
]

{ #category : #accessing }
WorldState >> tools [

	Smalltalk tools world: self worldRenderer world .
	^ Smalltalk tools
]

{ #category : #alarms }
WorldState >> triggerAlarmsBefore: nowTime [
	"Trigger all pending alarms that are to be executed before nowTime."
	| pending |
	lastAlarmTime ifNil:[lastAlarmTime := nowTime].
	(nowTime < lastAlarmTime or:[nowTime - lastAlarmTime > 10000])
		ifTrue:[self adjustAlarmTimes: nowTime].
	pending := self alarms.
	[pending isEmpty not and:[pending first scheduledTime < nowTime]]
		whileTrue:[pending removeFirst value: nowTime].
	lastAlarmTime := nowTime.
]

{ #category : #events }
WorldState >> updateToNewResolution: originalEvent [

	"We need to reset the render if the resolution changes. 
	If we don't do this the image seems blocked but as it does not refresh the window"

	self doFullRepaint.
	
	self worldRenderer updateToNewResolution.
	
	self worldRenderer checkForNewScreenSize.
]

{ #category : #canvas }
WorldState >> viewBox [

	^ self worldRenderer viewBox
]

{ #category : #accessing }
WorldState >> world [

	^ worldRenderer world
]

{ #category : #'worldmenu building' }
WorldState >> worldMenu [
	^self menuBuilder menuEntitled: self discoveredMenuTitle
]

{ #category : #hands }
WorldState >> worldRenderer [

    ^ worldRenderer ifNil: [ worldRenderer := NullWorldRenderer forWorld: MiniWorld new ]
]

{ #category : #accessing }
WorldState >> worldRenderer: anObject [

	worldRenderer := anObject.
	worldRenderer activate
]

{ #category : #accessing }
WorldState >> worldState [

	^ self
]

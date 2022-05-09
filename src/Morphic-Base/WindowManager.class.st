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
WindowManager >> deleteAWindow: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	allWindow removeAt: index.
	taskBar removeMorph: aWindow.
]

{ #category : #accessing }
WindowManager >> initialize [

	| root |
	allWindow := OrderedCollection new.
	root := MorphicRoot new.
	taskBar := TaskbarMorph new intoWorld: root world.
	root morph: taskBar
	"taskBarWindow := taskBar openInExternalWindow"
]

{ #category : #accessing }
WindowManager >> newWindowWithRoot: aMorph [

	| newWindow |
	newWindow := Window newWindow: aMorph manageBy: self.
	allWindow add: newWindow.
	taskBar addMorph: aMorph.
	taskBarWindow changed.
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
	^ ( self newWindowWithRoot: aMorph ) open
]

{ #category : #accessing }
WindowManager >> taskBar [

	^ taskBar 
]

{ #category : #accessing }
WindowManager >> windowMaximize: aSpPresenter [ 
	aSpPresenter owner maximize
]

{ #category : #accessing }
WindowManager >> windowMinimize: aSpPresenter [ 
	aSpPresenter owner minimize 
]

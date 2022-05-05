Class {
	#name : #WindowManager,
	#superclass : #Morph,
	#instVars : [
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

{ #category : #'add/remove' }
WindowManager >> deleteAWindow: aWindow [

	| index |
	index := allWindow indexOf: aWindow.
	allWindow removeAt: index.
	taskBar removeMorph: aWindow.
]

{ #category : #'add/remove' }
WindowManager >> initialize [

	allWindow := OrderedCollection new.
	taskBar := TaskbarMorph new .
	taskBarWindow := taskBar openInExternalWindow.
]

{ #category : #creation }
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

{ #category : #open }
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

{ #category : #size }
WindowManager >> windowMaximize: aSpPresenter [ 
	aSpPresenter owner maximize
]

{ #category : #size }
WindowManager >> windowMinimize: aSpPresenter [ 
	aSpPresenter owner minimize 
]

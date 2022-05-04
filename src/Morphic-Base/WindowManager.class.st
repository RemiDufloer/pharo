Class {
	#name : #WindowManager,
	#superclass : #Morph,
	#instVars : [
		'allWorld',
		'allWindowState',
		'taskBar'
	],
	#category : #'Morphic-Base'
}

{ #category : #'add/remove' }
WindowManager >> addWindow: aPresenter [ 
	
	aPresenter open.
	"taskBar  addNewItem: aPresenter adapter widget children first world.
	taskBar  openInWorld ."
	allWorld add: aPresenter adapter widget children first world.
	allWindowState add: (aPresenter ).
	
]

{ #category : #states }
WindowManager >> allWindowState [
	
	^ allWindowState
]

{ #category : #accessing }
WindowManager >> allWorld [

	^ allWorld
]

{ #category : #'add/remove' }
WindowManager >> deleteAWindow: aWindow [

	| index |
	aWindow delete.
	index := allWindowState  indexOf: aWindow .
	allWorld removeAt: ( index ).
	allWindowState removeAt: ( index )
]

{ #category : #'add/remove' }
WindowManager >> initialize [

	allWorld := OrderedCollection new.
	allWindowState := OrderedCollection new.
	taskBar :=  TaskbarMorph  new.
	"toolBar openInExternalWindow  . "
	"self addWindow: nil withWorld: self world"
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

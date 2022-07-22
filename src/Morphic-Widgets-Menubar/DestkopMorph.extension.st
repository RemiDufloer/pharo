Extension { #name : #DestkopMorph }

{ #category : #'*Morphic-Widgets-Menubar' }
DestkopMorph >> menubar [

	^ self submorphs detect: #isMenubar
]

Extension { #name : #DesktopMorph }

{ #category : #'*Morphic-Widgets-Menubar' }
DesktopMorph >> menubar [

	^ self submorphs detect: #isMenubar
]

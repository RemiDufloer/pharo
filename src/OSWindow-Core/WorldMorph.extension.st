Extension { #name : #WorldMorph }

{ #category : #'*OSWindow-Core' }
WorldMorph >> clipboardText [
	^ self worldState worldRenderer  osWindow clipboardText
]

{ #category : #'*OSWindow-Core' }
WorldMorph >> clipboardText: aString [
	^ self worldState worldRenderer clipboardText: aString
]

Extension { #name : #MorphicUIManager }

{ #category : #'*AST-Core' }
MorphicUIManager >> chooseFrom: labelList values: valueList lines: linesArray title: aString world: world [
	"Choose an item from the given list. Answer the selected item."
	
	|modalMorph|
	
	(ProvideAnswerNotification signal: aString) ifNotNil: [:answer |
		^answer].
	
	modalMorph := self modalMorph.
	^modalMorph theme  
		chooseIn: modalMorph
		title: aString
		labels: labelList
		values: valueList
		lines: linesArray
		world: world
]

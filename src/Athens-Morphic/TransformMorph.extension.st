Extension { #name : #TransformMorph }

{ #category : #'*Athens-Morphic' }
TransformMorph >> clipDuring: aBlock canvas: aCanvas [ 

	self clipSubmorphs 
		ifTrue: [ 
			aCanvas
				clipBy: self clippingBounds 
				during: aBlock ] 
		ifFalse: [ ^ aBlock value ]
]

{ #category : #'*Athens-Morphic' }
TransformMorph >> drawSubmorphsOnAthensCanvas: anAthensCanvas [
	| clip |
	clip := self clippingBounds intersect: anAthensCanvas clipRect.
	'clip' traceCr.
	anAthensCanvas
		transformBy: self transform
		withClip: clip
		in: self innerBounds
		during: [ :c | submorphs do: [ :m | m fullDrawOnAthensCanvas: c ] ]
]

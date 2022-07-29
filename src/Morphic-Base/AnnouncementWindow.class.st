Class {
	#name : #AnnouncementWindow,
	#superclass : #Announcement,
	#instVars : [
		'title'
	],
	#category : #'Morphic-Base'
}

{ #category : #accessing }
AnnouncementWindow class >> title: aString [

	^ self new title: aString.
]

{ #category : #accessing }
AnnouncementWindow >> title [

	^ title
]

{ #category : #accessing }
AnnouncementWindow >> title: aString [

	title := aString .
]

"
An alternative default handler that uses the file-list services to process files.

"
Class {
	#name : #DefaultExternalDropHandler,
	#superclass : #Object,
	#category : #'Morphic-Worlds'
}

{ #category : #initialization }
DefaultExternalDropHandler class >> initialize [
	"initialize the receiver"
	ExternalDropHandler defaultHandler: self new
]

{ #category : #initialization }
DefaultExternalDropHandler class >> unload [
	"initialize the receiver"
	ExternalDropHandler defaultHandler: nil
]

{ #category : #private }
DefaultExternalDropHandler >> chooseServiceFrom: aCollection [
	"private - choose a service from aCollection asking the user if  
	needed"
	aCollection size = 1
		ifTrue: [^ aCollection anyOne].
	^ UIManager default chooseFrom: (aCollection collect: [:each | each label]) values: aCollection.
]

{ #category : #events }
DefaultExternalDropHandler >> handle: aFileReference in: pasteUp dropEvent: anEvent [
	"the file was just droped, let's do our job"

	| fileName services theOne |
	fileName := aFileReference fullName.
	services := self servicesForFileNamed: fileName.

	"no service, default behavior"
	services isEmpty
		ifTrue: [ aFileReference inspect.
			^ self ].
	theOne := self chooseServiceFrom: services.
	theOne ifNotNil: [ theOne performServiceFor: aFileReference ]
]

{ #category : #private }
DefaultExternalDropHandler >> servicesForFileNamed: aString [ 
	"private - answer a collection of file-services for the file named  
	aString"
	| allServices |
	allServices := FileServices itemsForFile: aString.
	^ allServices
		reject: [:svc | self unwantedSelectors includes: svc selector]
]

{ #category : #private }
DefaultExternalDropHandler >> unwantedSelectors [
	"private - answer a collection well known unwanted selectors "
	^ #(#removeLineFeeds: #compressFile: )
]

"
For a code more optimize and more readable, prefer to use deny: instead of assert:equals: when you want to verify that something is false.
"
Class {
	#name : 'ReAssertWithBooleanEqualtiyRule',
	#superclass : 'ReNodeRewriteRule',
	#category : 'General-Rules-Migrated',
	#package : 'General-Rules',
	#tag : 'Migrated'
}

{ #category : 'accessing' }
ReAssertWithBooleanEqualtiyRule >> group [ 

	^ 'Optimization'
]

{ #category : 'initialization' }
ReAssertWithBooleanEqualtiyRule >> initialize [

	super initialize.
	self
		replace: 'self assert: `@expr equals: false'
		with: 'self deny: `@expr';
		replace: 'self assert: `@expr equals: true'
		with: 'self assert: `@expr';
		replace: 'self assert: `@expr identicalTo: true' 
		with: 'self assert: `@expr';
		replace: 'self assert: `@expr identicalTo: false'
		with: 'self deny: `@expr';
		replace: 'self deny: `@expr equals: false'
		with: 'self assert: `@expr';
		replace: 'self deny: `@expr equals: true' 
		with: 'self deny: `@expr';
		replace: 'self deny: `@expr identicalTo: false' 
		with: 'self assert: `@expr';
		replace: 'self deny: `@expr identicalTo: true'
		with: 'self deny: `@expr'
]

{ #category : 'accessing' }
ReAssertWithBooleanEqualtiyRule >> name [

	^ 'use deny: instead of assert:equals:'
]

Class {
	#name : #RMSTokenNotMatching,
	#superclass : #Error,
	#instVars : [
		'token'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #initialization }
RMSTokenNotMatching >> initializeToken: aToken [
	token:= aToken. 
	^ self.
]

{ #category : #initialization }
RMSTokenNotMatching >> token [ 
	^ token. 
]

Class {
	#name : #RMSTokenGenerator,
	#superclass : #Object,
	#instVars : [
		'allLetters'
	],
	#category : #'ReMobidyc-Server-Core'
}

{ #category : #accessing }
RMSTokenGenerator class >> size: anInteger [
	
	^ self new generateToken: anInteger. 
]

{ #category : #'as yet unclassified' }
RMSTokenGenerator >> generateToken: anInteger [

	^ String streamContents: [ :stream | 
		  anInteger timesRepeat: [ stream nextPutAll: allLetters atRandom ] ]
]

{ #category : #'as yet unclassified' }
RMSTokenGenerator >> getBaseString [ 
	^ ((0 to: 9) collect: #asString), ('abcdefghijklmnopqrstuvwxyz' asArray collect: #asString).
]

{ #category : #initialization }
RMSTokenGenerator >> initialize [ 
	super initialize. 
	allLetters := self getBaseString.
]

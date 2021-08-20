"
I represent a simulaton repository. My main responsability is to store registered simulations.

I'm using dictionary data structure to store registered simulations. 

Dictionary keys are simulations ID which is a RMSTokenGenerator object. 
Dictionary values are simulations informations. 


 
Internal Representation and Key Implementation Points.

   Instance Variables
	simulations:		a Dictionary object which contains all simulations.
"
Class {
	#name : #RMSRunRepository,
	#superclass : #Object,
	#instVars : [
		'lock',
		'expirationDuration',
		'lastIssuedId',
		'runs'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #adding }
RMSRunRepository >> add: aDictionary [
	self
		critical: [ | runId |
			runId := self getUniqueId.
			^ (runs
				at: runId
				put: (self newRepositoryItem: aDictionary runId: runId)) runInfo ]
]

{ #category : #accessing }
RMSRunRepository >> at: runId [
	^ self
		critical: [ self checkExpiration.
			(runs
				at: runId
				ifAbsent: [ ^ RMSRunNotFound signalWithRunId: runId ]) runInfo ]
]

{ #category : #accessing }
RMSRunRepository >> at: runId put: aDictionary token: aString [
	self
		critical: [ self
				checkExpiration;
				checkToken: aString runId: runId.
			^ (runs at: runId) merge: aDictionary ]
]

{ #category : #private }
RMSRunRepository >> checkExpiration [
	(Array
		streamContents: [ :stream | 
			runs
				keysAndValuesDo: [ :runId :item | 
					item isExpired
						ifTrue: [ stream nextPut: runId ] ] ])
		do: [ :runId | runs removeKey: runId ifAbsent: [  ] ]
]

{ #category : #private }
RMSRunRepository >> checkToken: aString runId: runId [
	aString
		=
			(runs at: runId ifAbsent: [ ^ RMSRunNotFound signalWithRunId: runId ])
				token
		ifFalse: [ ^ RMSTokenNotMatching signalWithToken: aString ]
]

{ #category : #private }
RMSRunRepository >> critical: aBlock [
	^ lock critical: aBlock
]

{ #category : #enumerating }
RMSRunRepository >> do: aBlock [
	self
		critical: [ self checkExpiration.
			runs valuesDo: [ :item | aBlock value: item runInfo ] ]
]

{ #category : #private }
RMSRunRepository >> getUniqueId [
	^ lastIssuedId := lastIssuedId + 1
]

{ #category : #initialization }
RMSRunRepository >> initialize [
	super initialize.
	lock := Semaphore forMutualExclusion.
	runs := Dictionary new.
	lastIssuedId := 0
]

{ #category : #private }
RMSRunRepository >> newRepositoryItem: aDictionary runId: aString [
	^ RMSRunRepositoryItem
		with:
			(aDictionary copy
				at: 'id' put: aString;
				yourself)
]

{ #category : #accessing }
RMSRunRepository >> remove: runId token: aString [
	self
		critical: [ self
				checkExpiration;
				checkToken: aString runId: runId.
			^ runs
				removeKey: runId
				ifAbsent: [ RMSRunNotFound signalWithRunId: runId ] ]
]

{ #category : #accessing }
RMSRunRepository >> size [
	self checkExpiration.
	^ runs size
]

{ #category : #accessing }
RMSRunRepository >> tokenAt: runId [
	^ (runs
		at: runId
		ifAbsent: [ ^ RMSRunNotFound signalWithRunId: runId ]) token
]

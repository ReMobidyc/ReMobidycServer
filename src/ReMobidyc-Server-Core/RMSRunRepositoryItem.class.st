Class {
	#name : #RMSRunRepositoryItem,
	#superclass : #Object,
	#instVars : [
		'token',
		'runInfo',
		'expirationDeadline'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #'instance creation' }
RMSRunRepositoryItem class >> with: aDictionary [
	^ self new runInfo: aDictionary
]

{ #category : #enumerating }
RMSRunRepositoryItem >> allKeysDo: aBlock [
	#('id' 'username' 'model' 'progress' 'state') do: aBlock
]

{ #category : #defaults }
RMSRunRepositoryItem >> defaultLifetime [
	^ 10 minutes
]

{ #category : #accessing }
RMSRunRepositoryItem >> expirationDeadline [
	^ expirationDeadline
]

{ #category : #accessing }
RMSRunRepositoryItem >> expirationDeadline: aDateAndTime [
	expirationDeadline := aDateAndTime
]

{ #category : #initialization }
RMSRunRepositoryItem >> initialize [
	expirationDeadline := DateAndTime now + self defaultLifetime
]

{ #category : #testing }
RMSRunRepositoryItem >> isExpired [
	^ expirationDeadline < DateAndTime now
]

{ #category : #accessing }
RMSRunRepositoryItem >> merge: aDictionary [
	self
		updatableKeysDo:
			[ :key | aDictionary at: key ifPresent: [ :value | runInfo at: key put: value ] ]
]

{ #category : #accessing }
RMSRunRepositoryItem >> runInfo [
	^ runInfo
]

{ #category : #accessing }
RMSRunRepositoryItem >> runInfo: aDictionary [
	runInfo := self sanitize: aDictionary.
	expirationDeadline := DateAndTime now + self defaultLifetime
]

{ #category : #private }
RMSRunRepositoryItem >> sanitize: aDictionary [
	| dict |
	dict := Dictionary new: aDictionary size + 4.
	self
		allKeysDo: [ :key | dict at: key put: (aDictionary at: key ifAbsent: [ '-' ]) ].
	^ dict
]

{ #category : #accessing }
RMSRunRepositoryItem >> token [
	^ token
		ifNil: [ token := String
				streamContents: [ :stream | 
					10
						timesRepeat: [ stream nextPut: '0123456789abcdefghijklmnopqrstuvwxyz' atRandom ] ] ]
]

{ #category : #accessing }
RMSRunRepositoryItem >> token: aString [
	token := aString
]

{ #category : #enumerating }
RMSRunRepositoryItem >> updatableKeysDo: aBlock [
	#('progress' 'state') do: aBlock
]

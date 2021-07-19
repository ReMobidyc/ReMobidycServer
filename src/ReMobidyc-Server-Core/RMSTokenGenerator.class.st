"
I represent a Token generator. RMSServer need token to authenticate user and also to identify a simulation. 

   One simple example is simply gorgeous.

Example: create a Token of size 10. 
```language=Pharo&caption=Beautiful&label=Fig1
   |token |
	
	token := RMSTokenGenerator size: 10. 
```


Internal Representation and Key Implementation Points.

    Instance Variables
	 allLetters:		<Object>
"
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

{ #category : #generators }
RMSTokenGenerator >> generateToken: anInteger [

	^ String streamContents: [ :stream | 
		  anInteger timesRepeat: [ stream nextPutAll: allLetters atRandom ] ]
]

{ #category : #accessing }
RMSTokenGenerator >> getBaseString [ 
	^ ((0 to: 9) collect: #asString), ('abcdefghijklmnopqrstuvwxyz' asArray collect: #asString).
]

{ #category : #initialization }
RMSTokenGenerator >> initialize [ 
	super initialize. 
	allLetters := self getBaseString.
]

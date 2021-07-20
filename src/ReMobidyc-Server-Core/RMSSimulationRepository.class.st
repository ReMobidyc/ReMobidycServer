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
	#name : #RMSSimulationRepository,
	#superclass : #Object,
	#instVars : [
		'simulations',
		'id'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #'as yet unclassified' }
RMSSimulationRepository class >> id: anId username: aUsername model: aModel progress: aProgress [
	
	^ self new id: anId; username: aUsername; model: aModel ; progress: aProgress. 
]

{ #category : #adding }
RMSSimulationRepository >> addSimulation: aDictionary [

	| simulationId |
	simulationId := self getUniqueId.
	^ simulations
		  at: simulationId
		  put: (aDictionary copyWith: #id -> simulationId)
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> checkTokenId: runId userToken: aToken [

	| simulationToken |
	simulationToken := (self getSimulationById: runId) at: 'token'.

	^ aToken = simulationToken
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> getSimulationById: simulationId [

	^ simulations
		  at: simulationId
		  ifAbsent: [ 
		  RMSSimulationNotFound signalWithSimulationId: simulationId ]
]

{ #category : #accessing }
RMSSimulationRepository >> getSimulationsValues [ 
	^ simulations values. 
]

{ #category : #accessing }
RMSSimulationRepository >> getSize [
	^ simulations size.  
]

{ #category : #adding }
RMSSimulationRepository >> getUniqueId [ 
	^ id := id + 1. 
]

{ #category : #accessing }
RMSSimulationRepository >> id [ 
	^ id. 
]

{ #category : #accessing }
RMSSimulationRepository >> id: anId [
	id := anId. 
]

{ #category : #accessing }
RMSSimulationRepository >> initialize [ 
	super initialize. 
	simulations := Dictionary new. 
	id := 0. 
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> removeSimulation: runId token: aToken [

	(self checkTokenId: runId userToken: aToken)
		ifTrue: [ 
			^ simulations
				  removeKey: runId
				  ifAbsent: [ RMSSimulationNotFound signalWithSimulationId: runId ] ]
		ifFalse: [ RMSTokenNotMatching signalWithToken: aToken ]
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> replaceSimulation: simulationId with: aDictionary [

	(self checkTokenId: simulationId userToken: (aDictionary at: 'token'))
		ifTrue: [ 
			^ simulations
				  at: simulationId
				  put: (aDictionary copyWith: #id -> simulationId) ]
		ifFalse: [ 
		RMSTokenNotMatching signalWithToken: (aDictionary at: 'token') ]
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> simulations [ 
	^ simulations 
]

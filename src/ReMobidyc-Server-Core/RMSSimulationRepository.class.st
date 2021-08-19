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
		'lastIssuedId'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #adding }
RMSSimulationRepository >> addSimulation: aDictionary [
	| simulationId |
	simulationId := self getUniqueId.
	^ simulations
		at: simulationId
		put:
			(aDictionary
				at: #id put: simulationId;
				yourself)
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> checkToken: aString runId: runIdString [
	aString = ((self getSimulationById: runIdString) at: 'token')
		ifFalse: [ ^ RMSTokenNotMatching signalWithToken: aString ]
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> getSimulationById: simulationId [
	^ simulations
		at: simulationId
		ifAbsent: [ RMSSimulationNotFound signalWithSimulationId: simulationId ]
]

{ #category : #adding }
RMSSimulationRepository >> getUniqueId [ 
	^ lastIssuedId := lastIssuedId + 1. 
]

{ #category : #accessing }
RMSSimulationRepository >> initialize [ 
	super initialize. 
	simulations := Dictionary new. 
	lastIssuedId := 0. 
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> removeSimulation: runId token: aString [
	self checkToken: aString runId: runId.
	^ simulations
		removeKey: runId
		ifAbsent: [ RMSSimulationNotFound signalWithSimulationId: runId ]
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> replaceSimulation: runId with: aDictionary [
	self checkToken: (aDictionary at: 'token') runId: runId.
	^ simulations at: runId put: (aDictionary copyWith: #id -> runId)
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> simulations [ 
	^ simulations 
]

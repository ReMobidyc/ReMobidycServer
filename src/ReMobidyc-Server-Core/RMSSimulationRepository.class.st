Class {
	#name : #RMSSimulationRepository,
	#superclass : #Object,
	#instVars : [
		'simulations',
		'id'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #adding }
RMSSimulationRepository >> addSimulation: aDictionary [

	| simulationId |
	simulationId := self getUniqueId.
	^ simulations
		  at: simulationId
		  put: (aDictionary copyWith: #id -> simulationId)
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> getSimulationById: simulationId [

	^ simulations 
		  at: simulationId
		  ifAbsent: [ RMSSimulationNotFound signalWithSimulationId: simulationId ]
]

{ #category : #accessing }
RMSSimulationRepository >> getSimulationsValues [ 
	^ simulations values. 
]

{ #category : #'as yet unclassified' }
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
RMSSimulationRepository >> removeSimulation: anId [

	^ simulations removeKey: anId ifAbsent: [ RMSSimulationNotFound signalWithSimulationId: anId ]. 
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> replaceSimulation: simulationId with: aDictionary [

	^ simulations at: simulationId put:(aDictionary copyWith: #id -> simulationId). 
	
]

{ #category : #'as yet unclassified' }
RMSSimulationRepository >> simulations [ 
	^ simulations 
]

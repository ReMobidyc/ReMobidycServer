Class {
	#name : #RMSSimulationNotFound,
	#superclass : #Error,
	#instVars : [
		'simulationId'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #signalling }
RMSSimulationNotFound class >> signalWithSimulationId: anId [

	(self new initializeSimulationId: anId) signal: 'Simulation not found', anId asString. 
]

{ #category : #initialization }
RMSSimulationNotFound >> initializeSimulationId: anId [
	simulationId := anId. 
	^ self. 
]

{ #category : #initialization }
RMSSimulationNotFound >> simulationId [ 
	^ simulationId. 
]

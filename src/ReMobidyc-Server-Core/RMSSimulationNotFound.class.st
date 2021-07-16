Class {
	#name : #RMSSimulationNotFound,
	#superclass : #Error,
	#instVars : [
		'simulationId'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #initialization }
RMSSimulationNotFound >> initializeSimulationId: anId [
	simulationId := anId. 
	^ self. 
]

{ #category : #initialization }
RMSSimulationNotFound >> simulationId [ 
	^ simulationId. 
]

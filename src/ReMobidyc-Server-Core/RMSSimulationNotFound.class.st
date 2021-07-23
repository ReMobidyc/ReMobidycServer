"
I represent an Exception, I'm raised when user wants to do a command (read, update, delete) on a simulation that does not exist yet. 
 
Internal Representation.

    Instance Variables
	runId:		<Object> a unique id.


"
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
RMSSimulationNotFound >> runId [ 
	^ simulationId. 
]

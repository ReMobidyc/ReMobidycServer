"
I represent an Exception, I'm raised when user wants to do a command (read, update, delete) on a simulation that does not exist yet. 
 
Internal Representation.

    Instance Variables
	runId:		<Object> a unique id.


"
Class {
	#name : #RMSRunNotFound,
	#superclass : #Error,
	#instVars : [
		'runId'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #signalling }
RMSRunNotFound class >> signalWithRunId: aString [
	(self new initializeRunId: aString)
		signal: 'Run not found' , aString asString
]

{ #category : #initialization }
RMSRunNotFound >> initializeRunId: aString [
	runId := aString.
	^ self
]

{ #category : #initialization }
RMSRunNotFound >> runId [ 
	^ runId. 
]

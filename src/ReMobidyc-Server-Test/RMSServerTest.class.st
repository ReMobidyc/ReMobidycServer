Class {
	#name : #RMSServerTest,
	#superclass : #TestCase,
	#instVars : [
		'server',
		'simulation1',
		'simulation2',
		'simulation3'
	],
	#category : #'ReMobidyc-Server-Test'
}

{ #category : #accessing }
RMSServerTest >> port [
 ^ 10000
]

{ #category : #initialization }
RMSServerTest >> setUp [
	Teapot stopAll.
	server:= RMSServer serveOn: self port. 
	simulation1 := { #username -> 'korede'. #model -> 'test'. #progress -> '0.1' } asDictionary. 
	simulation2 := { #username -> 'tomo'. #model -> 'sugar scape'. #progress -> '0.0' } asDictionary. 
	simulation3 := { #username -> 'gael'. #model -> 'copepod'. #progress -> '0.68' } asDictionary. 

        
]

{ #category : #tests }
RMSServerTest >> testGetSimulations [

	"add 3 simulations"

	ZnClient new
		url: self url , 'register';
		entity: (ZnEntity json: (NeoJSONWriter toString: { 
								  ('username' -> (simulation1 at:'username')).
								  ('model' -> (simulation1 at:'model')).
								  ('progress' -> (simulation1 at:'progress')) } asDictionary));
		post.

	ZnClient new
		url: self url , 'register';
		entity: (ZnEntity json: (NeoJSONWriter toString: { 
								  ('username' -> (simulation2 at:'username')).
								  ('model' ->(simulation2 at:'model')).
								  ('progress' -> (simulation2 at:'progress')) } asDictionary));
		post.

	ZnClient new
		url: self url , 'register';
		entity: (ZnEntity json: (NeoJSONWriter toString: { 
								  ('username' -> (simulation3 at:'username')).
								  ('model' -> (simulation3 at:'model')).
								  ('progress' -> (simulation3 at:'progress')) } asDictionary));
		post.

	self assert: server simulations getSize equals: 3
]

{ #category : #tests }
RMSServerTest >> testGetSpecificSimulationById [

	"add 3 simulations"

	| simulationId1 |
	ZnClient new
		url: 'http://localhost:10000/api/v0/register';
		entity: (ZnEntity json: (NeoJSONWriter toString: { 
								  ('username' -> (simulation1 at:'username')).
								  ('model' -> (simulation1 at:'model')).
								  ('progress' -> (simulation1 at:'progress')) } asDictionary));
		post.

	simulationId1 := ZnClient new
		                 url: self url , 'runs/1';
		                 get.
	simulationId1 := NeoJSONReader fromString: simulationId1.
	self assert: (simulationId1 at: #username) equals: 'korede'
]

{ #category : #accessing }
RMSServerTest >> url [
	^ 'http://localhost:', self port asString ,'/api/'. 
]

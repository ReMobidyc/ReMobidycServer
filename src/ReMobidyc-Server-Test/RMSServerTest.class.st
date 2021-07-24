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

	| simulation1JSON simulation2JSON simulation3JSON |
	simulation1JSON := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation1 at: 'username')).
				                    ('model' -> (simulation1 at: 'model')).
				                    ('progress' -> (simulation1 at: 'progress')) }
				                    asDictionary).
	simulation3JSON := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation3 at: 'username')).
				                    ('model' -> (simulation3 at: 'model')).
				                    ('progress' -> (simulation3 at: 'progress')) }
				                    asDictionary).
	simulation2JSON := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation2 at: 'username')).
				                    ('model' -> (simulation2 at: 'model')).
				                    ('progress' -> (simulation2 at: 'progress')) }
				                    asDictionary).
	ZnClient new
		url: self url , 'register';
		entity: simulation1JSON;
		post.

	ZnClient new
		url: self url , 'register';
		entity: simulation2JSON;
		post.

	ZnClient new
		url: self url , 'register';
		entity: simulation3JSON;
		post.

	self assert: server simulations getSize equals: 3
]

{ #category : #tests }
RMSServerTest >> testGetSpecificSimulationById [

	""

	| simulationId1 simulation1Data simulation1JSON |
	simulation1Data := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation1 at: 'username')).
				                    ('model' -> (simulation1 at: 'model')).
				                    ('progress' -> (simulation1 at: 'progress')) }
				                    asDictionary).
	"convert our data in JSON format to compare with the get command result"
	simulation1JSON := NeoJSONReader fromString: simulation1Data contents.


	" use register command to add simulation"
	ZnClient new
		url: 'http://localhost:10000/api/register';
		entity: simulation1Data;
		post.
	" get the simulation from our API"
	simulationId1 := ZnClient new
		                 url: self url , 'runs/1';
		                 get.
	" convert get result to JSON format"
	simulationId1 := NeoJSONReader fromString: simulationId1.

	"start comparaison"
	self
		assert: (simulationId1 at: 'username')
		equals: (simulation1JSON at: 'username').
	self
		assert: (simulationId1 at: 'model')
		equals: (simulation1JSON at: 'model').
	self
		assert: (simulationId1 at: 'progress')
		equals: (simulation1JSON at: 'progress')
]

{ #category : #tests }
RMSServerTest >> testRemoveSimulation [
	| simulationId1 simulation1Data return token |
	simulation1Data := ZnEntity
		json:
			(NeoJSONWriter
				toString:
					{('username' -> (simulation1 at: 'username')).
					('model' -> (simulation1 at: 'model')).
					('progress' -> (simulation1 at: 'progress'))} asDictionary).
	return := ZnClient new
		url: 'http://localhost:10000/api/register';
		entity: simulation1Data;
		post.

	"we get the token to use it in the put command"
	token := (NeoJSONReader fromString: return) at: 'token'.

	" delete command"
	ZnClient new
		beOneShot;
		optionAt: #autoResetEntityMethods put: #(HEAD);
		url: 'http://localhost:10000/api/runs/1';
		entity:
			(ZnEntity
				json: (NeoJSONWriter toString: {('token' -> token)} asDictionary));
		delete.

	" Get the simulation informations from our API"
	simulationId1 := NeoJSONReader
		fromString:
			(ZnClient new
				url: self url , 'runs/1';
				get).
	" Comparaisons simulation not found "
	self assert: (simulationId1 at: 'code') equals: 'NOT_FOUND'.
	self
		assert: (simulationId1 at: 'message')
		equals: 'No such simulation; 1'
]

{ #category : #tests }
RMSServerTest >> testRemoveSimulationWithBadToken [
	| simulationId1 simulation1Data simulation1JSON responseDelete |
	simulation1Data := ZnEntity
		json:
			(NeoJSONWriter
				toString:
					{('username' -> (simulation1 at: 'username')).
					('model' -> (simulation1 at: 'model')).
					('progress' -> (simulation1 at: 'progress'))} asDictionary).
	simulation1JSON := NeoJSONReader fromString: simulation1Data.
	ZnClient new
		url: 'http://localhost:10000/api/register';
		entity: simulation1Data;
		post.



	" delete command"
	responseDelete := NeoJSONReader
		fromString:
			(ZnClient new
				optionAt: #autoResetEntityMethods put: #(HEAD);
				url: 'http://localhost:10000/api/runs/1';
				entity:
					(ZnEntity
						json: (NeoJSONWriter toString: {('token' -> 'badToken')} asDictionary));
				delete).

	" Get the simulation informations from our API"
	simulationId1 := NeoJSONReader
		fromString:
			(ZnClient new
				url: self url , 'runs/1';
				get).
	" See if we get the OPERATION_DENIED result "
	self assert: (responseDelete at: 'code') equals: 'OPERATION_DENIED'.

	"Check if the simulation is still present in our API"
	self
		assert: (simulationId1 at: 'username')
		equals: (simulation1JSON at: 'username').
	self
		assert: (simulationId1 at: 'model')
		equals: (simulation1JSON at: 'model').
	self
		assert: (simulationId1 at: 'progress')
		equals: (simulation1JSON at: 'progress')
]

{ #category : #tests }
RMSServerTest >> testUpdateSimulation [

	| simulationId1 simulation1Data simulation1JSON simulationId1DataUpdate return token |
	simulation1Data := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation1 at: 'username')).
				                    ('model' -> (simulation1 at: 'model')).
				                    ('progress' -> (simulation1 at: 'progress')) }
				                    asDictionary).
	simulation1JSON := NeoJSONReader fromString: simulation1Data.

	return := ZnClient new
		          url: 'http://localhost:10000/api/register';
		          entity: simulation1Data;
		          post.

	"we get the token to use it in the put command"
	token := (NeoJSONReader fromString: return) at: 'token'.

	" Use update command "
	simulationId1DataUpdate := ZnEntity json:
		                           (NeoJSONWriter toString: { 
				                            ('username'
				                             -> (simulation1 at: 'username')).
				                            ('model' -> (simulation1 at: 'model')).
				                            ('progress' -> 1.0).
				                            ('token' -> token) } asDictionary).
	" Update progress"
	ZnClient new
		url: 'http://localhost:10000/api/runs/1';
		entity: simulationId1DataUpdate;
		put.
	" Get the simulation informations from our API"
	simulationId1 := NeoJSONReader fromString: (ZnClient new
			                  url: self url , 'runs/1';
			                  get).
	" Comparaisons "
	self
		assert: (simulationId1 at: 'username')
		equals: (simulation1JSON at: 'username').
	self
		assert: (simulationId1 at: 'model')
		equals: (simulation1JSON at: 'model').
	self assert: (simulationId1 at: 'progress') equals: 1.0
]

{ #category : #tests }
RMSServerTest >> testUpdateSimulationWithBadToken [

	| simulation1Data simulation1JSON simulationId1DataUpdate putResponse |
	simulation1Data := ZnEntity json: (NeoJSONWriter toString: { 
				                    ('username' -> (simulation1 at: 'username')).
				                    ('model' -> (simulation1 at: 'model')).
				                    ('progress' -> (simulation1 at: 'progress')) }
				                    asDictionary).
	simulation1JSON := NeoJSONReader fromString: simulation1Data.

	ZnClient new
		url: 'http://localhost:10000/api/register';
		entity: simulation1Data;
		post.


	" Use update command "
	simulationId1DataUpdate := ZnEntity json:
		                           (NeoJSONWriter toString: { 
				                            ('username'
				                             -> (simulation1 at: 'username')).
				                            ('model' -> (simulation1 at: 'model')).
				                            ('progress' -> 1.0).
				                            ('token' -> 'badToken') } asDictionary).
	" Update progress"
	putResponse := NeoJSONReader fromString: (ZnClient new
			                url: 'http://localhost:10000/api/runs/1';
			                entity: simulationId1DataUpdate;
			                put).

	" Comparaisons "
	self assert: (putResponse at: 'code') equals: 'OPERATION_DENIED'
]

{ #category : #accessing }
RMSServerTest >> url [
	^ 'http://localhost:', self port asString ,'/api/'. 
]

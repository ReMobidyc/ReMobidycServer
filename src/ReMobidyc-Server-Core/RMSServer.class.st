"
Class: RMSServer
                                                                                                    

I represent reMobidycServer REST API.

I have two endpoints:
- /register/
- /runs/


Public API commands:
- register: Allow user to register a simulation. Path : /api/register
- listing: Return the list of all simulations. Path : /api/runs
- read: Return information on a specific run designed by the runID argument. Path:/api/runs/<id:isInteger>
- update: Refresh state of a running simulation. Path : /api/runs/<id:isInteger>
- delete: Delete a specific simulation. Path: /api/runs/<id:isInteger>

For more information concerning API description please see our github wiki page : [here](https://github.com/ReMobidyc/ReMobidycServer/wiki/API-design#register-endpoint).

Create an Instance of RMSServer :
Use serveOn class message. 
```language=Pharo&caption=Beautiful&label=Fig1
   |server|
	server := RMSServer serveOn: 2222
```

Internal Representation and Key Implementation Points.

Instance Variables: 
simulations:  <Object> which is a RMSSimulationRepository object contains all registered simulations.
teapot:  <Object> Our API use teapot framework to deploy a REST API. 

Example: Add simulation using ZnClient  
```language=Pharo&caption=Beautiful&label=Fig1
   |server addedSimulation |
	server := RMSServer serveOn: 2222.
	addedSimulation := (ZnEntity json: (NeoJSONWriter toString: { 
								  ('username' -> 'korede').
								  ('model' -> 'test').
								  ('progress' -> 0.1) } asDictionary)).
	ZnClient new
		url: 'http://localhost:2222/api/register';
		entity: addedSimulation;
		post. 
```




"
Class {
	#name : #RMSServer,
	#superclass : #Object,
	#instVars : [
		'teapot',
		'simulations'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #'as yet unclassified' }
RMSServer class >> serveOn: port [

	^ self new
		  initializePort: port;
		  start
]

{ #category : #private }
RMSServer >> createSimulation: request [
	|object|
	
	object := NeoJSONReader fromString: request entity contents.
	^ { 
		  ('username' -> (object at: 'username')).
		  ('model' -> (object at: 'model')).
		  ('progress' -> (object at: 'progress')).
		  ('state' -> 'running').
		  ('token' -> (RMSTokenGenerator size:10))		
	} asDictionary
]

{ #category : #private }
RMSServer >> createSimulationForRefresh: request [
	|object|
	
	object := NeoJSONReader fromString: request entity contents.
	^ { 
		  ('username' -> (object at: 'username')).
		  ('model' -> (object at: 'model')).
		  ('progress' -> (object at: 'progress')).
		  ('state' -> 'running').
		  ('token' -> (object at:'token'))		
	} asDictionary
]

{ #category : #'as yet unclassified' }
RMSServer >> createSimulationWithoutToken: simulation [ 

	^ { 
		  ('id' -> (simulation at:'id')).
		  ('username' -> (simulation at: 'username')).
		  ('model' -> (simulation at: 'model')).
		  ('progress' -> (simulation at: 'progress')).
		  ('state' -> 'running').		
	} asDictionary
]

{ #category : #path }
RMSServer >> getSimulations: request [ 
	
		|simulationsValuesWithoutToken|
	
	simulationsValuesWithoutToken := Dictionary new. 
	simulations simulations valuesDo:[:value|  simulationsValuesWithoutToken at:(value at:'id') put:(self createSimulationWithoutToken: value) ].
	^ simulationsValuesWithoutToken values. 
	"^ simulations getSimulationsValues."
]

{ #category : #path }
RMSServer >> getSpecificSimulationById: request [

	 ^ self createSimulationWithoutToken:(simulations getSimulationById: (request at:#id)). 

]

{ #category : #initialization }
RMSServer >> initializePort: port [

	simulations := RMSSimulationRepository new.
	teapot := Teapot configure: { 
			          (#defaultOutput -> #json).
			          (#debugMode -> true).
			          (#port -> port) }.
	^ self
		  registerRoutes;
		  registerErrorHandlers;
		  yourself
]

{ #category : #'error handler' }
RMSServer >> missingParam: aKeyNotFoundError request: aZnRequest [

	^ TeaResponse badRequest body: { 
			  #code -> 'UNPROCESSABLE_ENTITY'.
			  #message -> ('Missing parameter: ' , aKeyNotFoundError key) }
			  asDictionary
]

{ #category : #private }
RMSServer >> readRequestParameters: request [
	^ NeoJSONReader fromString: request entity contents
]

{ #category : #path }
RMSServer >> refreshSimulationState: request [

	^ simulations
		  replaceSimulation: (request at: 'id')
		  with: (self createSimulationForRefresh: request)

]

{ #category : #initialization }
RMSServer >> registerErrorHandlers [

	teapot 
	exception: RMSSimulationNotFound   -> (Send message:#simulationNotFound:request: to:self);
	exception: KeyNotFound -> (Send message:#missingParam:request: to:self);
	exception: RMSTokenNotMatching ->(Send message:#tokenNotMatching:request: to:self);
	exception: Error ->(TeaResponse serverError body:{#code ->'ERROR'} asDictionary)
]

{ #category : #initialization }
RMSServer >> registerRoutes [

	teapot
		after: '/*' -> [ :req :resp | 
				resp headers at: 'Access-Control-Allow-Origin' put: '*'.
				resp headers
					at: 'Access-Control-Allow-Methods'
					put: 'POST,GET,OPTIONS,DELETE,PUT'.
				resp headers
					at: 'Access-Control-Allow-Headers'
					put: 'Content-Type,Authorization' ];
		GET: '/' -> '<h1> reMobidycServer API V0.0.1</h1>';
		output: #html;
		OPTIONS: '/api/register' -> '';
		POST: '/api/register' -> (Send message: #registerSimulation: to: self);
		GET: '/api/runs/' -> (Send message: #getSimulations: to: self);
		GET: '/api/runs/<id:IsInteger>'
			-> (Send message: #getSpecificSimulationById: to: self);
		PUT: '/api/runs/<id:IsInteger>'
			-> (Send message: #refreshSimulationState: to: self);
		DELETE: '/api/runs/<id:IsInteger>'
			-> (Send message: #removeSimulation: to: self)
]

{ #category : #path }
RMSServer >> registerSimulation: request [

	| simulation |
	simulation := simulations addSimulation: (self createSimulation: request).
	
	^ TeaResponse created
		  body: simulation;
		  location: '/runs/' , (simulation at: #id) asString
]

{ #category : #path }
RMSServer >> removeSimulation: request [
	^ simulations
		removeSimulation: (request at: 'id')
		token: ((self readRequestParameters: request) at: 'token' ifAbsent: [ nil ])
]

{ #category : #'error handler' }
RMSServer >> simulationNotFound: aSimulation request: aZnRequest [

	^ TeaResponse notFound body:{
		#code -> 'NOT_FOUND'.
		#message -> ('No such simulation; ', aSimulation runId asString)
	} asDictionary. 
]

{ #category : #accessing }
RMSServer >> simulations [
	^ simulations.
]

{ #category : #accessing }
RMSServer >> start [

	teapot start.
	^ self
]

{ #category : #accessing }
RMSServer >> stop [ 
	
	teapot stop. 
	^ self.
]

{ #category : #'error handler' }
RMSServer >> tokenNotMatching: aTokenNotMatching request: aZnRequest [ 
	
	^ TeaResponse badRequest body: { 
			  #code -> 'OPERATION_DENIED'.
			  #message -> ('Token does not match : ' , aTokenNotMatching token) }
			  asDictionary
]

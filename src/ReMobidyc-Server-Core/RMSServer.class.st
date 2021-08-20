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
		'repository'
	],
	#classVars : [
		'Current'
	],
	#category : #'ReMobidyc-Server-Core-ReMobidyc-Server-Core'
}

{ #category : #'sole instance' }
RMSServer class >> current [
	^ Current ifNil: [ Current := self new ]
]

{ #category : #defaults }
RMSServer class >> defaultPort [ 
	^ 2222
]

{ #category : #'class initialization' }
RMSServer class >> initialize [
	SessionManager default registerUserClassNamed: self name
]

{ #category : #services }
RMSServer class >> serveOn: port [
	^ self new
		initializePort: port;
		start
]

{ #category : #'class initialization' }
RMSServer class >> shutDown: quitting [
	self stop
]

{ #category : #services }
RMSServer class >> start [
	<script: 'RMSServer start'>
	^ self current
		stop;
		initializePort: self defaultPort;
		start
]

{ #category : #'class initialization' }
RMSServer class >> startUp: resuming [
	self start
]

{ #category : #services }
RMSServer class >> stop [
	<script: 'RMSServer stop'>
	^ self current stop
]

{ #category : #path }
RMSServer >> getRun: request [
	^ repository at: (request at: #id)
]

{ #category : #initialization }
RMSServer >> initializePort: port [
	repository := RMSRunRepository new.
	teapot ifNotNil: #stop.
	teapot := Teapot
		configure:
			{(#defaultOutput -> #json).
			(#debugMode -> true).
			(#port -> port)}.
	^ self
		registerRoutes;
		registerErrorHandlers;
		yourself
]

{ #category : #path }
RMSServer >> listAllRuns: request [
	^ Array
		streamContents: [ :stream | repository do: [ :dict | stream nextPut: dict ] ]
]

{ #category : #'error handler' }
RMSServer >> missingParam: aKeyNotFoundError request: aZnRequest [

	^ TeaResponse badRequest body: { 
			  #code -> 'UNPROCESSABLE_ENTITY'.
			  #message -> ('Missing parameter: ' , aKeyNotFoundError key) }
			  asDictionary
]

{ #category : #initialization }
RMSServer >> registerErrorHandlers [

	teapot 
	exception: RMSRunNotFound   -> (Send message:#simulationNotFound:request: to:self);
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
		POST: '/api/register' -> (Send message: #registerRun: to: self);
		GET: '/api/runs/' -> (Send message: #listAllRuns: to: self);
		GET: '/api/runs/<id:IsInteger>'
			-> (Send message: #getRun: to: self);
		PUT: '/api/runs/<id:IsInteger>'
			-> (Send message: #updateRun: to: self);
		DELETE: '/api/runs/<id:IsInteger>'
			-> (Send message: #removeRun: to: self)
]

{ #category : #path }
RMSServer >> registerRun: request [
	| simulation runId token |
	simulation := repository add: (self requestParams: request).
	runId := simulation at: 'id'.
	token := repository tokenAt: runId.
	^ TeaResponse created
		body:
			{('id' -> runId).
			('token' -> token)} asDictionary;
		location: '/runs/' , (simulation at: #id) asString
]

{ #category : #path }
RMSServer >> removeRun: request [
	^ repository
		remove: (request at: 'id')
		token: ((self requestParams: request) at: 'token' ifAbsent: [ nil ])
]

{ #category : #accessing }
RMSServer >> repository [
	^ repository
]

{ #category : #accessing }
RMSServer >> requestParams: request [
	^ NeoJSONReader fromString: request entity contents
]

{ #category : #'error handler' }
RMSServer >> simulationNotFound: aSimulation request: aZnRequest [

	^ TeaResponse notFound body:{
		#code -> 'NOT_FOUND'.
		#message -> ('No such simulation; ', aSimulation runId asString)
	} asDictionary. 
]

{ #category : #accessing }
RMSServer >> start [
	teapot ifNotNil: #start
]

{ #category : #accessing }
RMSServer >> stop [
	teapot ifNotNil: #stop
]

{ #category : #accessing }
RMSServer >> teapot [
	^ teapot
]

{ #category : #'error handler' }
RMSServer >> tokenNotMatching: aTokenNotMatching request: aZnRequest [ 
	
	^ TeaResponse badRequest body: { 
			  #code -> 'OPERATION_DENIED'.
			  #message -> ('Token does not match : ' , aTokenNotMatching token) }
			  asDictionary
]

{ #category : #path }
RMSServer >> updateRun: request [
	| params |
	params := self requestParams: request.
	^ repository
		at: (request at: 'id')
		put: params
		token: (params at: 'token')
]

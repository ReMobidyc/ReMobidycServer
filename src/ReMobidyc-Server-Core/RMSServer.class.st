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

{ #category : #'as yet unclassified' }
RMSServer >> createSimulation: request [
	|object|
	
	object := NeoJSONReader fromString: request entity contents.
	^ { 
		  ('username' -> (object at: 'username')).
		  ('model' -> (object at: 'model')).
		  ('progress' -> (object at: 'progress')).
		  ('state' -> 'running') } asDictionary
]

{ #category : #'as yet unclassified' }
RMSServer >> getSimulations: request [ 
	^ simulations getSimulationsValues. 
]

{ #category : #'as yet unclassified' }
RMSServer >> getSpecificSimulationById: request [
	^ simulations getSimulationById: (request at:#id). 
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

{ #category : #'as yet unclassified' }
RMSServer >> refreshSimulationState: request [
	^ simulations replaceSimulation: (request at: 'id') with: (self createSimulation: request)
]

{ #category : #'as yet unclassified' }
RMSServer >> registerErrorHandlers [

	teapot 
	exception: RMSSimulationNotFound   -> (Send message:#simulationNotFound:request: to:self)
]

{ #category : #initialization }
RMSServer >> registerRoutes [

	teapot
		GET: '/' -> '<h1> reMobidycServer API V0.0.1</h1>';output: #html;
		POST: '/api/register' -> (Send message: #registerSimulation: to: self);
		GET: '/api/runs/' -> (Send message: #getSimulations: to: self);
		GET: '/api/runs/<id:IsInteger>' -> (Send message: #getSpecificSimulationById: to: self); 
		PUT: '/api/runs/<id:IsInteger>' -> (Send message: #refreshSimulationState: to:self); 
		DELETE: '/api/runs/<id:IsInteger>' -> (Send message:#removeSimulation: to: self). 
]

{ #category : #'as yet unclassified' }
RMSServer >> registerSimulation: request [

	| simulation |
	simulation := simulations addSimulation: (self createSimulation: request).
	^ TeaResponse created
		  body: simulation;
		  location: '/runs/' , (simulation at: #id) asString
]

{ #category : #'as yet unclassified' }
RMSServer >> removeSimulation: request [

	^ simulations removeSimulation:(request at:#id). 
]

{ #category : #'as yet unclassified' }
RMSServer >> simulationNotFound: aSimulation request: aZnRequest [

	^ TeaResponse notFound body:{
		#code -> 'NOT_FOUND'.
		#message -> ('No such simulation; ', aSimulation simulationId asString)
	} asDictionary. 
]

{ #category : #accessing }
RMSServer >> simulations [
	^ simulations.
]

{ #category : #accessing }
RMSServer >> start [
	
	teapot start. 
	^self 
]

{ #category : #accessing }
RMSServer >> stop [ 
	
	teapot stop. 
	^ self.
]

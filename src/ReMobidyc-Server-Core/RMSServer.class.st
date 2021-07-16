"
I represent reMobidycServer REST API. 

I have two endpoints: 
	- /register/
	- /runs/


For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	simulations:		<Object>
	teapot:		<Object>


    Implementation Points
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

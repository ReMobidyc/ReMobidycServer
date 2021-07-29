Class {
	#name : #BaselineOfReMobidycServer,
	#superclass : #BaselineOf,
	#category : #BaselineOfReMobidycServer
}

{ #category : #baselines }
BaselineOfReMobidycServer >> baselineOf: spec [
	<baseline>
	spec
		for: #common
		do: [ spec
				baseline: 'Teapot'
					with: [ spec repository: 'github://zeroflag/Teapot/source' ];
				baseline: 'NeoJSON'
					with: [ spec repository: 'github://svenvc/NeoJSON/repository' ].
			spec
				package: 'ReMobidyc-Server-Core'
					with: [ spec requires: #('Teapot' 'NeoJSON') ];
				package: 'ReMobidyc-Server-Test'
					with: [ spec requires: #('ReMobidyc-Server-Core') ].
			spec
				group: 'default' with: #('core' 'tests');
				group: 'core' with: #('ReMobidyc-Server-Core');
				group: 'tests' with: #('ReMobidyc-Server-Test') ]
]

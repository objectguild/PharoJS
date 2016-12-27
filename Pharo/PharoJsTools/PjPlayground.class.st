"
I am a version of Playground for PharoJS bridges.
"
Class {
	#name : #PjPlayground,
	#superclass : #GTPlayground,
	#instVars : [
		'bridge',
		'bridgeVar',
		'allJavascriptGlobals',
		'page'
	],
	#category : #'PharoJsTools-Playground'
}

{ #category : #'as yet unclassified' }
PjPlayground class >> openFor: aPjBridge [
	^ self basicNew initializeWithBridge: aPjBridge
]

{ #category : #'world menu' }
PjPlayground class >> pharoJsMenuOn: aBuilder [ 
	<worldMenu>
	(aBuilder item: #PharoJsPlayground)
		label: 'PharoJs Playground';
		target: PjPlayground;
		action: [ self new ];
		withSeparatorAfter; 
		icon: Smalltalk tools workspace taskbarIcon
]

{ #category : #actions }
PjPlayground >> actOnBrowserClosing: ann [
	
	super actOnBrowserClosing: ann.
	bridge ifNotNil: [bridge stop]

]

{ #category : #accessing }
PjPlayground >> addBinding: anAssociation [
	|bindings|
	bindings := self currentBindings copy.
	bindings removeKey: anAssociation key ifAbsent: [ ].
	bindings add: anAssociation.
	self setBindings: bindings.
]

{ #category : #accessing }
PjPlayground >> allJavascriptGlobals [
	^ allJavascriptGlobals ifNil: [
		allJavascriptGlobals := PjProxyGlobal allJavascriptGlobals
	]
]

{ #category : #accessing }
PjPlayground >> bridge [
	^ bridge
]

{ #category : #accessing }
PjPlayground >> bridge: anObject [
	bridge ifNotNil: [ bridge stop ].
	self allJavascriptGlobals do: [ :name |
		self removeBinding: name -> nil ].
	bridge := anObject.
	anObject ifNil: [
		self label: '...disconnected...'.
		^ self].
	page saveContent: page content,bridge playgroundInitialContent.
	self
		label: anObject clientTitle;
		setupProxies
]

{ #category : #accessing }
PjPlayground >> bridgeVar [
	^ bridgeVar
]

{ #category : #building }
PjPlayground >> codePresentationIn: composite [
	^ composite custom: (PjPresentation onPlayground: self) 
]

{ #category : #initialization }
PjPlayground >> initPage [
	| bindings |
	self openOn: page.
	bridgeVar := (PjWorkspaceBridgeVariable key: #bridge value: nil)
		playground: self.
	bindings := Dictionary newFrom: {bridgeVar}.
	self setBindings: bindings.
	self label: 'PharoJS Playground'
]

{ #category : #initialization }
PjPlayground >> initialize [
	super initialize.
	page := GTPlayPage new saveContent:
		'" cmd-D on the following line will open a bridge and globals will be defined"', String cr
		,'bridge := ' , PjBrowserApplication name, ' bridge start.' , String cr
		;
		yourself.
	self initPage
]

{ #category : #initialization }
PjPlayground >> initializeWithBridge: aPjBridge [
	super initialize.
	page := GTPlayPage new saveContent: '" a bridge is now open and globals are defined"', String cr;
		yourself.
	self initPage.
	bridgeVar value: aPjBridge
]

{ #category : #proxies }
PjPlayground >> makeJsGlobal: jsGlobalName [
	^ (PjWorkspaceGlobalVariable key: jsGlobalName)
		bridge: bridge;
		yourself
]

{ #category : #proxies }
PjPlayground >> setupProxies [
	| dict |
	bridge ifNil: [ ^ self ].
	dict := Dictionary new.
	dict add: bridgeVar.
	bridge client jsGlobalNames
		do: [ :jsGlobalName |
			dict add: (self makeJsGlobal: jsGlobalName)].
	self setBindings: dict.
	bridge setExtraBindings: dict.

]
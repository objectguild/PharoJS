Extension { #name : #PjArray }

{ #category : #'*PharoJsSerialization' }
PjArray class >> instantiateWithPhxJsonReader: reader instanceJsonObject: jsonObject [
	^ self
		withAll:
			(jsonObject collect: [ :each | reader readFromJsObjectOrDictionary: each ])
]

{ #category : #'*PharoJsSerialization' }
PjArray >> writePhxJsonRepresentationOn: w [
	w
		doBetweenSquareBrackets: [ self
				do: [ :each | each writePhxJsonOn: w ]
				separatedBy: [ w comma ] ]
]

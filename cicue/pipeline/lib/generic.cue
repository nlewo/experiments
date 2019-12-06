_trigger: {
	spec: {}
	submit: {}
	fire: ((spec & submit) | _|_) != _|_
}

kubernetes: genericTask.kubernetes

self = genericTask
genericTask: {
	name: *"generic-task" | string
        // TODO: find a way to be able to avoid trigger and triggerDef :/
        // This is to be used in pipeline.yaml
	trigger: {}
        // This allows to define more complex constraints with regex matching for instance
        triggerDef:: {...}
        steps: [...{ name: string, image: string, script: string}]
        kubernetes: [..._]
	if ((_trigger & {spec: (triggerDef & trigger)} & {submit: ci}).fire) {
		kubernetes: [
			{
				apiVersion: "tekton.dev/v1alpha1"
				kind:       "PipelineResource"
				metadata: {
					namespace: ci.namespace
					name:      self.name + "-repository"
				}
				spec: {
					type: "git"
					params: [{
						name:  "revision"
						value: "master"
					}, {
						name:  "url"
						value: null
					}]
				}
			},
			{
				apiVersion: "tekton.dev/v1alpha1"
				kind:       "TaskRun"
				metadata: {
					namespace: ci.namespace
					name:      self.name
				}
				spec: {
					taskRef name: self.name
					resources: [{
						name: "source"
						resourceRef name: "repository-"
					}]
				}
			},
			{
				apiVersion: "tekton.dev/v1alpha1"
				kind:       "Task"
				metadata: {
					namespace: ci.namespace
					name:      "generic-task"
				}
				steps: self.steps
				spec: {
					inputs resources: [{
						name: "source"
						type: "git"
					}]
				}
			}]}
}

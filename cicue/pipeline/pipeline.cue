// This can be used to test triggers
// ci event: "push"
ci repository branch: "test-1"

genericTask: {
	name: "my-task"
	steps: [{
		name:   "build"
		image:  "golang"
		script: "go build"
	}]
	triggerDef:: {
          event: "push"
          repository : { branch : =~ "^test-.*", ... }
        }
}

genericTask kubernetes : [...{ metadata annotations revision: ci.repository.revision}]

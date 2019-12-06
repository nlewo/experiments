A simple way to build Tekton pipelines with Cue. The key idea is to
allow a user to start by using YAML file to describe pipelines, and
smoothly switch to Cue when more complex things have to be achieve.

We use a small wrapper `./template.sh` on top of Cue which make
conversion from and to YAML for us.

### Simple YAML pipeline

We suppose to provide a `lib` to the user. This lib contains some
resource specifications, helpers,... It currently only contains a
helper to build Tekton resources easily. Thanks to this lib, a user can
define a Tetkon task from a simple YAML:

    genericTask:
      name: my-task
      steps:
      - name: build
        image: golang
        script: go build
      - name: test
        image: golang
        script: go test

From this YAML file, a Tekton pipeline can be build:

    pipeline $ ../template.sh lib/generic.cue lib/ci.cue pipeline.yaml -e kubernetes -y
    - kind: PipelineResource
      spec:
        type: git
        ...
    - kind: TaskRun
      spec:
        taskRef:
          name: my-task
      ...
    - kind: Task
      spec:
        inputs:
          resources:
          - name: source
            type: git
      apiVersion: tekton.dev/v1alpha1
      metadata:
        name: generic-task
        namespace: default
      steps:
      - name: build
        image: golang
        script: go build
      - name: test
        image: golang
        script: go test


### Add a condition on the pipeline

The `genericTask` also provides way to create resource only if some
constraints are satisfied. The user can specify a `trigger` struct
with value that have to match values provided by a CI. In the following example, Tekton resources are only created if `ci.repository == master`.

    genericTask:
      name: my-task
      steps:
      - name: build
        image: golang
        script: go build
      - name: test
        image: golang
        script: go test
      trigger:
        repository:
          branch: master

Let's imagine a CI creating a file ci.yaml:

    ci:
      repository:
        branch: master

The pipeline is only generated if the branch is "master", as wanted by the user.


### Add more complex conditions and switch to Cue

But, the user could want to define more complex constraints. For
instance, running a pipeline only if the branch name starts with the
prefix `test-`. This is not possible to specify this directly in
YAML. The user would then have to convert his YAML file to Cue in
order to be able to define such kind of constraints. The
`pipeline.cue` file could then looks like:

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


### Add an annotation to all resources

Suppose now the user wants to add an annotation to all resources
generated for the pipeline. Thanks to Cue this is trivial in the
`pipeline.cue` file. Just need to add:

    genericTask kubernetes : [...{ metadata annotations branch: ci.repository.branch}]

---
title: Argo
created: '2021-12-11T00:34:19.347Z'
modified: '2021-12-27T21:11:00.501Z'
---

# Argo
Open source Kubernetes native engine for workflows, events, CI and CD.
Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes. Argo Workflows is implemented as a Kubernetes CRD (Custom Resource Definition).
- Define workflows where each step in the workflow is a container.
- Model multi-step workflows as a sequence of tasks or capture the dependencies between tasks using a directed acyclic graph (DAG).
- Easily run compute intensive jobs for machine learning or data processing in a fraction of the time using Argo Workflows on Kubernetes.
- Run CI/CD pipelines natively on Kubernetes without configuring complex software development products.

## What is a Workflow?
A workflow is defined as a Kubernetes resource. Each workflow consists of one or more templates, one of which is defined as the entrypoint. Each template can be one of several types, in this example we have one template that is a container.
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  name: hello  
spec:
  entrypoint: main # the first template to run in the workflows        
  templates:
  - name: main           
    container: # this is a container template
      image: docker/whalesay # this image prints "hello world" to the console
```
There are several other types of template. Because a workflow is just a Kubernetes resource, you can use kubectl with them.
  - To execute the above workflow you can use the same syntax as any other k8s resource:
  ```
  kubectl -n argo apply -f hello-workflow.yaml
  ``` 
## Argo CLI
To submit a workflow via argo CLI:
```
argo submit hello-workflow.yaml
```
To list workflows in a k8s namespaoce
```
argo list -n argo
```
Get details about a specific workflow. @latest is an alias for the latest workflow:
```
argo get -n argo @latest
```
And you can view that workflows logs:
```
argo logs -n argo @latest
```
## Template Types
There are several types of templates, divided into two different categories.
The first category defines work to be done. This includes:
- **Container** - Allows you to run a container in a pod
- **Container Set** - Allows you to run multiple containers in a single pod. This is useful when you want the containers to share a common workspace.
- **Data** - Allows you get data from storage (e.g. S3). This is useful when each item of data represents an item of work that needs doing.
- **Resource** - Allows you to create a Kubernetes resource and wait for it to meet a condition (e.g. successful) . This is useful if you want to interoperate with another Kubernetes system, Spark EMR.
- **Script** - Allows you to run a script in a container. This is very similar to a container template, but when you've added a script to it.

The second category orchestrate the work:
- **DAG** -- Allows you to define steps the run parrallel but may have dependencies on other steps
- **Steps** - Allows you to run a series of steps in sequence.
- **Suspend** - Allows you to automatically suspend a workflow, e.g. while waiting on manual approval, or while an external system does some work.
The two most common templates: **containers** and **DAG**.
### Container Template
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow                 
metadata:
  generateName: container-   
spec:
  entrypoint: main         
  templates:
  - name: main             
    container:
      image: docker/whalesay
      command: [cowsay]         
      args: ["hello world"]
```
### Dag Template
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: dag-
spec:
  entrypoint: main
  templates:
    - name: main
      dag:
        tasks:
          - name: a
            template: whalesay
          - name: b
            template: whalesay
            dependencies:
              - a
    - name: whalesay
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "hello world" ]
```
- The "main" template is our new DAG.
- The "whalesay" template is the same template as in the container example.
- The DAG has two tasks: "a" and "b". Both run the "whalesay" template, but as "b" depends on "a", it won't start until " a" has completed successfully.


## Template Tags
- Template tags (also knows as template variables) are a way for you to substitute data into your workflow at runtime. Template tags are delimited by {{ and }} and will be replaced when the template is executed.
- What tags are available to use depends on the template type, and there are a number of global ones you can use, such as {{workflow.name}}, which is replaced by the workflow's name:
```
    - name: main
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "hello {{workflow.name}}" ]
```
## Loops
The ability to run large parallel processing jobs is one of the key features or Argo Workflows. Lets have a look at using loops to do this.
### With Items
- A DAG allows you to loop over a number of items using withItems
- In this example, it will execute once for each of the listed items
- {{item}} will be replaced with "hello world" and "goodbye world"
- DAGs execute in parallel, so both tasks will be started at the same time.
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: with-items-
spec:
  entrypoint: main
  templates:
    - name: main
      dag:
        tasks:
          - name: print-message
            template: whalesay
            arguments:
              parameters:
                - name: message
                  value: "{{item}}"
            withItems:
              - "hello world"
              - "goodbye world"

    - name: whalesay
      inputs:
        parameters:
          - name: message
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "{{inputs.parameters.message}}"
```
### With Sequence
You can also loop over a sequence of numbers using withSequence:
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: with-sequence-
spec:
  entrypoint: main
  templates:
    - name: main
      dag:
        tasks:
          - name: print-message
            template: whalesay
            arguments:
              parameters:
                - name: message
                  value: "{{item}}"
            withSequence:
              count: 5

    - name: whalesay
      inputs:
        parameters:
          - name: message
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "{{inputs.parameters.message}}" ]
```
## Exit Handler
If you need to perform a task after something has is finished, you can use an exit handle. Exit handlers are specified using onExit:
```
      dag:
        tasks:
          - name: a
            template: whalesay
            onExit: tidy-up
```
onExit can be placed on the workflow instead of a specific template:
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: exit-handler-
spec:
  entrypoint: main
  onExit: tidy-up
  templates:
```
## Parameters
One type of input or output is a parameter. Unlike artifacts, these are plain string values, and are useful for most simple cases.
### Input Parameters
- This template declares that it has one input parameter named "message".
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: input-parameters-
spec:
  entrypoint: main
  arguments:
    parameters:
      - name: message
        value: hello world
  templates:
    - name: main
      inputs:
        parameters:
          - name: message
      container:
        image: docker/whalesay
        command: [ cowsay ]
        args: [ "{{inputs.parameters.message}}" ]
```
The parameter can be overridden the argo CLI:
`argo submit --watch input-params-workflow.yaml -p message='Hello Knoldus'`
### Output Parameters
Output parameters can be from a few places, but typically the most versatile is from a file. The container creates a file with a message in it:
```
  - name: whalesay
    container:
      image: docker/whalesay
      command: [sh, -c]
      args: ["echo -n hello world > /tmp/hello_world.txt"] 
    outputs:
      parameters:
      - name: hello-param        
        valueFrom:
          path: /tmp/hello_world.txt
```
In DAGs and steps template, you can reference the output from one task, as the input to another task using a template tag:
```
      dag:
        tasks:
          - name: generate-parameter
            template: whalesay
          - name: consume-parameter
            template: print-message
            dependencies:
              - generate-parameter
            arguments:
              parameters:
                - name: message
                  value: "{{tasks.generate-parameter.outputs.parameters.hello-param}}"
```
## Artifacts
Artifact is a fancy name for a file that is compressed and stored in S3.
There are two kind of artifact in Argo:
1. An input artifact is a file downloaded from storage (e.g. S3) and mounted as a volume within the container.
2. An output artifact is a file created in the container that is uploaded to storage.

Artifacts are typically uploaded into a bucket within some kind of storage such as S3 or GCP. We call that storage an artifact repository. MinIO also serves this purpose without needing a cloud provider.

### Output Artifacts
Each task within a workflow can produce output artifacts. To specify an output artifact, you must include outputs in the manifest. Each output artifact declares:
- The path within the container where it can be found.
- A name so that it can be referred to.
```
    - name: save-message
      container:
        image: docker/whalesay
        command: [ sh, -c ]
        args: [ "cowsay hello world > /tmp/hello_world.txt" ]
      outputs:
        artifacts:
          - name: hello-art
            path: /tmp/hello_world.txt
```
- When the container completes, the file is copied out of it, compressed, and stored.
- Files can also be directories, so when a directory is found all the files are compressed into an archive and stored.

### Input Artifact
To declare an input artifact, you must include inputs in the manifest. Each input artifact must declare:
- Its name.
- The path where it should be created.
```
    - name: print-message
      inputs:
        artifacts:
          - name: message
            path: /tmp/message
      container:
        image: docker/whalesay
        command: [ sh, -c ]
        args: [ "cat /tmp/message" ]
```
- If the artifact was a compressed directory, it will be uncompressed and unpacked into the path.
### Input and Outputs
You can't use inputs and output in isolation, you need to combine them together using either a steps or a DAG template:
```
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifacts-
spec:
  entrypoint: main
  templates:
    - name: main
      dag:
        tasks:
          - name: generate-artifact
            template: save-message
          - name: consume-artifact
            template: print-message
            dependencies:
              - generate-artifact
            arguments:
              artifacts:
                - name: message
                  from: "{{tasks.generate-artifact.outputs.artifacts.hello-art}}"

    - name: save-message
      container:
        image: docker/whalesay
        command: [ sh, -c ]
        args: [ "cowsay hello world > /tmp/hello_world.txt" ]
      outputs:
        artifacts:
          - name: hello-art
            path: /tmp/hello_world.txt

    - name: print-message
      inputs:
        artifacts:
          - name: message
            path: /tmp/message
      container:
        image: docker/whalesay
        command: [ sh, -c ]
        args: [ "cat /tmp/message" ]
```
### Workflow Templates
Workflow templates (not to be confused with a template) allow you to create a library of code that can be reused. They're similar to pipelines in Jenkins.
Workflow templates have a different kind to a workflow, but are otherwise very similar:

```
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: hello
spec:
  entrypoint: main
  templates:
    - name: main
      container:
        image: docker/whalesay
```
To create a workflow template with the cli:
```
argo template create hello-workflowtemplate.yaml
```
You can also use kubectl:
```
kubectl apply -f hello-workflowtemplate.yaml
```
To submit:
```
argo submit --watch --from workflowtemplate/hello
```
### Cron Workflows
A cron workflow is a workflow that runs on a cron schedule:
```
apiVersion: argoproj.io/v1alpha1
kind: CronWorkflow
metadata:
  name: hello
spec:
  schedule: "* * * * *"
  workflowSpec:
    workflowTemplateRef:
      name: hellocontrolplane $ 
```
When it should be run is set in the schedule field, in the example every minute.

To created a cron workflow:
```
argo cron create hello-cronworkflow.yaml
```
You'll need to wait for up to a minute to see the workflow run.

## Argo Workflow + Argo CD + Argo Events
Secret
  source-key-argo
  deploy-key-argo
  deploy-key-argocd
  github-access-argo-event
  github-access-argo
  gcr-credentials!

Argo Event
 Event source
 - The Custom Resource for Event Source. Event Source is configurated to receive events from github.
 Event source service
 - The services accessible by webook
 Event Sensor
 - Event sensor performs predefined triggers when events are received from the source.
To trigger workflow the following endpoint can be hit for event-sensor:
curl -d '{"message":"ok"}' -H "Content-Type: application/json" -X POST http://localhost:12000/push

 Argo Workflow
Workflow Template
 - Predefined workflowtemplate. Used by trigger in event sensor to create workflow.
 Argo Cluster Role
 - Custerrole to access resources in argo namespace

Argo CD
Application
- Configuration for Argo CD
Repository
- ConfigMap to access the deploy repository. Used by Argo CD to deploy the application CR.

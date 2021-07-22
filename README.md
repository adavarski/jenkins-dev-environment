# docker-compose development environment : Jenkins custom Docker image + Atlassian Bitbucket + Sonarqube + etc. 

This repo contains a docker/docker-compose configuration for Jenkins custom Docker image + Sonarqube && Atlassian Bitbucket for development environment setup. Note: Sonarqube & Bitbucket applications comes with it's own PostgreSQL instances (docker containers: postgres for sonarqube && atl_database for BB database), user, database and docker volume.

## Requirements

git, docker and docker-compose to be installed.

```
$ sh ./utils/docker-setup.sh
```

## Jenkins custom Docker image

Custom Jenkins image is built with the following features:

- [Preinstalled plugins](#preinstalled-plugins)
- [Default administrator](#default-administrator)
- [No setup wizard](#no-setup-wizard)
- [Default location configuration](#default-location-configuration)
- [Default Maven installation](#default-maven-installation)
- [Capability of running Ansible playbooks](#capability-of-running-ansible-playbooks)
- [Docker in Docker](#docker-in-docker)
- [Adding a global credentials](#adding-a-global-credentials)
- [Adding an AWS credentials](#adding-an-aws-credentials)
- [In-process Script Approval](#in-process-script-approval)
- [Integration with Bitbucket](#integration-with-bitbucket)
- [Integration with SonarQube](#integration-with-sonarqube)
- [Integration with Slack](#integration-with-slack)
- [JVM Metrics](#jvm-metrics)
- [UI tests capability](#ui-tests-capability)
- [Jenkins hardening](#jenkins-hardening)

## Atlassian Bitbucket (to host some development projects/repos).

Note: Set some secure passwords in .env and pg-init-scripts/init.sql if you needed.

During configuration of the applications via the setup procedure, use the following database settings:
```
host: atl_database
port: 5432
database: <app>db
database user: <app>user
database user password: <password specified in init.sql>
``` 
To fully clean reset an application, you have to delete the associated docker volume and clean the associated database.

## Run development environment 

```
$ sudo sysctl -w vm.max_map_count=262144 // Note: For sonarqube to work properly

$ docker-compose up -d 
Building with native build. Learn about native build in Compose here: https://docs.docker.com/go/compose-native-build/
Creating network "jenkins-dev-environment_default" with the default driver
Creating postgres     ... done
Creating atl_database ... done
Creating bitbucket    ... done
Creating sonarqube    ... done
Creating jenkins-dev  ... done

```

## Check development environment
```
$ docker-compose ps 
    Name                  Command                  State                                 Ports                          
------------------------------------------------------------------------------------------------------------------------
atl_database   docker-entrypoint.sh postgres    Up             0.0.0.0:5431->5432/tcp                                   
bitbucket      /usr/bin/tini -- /entrypoi ...   Up             0.0.0.0:7990->7990/tcp, 0.0.0.0:7999->7999/tcp           
jenkins-dev    /entrypoint.sh                   Up             50000/tcp, 0.0.0.0:8080->8080/tcp, 0.0.0.0:8081->8081/tcp
postgres       docker-entrypoint.sh postgres    Up (healthy)   5432/tcp                                                 
sonarqube      ./bin/run.sh                     Up             0.0.0.0:9000->9000/tcp 

$ docker-compose logs sonarqube|tail
sonarqube       | 2021.07.21 15:37:49 INFO  ce[][o.e.p.PluginsService] loaded plugin [org.elasticsearch.percolator.PercolatorPlugin]
sonarqube       | 2021.07.21 15:37:49 INFO  ce[][o.e.p.PluginsService] loaded plugin [org.elasticsearch.transport.Netty4Plugin]
sonarqube       | 2021.07.21 15:37:54 INFO  ce[][o.s.s.e.EsClientProvider] Connected to local Elasticsearch: [127.0.0.1:9001]
sonarqube       | 2021.07.21 15:37:54 INFO  ce[][o.sonar.db.Database] Create JDBC data source for jdbc:postgresql://postgres/sonar
sonarqube       | 2021.07.21 15:38:07 INFO  ce[][o.s.s.p.ServerFileSystemImpl] SonarQube home: /opt/sonarqube
sonarqube       | 2021.07.21 15:38:08 INFO  ce[][o.s.c.c.CePluginRepository] Load plugins
sonarqube       | 2021.07.21 15:38:21 INFO  ce[][o.s.c.c.ComputeEngineContainerImpl] Running Community edition
sonarqube       | 2021.07.21 15:38:22 INFO  ce[][o.s.ce.app.CeServer] Compute Engine is operational
sonarqube       | 2021.07.21 15:38:22 INFO  app[][o.s.a.SchedulerImpl] Process[ce] is up
sonarqube       | 2021.07.21 15:38:22 INFO  app[][o.s.a.SchedulerImpl] SonarQube is up
```

## Access J && BB:
|Application|URL|
|--|--|
|Bitbucket |http://localhost:7990/|
|Jenkins |http://localhost:8080/|
The PostgreSQL database is only accessible from inside the cluster on port `5432`.

## Clean environment

```
docker-compose down
docker volume ls|grep jenkins-dev-environment|awk '{print $2}'|xargs docker volume rm -
```

# Jenkins custom Docker image details, features and howto usage


## Preinstalled plugins

A bunch of [plugins](plugins.txt) are installed during the image build. Once they increase the image size considerably, the [Alpine](https://alpinelinux.org) version of the Jenkins Docker image is used as the base image ([jenkins/jenkins:lts-alpine](https://github.com/jenkinsci/docker/blob/master/Dockerfile-alpine)), in order to keep the built image as small as possible.

Most of the plugins enable other features, as described below.

## Default administrator

The default Jenkins administrator account is created during the execution of [default-user.groovy](scripts/default-user.groovy). Its credentials are obtained from the environment variables:

- JENKINS_USER (default: admin)
- JENKINS_PASS (default: jenkins)

## No setup wizard

With preinstalled plugins and a default administrator, there is no need of following the Jenkins wizard during its setup. For this reason, the wizard is disabled: `-Djenkins.install.runSetupWizard=false`.

## Default location configuration

The default Jenkins location is configured during the execution of [config-location.groovy](scripts/config-location.groovy). The Jenkins URL and the e-mail address Jenkins use as the sender for e-mail notification are obtained from the environment variables:

- JENKINS_URL (default: <http://localhost:8080>)
- JENKINS_EMAIL (default: jenkins@example.com)

## Default Maven installation

The default [Apache Maven](https://maven.apache.org) installation is configured during the execution of [config-maven.groovy](scripts/config-maven.groovy). The Maven version is obtained from the environment variable:

- MAVEN_VERSION (default: 3.6.3)

Maven can then be referenced by `M3` in the Jenkinsfile, like in the example below:

```groovy
node {
    def mvnHome = tool 'M3'
    ...
    stage('Build and Unit Tests') {
        sh "'${mvnHome}/bin/mvn' clean install"
    }
    ...
}
```

## Capability of running Ansible playbooks

The default [Ansible](https://www.ansible.com) installation is configured during the execution of [config-ansible.groovy](scripts/config-ansible.groovy). Ansible can then be referenced by `Ansible` in the Jenkinsfile, like in the example below:

```groovy
node {
    ...
    stage('Deploy to AWS') {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            ansiblePlaybook(installation: 'Ansible', playbook: 'deploy-to-aws.yml')
        }
    }
    ...
}
```

This feature is enabled by the [Ansible plugin](https://plugins.jenkins.io/ansible).

## Docker in Docker

The jenkins Docker image is prepared itself to enable the execution of Docker commands. So, you are able to run pipelines in the jenkins Docker container that build Docker images, push Docker images to a Docker Registry or execute any other Docker command (example below). The only requirement is to [bind mount](https://docs.docker.com/storage/bind-mounts) your host Docker daemon Unix socket to the container Docker daemon Unix socket: `-v /var/run/docker.sock:/var/run/docker.sock`.

```groovy
node {
    def appDockerImage
    ...
    stage('Build Docker Image') {
        appDockerImage = docker.build("davarski/webapp-docker")
    }
    stage('Deploy Docker Image') {
        docker.withRegistry("", "dockerhub") {
            appDockerImage.push()
        }
    }
    ...
}
```
Note: See [EXAMPLE](https://github.com/adavarski/jenkins-dev-environment/tree/main/j.playground)
    
## Adding a global credentials

[A new global credentials can be created in Jenkins](https://jenkins.io/doc/book/using/using-credentials/#adding-new-global-credentials) with the execution of [add-credentials.groovy](scripts/add-credentials.groovy). It only happens if the following environment variables are defined:

- CREDENTIALS_ID
- CREDENTIALS_USER
- CREDENTIALS_PASS

The global credentials can then be referenced by its `credentialsId` in the Jenkinsfile, like in the example below:

```groovy
node {
    ...
    stage('Deploy Java Artifacts') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'ossrh', usernameVariable: 'OSSRH_USER', passwordVariable: 'OSSRH_PASSWORD']]) {
            sh "'${mvnHome}/bin/mvn' -s .travis.settings.xml source:jar deploy -DskipTests=true"
        }
    }
    ...
}
```

## Adding an AWS credentials

A new AWS credentials can be created in Jenkins with the execution of [add-aws-credentials.groovy](scripts/add-credentials.groovy). It only happens if the following environment variables are defined:

- AWS_CREDENTIALS_ID
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

The AWS credentials can then be referenced by its `credentialsId` in the Jenkinsfile, like in the example below:

```groovy
node {
    ...
    stage('Deploy to AWS') {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            ansiblePlaybook(installation: 'Ansible', playbook: 'deploy-to-aws.yml')
        }
    }
    ...
}
```

This feature is enabled by the [CloudBees AWS Credentials plugin](https://plugins.jenkins.io/aws-credentials).

## Capability of running Terraform modules

Note: Use Dockerfile-TF for jenkins custom image

```groovy
...
String awsCredentialsId = 'AWS-demo'
...
    stage('TF init') {
      steps {
        dir('aws-tf/Jenkins-EC2') {
          script {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: awsCredentialsId,
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']])
            {
              sh "terraform init"
            }
            
            }
          }
        }
      }


     stage('TF apply env') {
      when{ equals expected: "CREATE", actual: "${params.Action}"}
      steps {
        dir('aws-tf/Jenkins-EC2') {
          script {
            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
            credentialsId: awsCredentialsId,
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',  
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']])
             {
             sh "terraform apply -auto-approve"
             }
            }
          }
        }
      }
...

```
This feature is enabled by the [CloudBees AWS Credentials plugin](https://plugins.jenkins.io/aws-credentials).

## In-process Script Approval

[An in-process script or a method signature can be approved in Jenkins](https://jenkins.io/doc/book/managing/script-approval) with the execution of [approve-signature.groovy](scripts/approve-signature.groovy). It only happens if the following environment variable is defined:

- SIGNATURE

## Integration with Bitbucket

Jenkins can be integrated to [Bitbucket](https://www.atlassian.com/software/bitbucket) with the execution of [config-bitbucket.groovy](scripts/config-bitbucket.groovy). It only happens if the following environment variables are defined:

- BITBUCKET_URL - the endpoint where your Bitbucket instance is available
- BITBUCKET_CREDENTIALS_ID - the global credentials id previously added to Jenkins with the Bitbucket *username* and *password*

This feature is enabled by the [Bitbucket plugin](https://plugins.jenkins.io/bitbucket).

 For better integration you can install  [Bitbucket Server integration plugin](https://plugins.jenkins.io/atlassian-bitbucket-server-integration/): See [EXAMPLE](https://github.com/adavarski/jenkins-dev-environment/tree/main/j.playground) using Bitbucket Server integration plugin.

## Integration with SonarQube

Jenkins can be integrated to [SonarQube](https://www.sonarqube.org) with the execution of [config-sonarqube.groovy](scripts/config-sonarqube.groovy). It only happens if the following environment variable is defined:

- SONARQUBE_URL - the endpoint where your SonarQube instance is available

:warning: If you have disabled anonymous access in SonarQube and have generated an user token for performing the static code analysis, set the environment variable SONARQUBE_TOKEN.

SonarQube can then be referenced by `SonarQube` in the Jenkinsfile, like in the example below:

```groovy
node {
    ...
    stage('Static Code Analysis') {
        withSonarQubeEnv('SonarQube') {
            sh "'${mvnHome}/bin/mvn' sonar:sonar"
        }
    }
    ...
}
```

:information_source: You don't need to pass the *installationName* parameter to **withSonarQubeEnv** if just one SonarQube server was configured in Jenkins. More details in [Using a Jenkins pipeline](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-jenkins/#header-5).

This feature is enabled by the [SonarQube plugin](https://plugins.jenkins.io/sonar).

## Integration with Slack

Jenkins can be integrated to [Slack](https://slack.com) with the execution of [config-slack.groovy](scripts/config-slack.groovy). It only happens if the following environment variables are defined:

- SLACK_WORKSPACE
- SLACK_TOKEN

Slack can then be used in the Jenkinsfile, like in the example below:

```groovy
node {
    ...
    stage('Results') {
        ...
        slackSend(channel: 'builds', message: 'Pipeline succeed!', color: 'good')
    }
}
```

This feature is enabled by the [Slack Notification plugin](https://plugins.jenkins.io/slack).

## JVM Metrics

The Jenkins JVM metrics are exposed by [jmx_exporter](https://github.com/prometheus/jmx_exporter), a process for exposing JMX Beans via HTTP for [Prometheus](https://prometheus.io) consumption. The JVM metrics are exposed through port **8081**, as passed to the Java Agent:

`-javaagent:/usr/bin/jmx_exporter/jmx_prometheus_javaagent.jar=8081:/usr/bin/jmx_exporter/config.yaml`

## UI tests capability

The Jenkins image has installed [Firefox ESR](https://www.mozilla.org/en-US/firefox/organizations) and [geckodriver](https://github.com/mozilla/geckodriver) (available in `/usr/local/bin/geckodriver`), enabling that way UI tests with [Selenium](https://www.seleniumhq.org).

The example below shows how the UI test can be performed during the execution of your Jenkinsfile:

```groovy
node {
    ...
    stage('UI Tests') {
        sh "'${mvnHome}/bin/mvn' -f test-selenium test -Dwebdriver.gecko.driver=/usr/local/bin/geckodriver -Dheadless=true"
    }
    ...
}
```

## Jenkins hardening

The Jenkins security is improved during the execution of [harden-jenkins.groovy](scripts/harden-jenkins.groovy) and [default-project-authorization.groovy](scripts/default-project-authorization.groovy), when the following actions are taken:

- [Enabling CSRF protection](https://wiki.jenkins.io/display/JENKINS/CSRF+Protection);
- [Enabling Agent -> Master access control](https://wiki.jenkins.io/display/JENKINS/Slave+To+Master+Access+Control);
- Disabling the deprecated [JNLP](https://en.wikipedia.org/wiki/Java_Web_Start#Java_Network_Launching_Protocol_(JNLP));
- Preventing builds run as SYSTEM by configuring [access control for builds](https://jenkins.io/doc/book/system-administration/security/build-authorization).

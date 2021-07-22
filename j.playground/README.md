After `docker-compose up -d`

# Bitbucket setup (http://localhost:7990/)

- Login to your Attlassian account and generate licence.  

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-license.png" width="900">

- Setup admin user credentials (Example: admin/${bb-admin-password}).

- Create admin personal access token (Ref: https://confluence.atlassian.com/bitbucketserver/personal-access-tokens-939515499.html)

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-admin-dev-personal-access-token-for-jenkins.png" width="900">


- Create Project:DEMO/repo:webapp-docker @Bitbucket
<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucker-create-repo-in-DEMO-project.png" width="900">



- Puch existing project to repo
```
cd ./webapp-docker
git init
git add --all
git commit -m "Initial Commit"
git remote add origin http://localhost:7990/scm/demo/webapp-docker.git
git push -u origin master
```
Example push:
```
$ git push -u origin master
Username for 'http://localhost:7990': admin
Password for 'http://admin@localhost:7990': 
Counting objects: 9, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (9/9), done.
Writing objects: 100% (9/9), 1.87 KiB | 1.87 MiB/s, done.
Total 9 (delta 1), reused 0 (delta 0)
To http://localhost:7990/scm/demo/webapp-docker.git
 * [new branch]      master -> master
Branch 'master' set up to track remote branch 'master' from 'origin'.
```
<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-repo-pushed.png" width="900">


- OPTIONAL: Migrate BB to external database 

Setup/Test database connection (Note: atl_database docker container)

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/Bitbucket-external-database-migration.png" width="900">

After migration we will have:

https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-external-database-migrated.png

 
# Jenkins setup (http://localhost:8080/ -> default user/password: admin/jenkins) 

- Install Bitbucket Server Integration plugin (Ref: https://plugins.jenkins.io/atlassian-bitbucket-server-integration/)

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-install-bitbucket-server-integration-plugin.png" width="900">

- Setup Bitbucket Server Integration plugin: Add a Bitbucket Server instance (Credentials: Kind --> Bitbucket personal access token ) ---> Test Connection. 

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-bitbucket-server-integration-plugin-setup.png" width="900">

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-credentials-bitbuvket-token.png" width="900">

- Add needed credentials for pipelines: bitbucket user/password credentials && dockerhub credentials also

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-credentials-all.png" width="900">

- Create pipeline in Jenkins 

Pipeline from SCM : Select a Bitbucket Server instance when creating a Pipeline

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-pipeline-SCM-Jenkinsfile.png" width="900">

- Run pipeline and check status:

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-pipeline-status.png" width="900">


NOTE: Optional create Application Link between Jenkins && Bitbucket (Ref: https://plugins.jenkins.io/atlassian-bitbucket-server-integration/)

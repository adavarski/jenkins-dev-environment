After `docker-compose up -d`

# URL: http://localhost:7990/ for Bitbucket setup

- Login to your Attlassian account and generate licence.  

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-license.png" width="900">

- Setup admin user credentials (Example: admin/bb-admin-password).

- Create admin personal access token.

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucket-admin-dev-personal-access-token-for-jenkins.png" width="900">


Create Project:DEMO/repo:webapp-docker @Bitbucket
<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/bitbucker-create-repo-in-DEMO-project.png" width="900">



Puch existing project to repo
```
cd ./webapp-docker
git init
git add --all
git commit -m "Initial Commit"
git remote add origin http://localhost:7990/scm/demo/webapp-docker.git
git push -u origin master
```
example:
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


# URL: http://localhost:8080/ for Jenkins setup (default user/password: admin/jenkins) 

- Install Bitbucket Server Integration plugin (Ref: https://plugins.jenkins.io/atlassian-bitbucket-server-integration/)

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-install-bitbucket-server-integration-plugin.png" width="900">

Setup Bitbucket Server Integration plugin: Add a Bitbucket Server instance (Credentials: Kind --> Bitbucket personal access token ) ---> Test Connection. 

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-bitbucket-server-integration-plugin-setup.png" width="900">

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-credentials-bitbuvket-token.png" width="900">


and add bitbucket user/password credentials

add dockerhub credentials also

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-credentials-all.png" width="900">


Create pipeline in Jenkins 


Pipeline from SCM 

Select a Bitbucket Server instance when creating a Pipeline

<img src="" width="900">


Check pipeline status:

<img src="https://github.com/adavarski/jenkins-dev-environment/blob/main/j.playground/pictures/jenkins-pipeline-status.png" width="900">



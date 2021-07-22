After `docker-compose up -d`

# URL: http://localhost:7990/ for Bitbucket setup

Login to your Attlassian account and generate licence. Setup admin user. Create admin personal access token.

Create Project:DEMO/repo:webapp-docker @Bitbucket

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


# URL: http://localhost:8080/ for Jenkins setup (default user/password: admin/jenkins) 

Install Bitbucket Server Integration plugin (Ref: https://plugins.jenkins.io/atlassian-bitbucket-server-integration/)

Setup Bitbucket Server Integration plugin: Add a Bitbucket Server instance (Credentials: Kind --> Bitbucket personal access token ) ---> Test Connection. 

Create pipeline in Jenkins 

Pipeline from SCM 

Select a Bitbucket Server instance when creating a Pipeline

and add bitbucket user/password credentials for jenkins 

add dockerhub credentials also

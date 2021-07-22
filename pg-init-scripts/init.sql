CREATE USER bitbucketuser WITH PASSWORD 'bitbucket-pw';
CREATE DATABASE  bitbucketdb;
GRANT ALL PRIVILEGES ON DATABASE bitbucketdb TO bitbucketuser;


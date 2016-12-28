#!/bin/bash

wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install -q -y jenkins java

puppet resource augeas jenkins context=/files/etc/sysconfig/jenkins changes="set JENKINS_HOME /data/jenkins/conf"

mkdir /data/jenkins/conf -p
chown jenkins /data/jenkins -R
systemctl enable jenkins

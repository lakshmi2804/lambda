FROM ubuntu:latest

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update
RUN apt-get -y install git

#RUN apt install -y default-jre
#RUN apt-get -y install default-jdk
RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install maven
RUN apt-get -y  update
RUN apt-get install -y awscli

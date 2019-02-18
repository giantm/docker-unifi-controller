FROM ubuntu:17.10
MAINTAINER matt@giant.family

ARG BUILD_DATE
ARG SHORT_VERS=5.10.19
ARG UNIFI_VERSION=${SHORT_VERS}-113b57454f

LABEL build_version="mattgiant version:- ${SHORT_VERS} Build-date:- ${BUILD_DATE}"

# SET ENVIROMENT VARIABLES
ENV DEBIAN_FRONTEND noninteractive

# INSTALL PACKAGES
RUN apt update -q && \
    apt upgrade -y && \
    apt dist-upgrade -y 

#install image building support
RUN apt -y install wget	prelink execstack

#install actual needed software
RUN apt -y install openjdk-8-jre-headless supervisor mongodb-server binutils jsvc libcap2 curl
        
    # INSTALL UNIFI    
RUN wget -nv https://www.ubnt.com/downloads/unifi/$UNIFI_VERSION/unifi_sysvinit_all.deb && \    
    dpkg --install unifi_sysvinit_all.deb && \
    rm unifi_sysvinit_all.deb 
            
    # FIX WEBRTC STACK GUARD ERROR 
RUN execstack -c /usr/lib/unifi/lib/native/Linux/x86_64/libubnt_webrtc_jni.so 

#clean out apt stuff
RUN apt-get -y purge prelink wget &&\     
    apt-get -q clean && \ 
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*.deb /tmp/* /var/tmp/*  
   
    # FORWARD PORTS
EXPOSE 3478/udp 6789/tcp 8080/tcp 8081/tcp 8443/tcp 8843/tcp 8880/tcp 

    # SET INTERNAL STORAGE VOLUME
VOLUME ["/usr/lib/unifi/data"]

    # SET WORKING DIRECTORY FOR PROGRAM
WORKDIR /usr/lib/unifi

    # ADD SUPERVISOR CONFIG
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord","--configuration=/etc/supervisor/supervisord.conf"]


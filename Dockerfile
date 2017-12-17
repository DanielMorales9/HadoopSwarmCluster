FROM debian:jessie
MAINTAINER DanielMorales9

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y curl unzip nano screen tmux wget git openssh-server openssh-client default-jre default-jdk \
    python3 python3-setuptools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    easy_install3 pip py4j && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /usr/incubator-toree

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

WORKDIR /usr

# HADOOP
ARG HADOOP_VERSION=2.7.5
ARG HADOOP_BINARY_ARCHIVE_NAME=hadoop-$HADOOP_VERSION
ARG HADOOP_BINARY_DOWNLOAD_URL=http://mirror.koddos.net/apache/hadoop/common/$HADOOP_BINARY_ARCHIVE_NAME/$HADOOP_BINARY_ARCHIVE_NAME.tar.gz

RUN wget -qO - $HADOOP_BINARY_DOWNLOAD_URL | tar -xz -C /usr/ && \
    ln -s $HADOOP_BINARY_ARCHIVE_NAME hadoop

ENV HADOOP_HOME=/usr/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:JAVA_HOME/bin

RUN mkdir -p /usr/hdfs/namenode && \ 
    mkdir -p /usr/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

# HADOOP master slave configuration
COPY config/* /tmp/
RUN mkdir -p ~/.ssh/config &&\ 
    mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/entrypoint.sh ~/entrypoint.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh && \
    chmod +x ~/entrypoint.sh && \
    hdfs namenode -format && \
    chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config && \
    ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

RUN mkdir -p /home/code && \
    mkdir -p /home/data

VOLUME /home/code
VOLUME /home/data

CMD ["sh", "-c", "~/entrypoint.sh"]

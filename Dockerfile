FROM ubuntu:18.04

# Ensure the package repository is up to date
RUN apt-get update && \
    apt-get install -qy git wget openssh-server openjdk-17-jdk && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
    # Install Maven (latest version compatible with Java 17)
    wget https://downloads.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
    tar -xvzf apache-maven-3.9.5-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-maven-3.9.5 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm apache-maven-3.9.5-bin.tar.gz && \
    # Cleanup old packages
    apt-get -qy autoremove && \
    # Add user 'jenkins' to the image
    adduser --quiet jenkins && \
    echo "jenkins:password" | chpasswd && \
    mkdir -p /home/jenkins/.m2 /home/jenkins/workspace/java-docker-nexus

# Set ownership for Jenkins user's directories
RUN chown -R jenkins:jenkins /home/jenkins/.m2 /home/jenkins/workspace

# Set working directory to match Jenkins workspace
WORKDIR /home/jenkins/workspace/java-docker-nexus

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:/opt/maven/bin:$PATH

# Expose the SSH port
EXPOSE 22

# Start the SSH server
CMD ["/usr/sbin/sshd", "-D"]


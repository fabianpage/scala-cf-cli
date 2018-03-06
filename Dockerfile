
FROM hseeberger/scala-sbt


## add cloudfoundry cli
RUN apt-get update -yq
RUN apt-get install apt-transport-https wget -yq
RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
RUN echo "deb http://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
RUN apt-get update -yq
RUN apt-get install ca-certificates cf-cli zip netcat sudo build-essential tmux wget curl jq -yq

## Add Scala Versions
## From fommil/docker-openjdk-sbt https://github.com/fommil/docker-openjdk-sbt/blob/master/Dockerfile
ENV PATH /root/.jenv/shims:/root/.jenv/bin:$PATH
ENV JAVA_VERSIONS 1.8
ENV SCALA_VERSIONS 2.11.8 2.11.11 
ENV SBT_VERSIONS 0.13.15 0.13.16
ENV COURSIER_VERBOSITY -1

RUN \
  mkdir -p /tmp/sbt &&\
  cd /tmp/sbt &&\
  mkdir -p project project/project src/main/scala &&\
  touch src/main/scala/scratch.scala &&\
  for JAVA_VERSION in $JAVA_VERSIONS ; do\
  echo $JAVA_VERSION > .java-version ;\
  head .java-version &&\
  for SBT_VERSION in $SBT_VERSIONS ; do\
    echo "sbt.version=$SBT_VERSION" > project/build.properties &&\
    head project/build.properties &&\
    for SCALA_VERSION in $SCALA_VERSIONS ; do\
      echo "$JAVA_VERSION $SBT_VERSION $SCALA_VERSION" ;\
      rm project/project/plugins.sbt >/dev/null 2>&1 ;\
      sbt ++$SCALA_VERSION clean update compile >/dev/null 2>&1 ;\
      echo 'addSbtPlugin("io.get-coursier" % "sbt-coursier" % "1.0.0")' > project/project/plugins.sbt ;\
      sbt ++$SCALA_VERSION clean update compile >/dev/null 2>&1 ;\
      rm project/project/plugins.sbt >/dev/null 2>&1 ;\
    done ;\
  done ;\
  done &&\
  cd .\
  rm -rf /tmp/sbt

WORKDIR /root


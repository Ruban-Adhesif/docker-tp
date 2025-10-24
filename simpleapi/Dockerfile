FROM eclipse-temurin:21-jdk AS build
ENV MYAPP_HOME=/opt/myapp
WORKDIR $MYAPP_HOME
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*
COPY pom.xml .
RUN mvn -B -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:21-jre
ENV MYAPP_HOME=/opt/myapp
WORKDIR $MYAPP_HOME
COPY --from=build $MYAPP_HOME/target/*.jar $MYAPP_HOME/app.jar
ENTRYPOINT ["java","-jar","app.jar"]

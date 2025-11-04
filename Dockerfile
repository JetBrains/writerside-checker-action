FROM eclipse-temurin:21-jdk-alpine

RUN apk add --no-cache curl

RUN mkdir /app
WORKDIR /app
RUN curl -o wrs-doc-app.jar -L https://packages.jetbrains.team/maven/p/writerside/maven/com/jetbrains/writerside/writerside-ci-checker/1.0/writerside-ci-checker-1.0.jar

# Use a shell script as entrypoint to handle optional arguments
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]

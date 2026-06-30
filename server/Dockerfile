FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper and POM files first
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

RUN chmod +x mvnw
# Cache Maven dependencies using BuildKit cache mount
RUN --mount=type=cache,target=/root/.m2 ./mvnw dependency:go-offline -B

# Copy src and build the package
COPY src src
RUN --mount=type=cache,target=/root/.m2 ./mvnw package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
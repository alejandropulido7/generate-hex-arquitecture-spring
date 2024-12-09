#!/bin/bash

# Base directory (modify this variable if needed)"$GROUP/$ARTIFACT"
GROUP="com/courses"
ARTIFACT="e-learning"

# Function to create a folder and echo its creation
create_dir() {
  mkdir -p "$1"
  echo "Created: $1"
}

echo "Creating Hexagonal Architecture Folder Structure in $ARTIFACT..."

# Create main project structure
create_dir "src/main/java/$GROUP/$ARTIFACT/application/config/security"
create_dir "src/main/java/$GROUP/$ARTIFACT/application/useCases/service1"
create_dir "src/main/java/$GROUP/$ARTIFACT/application/useCases/service2"

create_dir "src/main/java/$GROUP/$ARTIFACT/domain/gateway"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/model/exceptions"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/model"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/ports/in"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/ports/out"

create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/out/persistence/config"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/out/persistence/service1"

create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/in/web/common"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/in/web/service1"

rm "src/main/resources/application.properties"

# Print completion message
echo "Hexagonal Architecture Folder Structure created successfully in root directory"

PORTS_IN="src/main/java/$GROUP/$ARTIFACT/domain/ports/in/example.java"

cat > $YML_FILE <<EOL
Used by Controller (Adapter/in) and implemented by UseCase
EOL

PORTS_IN="src/main/java/$GROUP/$ARTIFACT/domain/ports/out/example.java"

cat > $YML_FILE <<EOL
Used by UseCase and implemented by Adapter/out
EOL

echo "Creating application.yml..."
# Define the path for the YAML file
YML_FILE="src/main/resources/application.yml"

# Create the YAML file with the specified content
cat > $YML_FILE <<EOL
spring:
  main:
    allow-bean-definition-overriding: true
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: America/Bogota
  servlet:
    context-path: /api/learning
  application:
    name: e-learning
  jpa:
    hibernate:
      ddl-auto: create-drop
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
  datasource:
    url: jdbc:postgresql://localhost:5432/e-learning\
    username: learning
    password: learning
    hikari:
      auto-commit: true
      max-lifetime: 1000
      maximum-pool-size: 10
      connection-timeout: 2000
server:
  port: 8085
EOL


echo "Creating dockerfile..."
DOCKER_FILE="Dockerfile"
# Create the YAML file with the specified content
cat > $DOCKER_FILE <<EOL
FROM eclipse-temurin:17.0.13_11-jdk

ARG JAR_FILE=build/libs/*.jar

COPY "${JAR_FILE}" app.jar

ENTRYPOINT ["java","-jar","/app.jar"]
EOL


echo "Creating docker-compose..."
DOCKER_COMPOSE_FILE="docker-compose.yml"

# Create the YAML file with the specified content
cat > $DOCKER_COMPOSE_FILE <<EOL
version: '3.9'
services:
  app:
    build:
      context: .
    ports:
      - 8085:8085
    depends_on:
      - postgres
    environment:
      - POSTGRES_URL=jdbc:postgresql://postgres:5432/hotel-reservations
      - POSTGRES_USER=hotel
      - POSTGRES_PASSWORD=claveHotel
  postgres:
    image: postgres
    ports:
      - 5432:5432
    volumes:
      - pgdata:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=claveHotel
      - POSTGRES_USER=hotel
      - POSTGRES_DB=hotel-reservations

volumes:
  pgdata:
EOL



echo "Creating security java class..."

SECURITY_BEANS="src/main/java/$GROUP/$ARTIFACT/application/config/security/SecurityBeans.java"

# Ensure the folder structure exists
# shellcheck disable=SC2046
mkdir -p $(dirname "$SECURITY_BEANS")

# Create the Java file with the specified content
cat > $SECURITY_BEANS <<EOL
package hotel.reservations.application.config.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity;
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity;
import org.springframework.security.config.web.server.ServerHttpSecurity;
import org.springframework.security.core.userdetails.MapReactiveUserDetailsService;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.server.SecurityWebFilterChain;
import org.springframework.security.web.server.util.matcher.PathPatternParserServerWebExchangeMatcher;

import java.util.ArrayList;
import java.util.List;

import static org.springframework.security.config.Customizer.withDefaults;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityBeans {

    @Bean
        public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
            return httpSecurity
                    .csrf(csrf -> csrf.disable())
                    .httpBasic(Customizer.withDefaults())
                    .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                    .authorizeHttpRequests(http -> {
                        http.anyRequest().authenticated();
                    })
                    .build();
        }

        @Bean
        public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
            return authenticationConfiguration.getAuthenticationManager();
        }

        @Bean
        public AuthenticationProvider authenticationProvider(){
            DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
            provider.setPasswordEncoder(passwordEncoder());
            provider.setUserDetailsService(userDetailService());
            return provider;
        }

        @Bean
        public UserDetailsService userDetailService(){
            List<UserDetails> userDetailsList = new ArrayList<>();

            userDetailsList.add(User.withUsername("user")
                    .password("user")
                    .roles("USER")
                    .build());

            userDetailsList.add(User.withUsername("admin")
                    .password("admin")
                    .roles("ADMIN")
                    .build());

            return new InMemoryUserDetailsManager(userDetailsList);
        }

        @Bean
        public PasswordEncoder passwordEncoder(){
            return NoOpPasswordEncoder.getInstance();
        }
}
EOL

echo "Creating gradle test dependencies..."
GRADLE_EXAMPLE="gradle-example.txt"


cat > $GRADLE_EXAMPLE <<EOL
implementation 'org.springframework.boot:spring-boot-starter-data-jdbc'
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
implementation 'org.springframework.boot:spring-boot-starter-security'
implementation 'org.springframework.boot:spring-boot-starter-validation'
implementation 'org.springframework.boot:spring-boot-starter-web'
compileOnly 'org.projectlombok:lombok'
runtimeOnly 'org.postgresql:postgresql'
annotationProcessor 'org.projectlombok:lombok'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
testImplementation 'org.springframework.security:spring-security-test'
testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
implementation 'org.mapstruct:mapstruct:1.6.3'
annotationProcessor 'org.mapstruct:mapstruct-processor:1.6.3'
EOL

echo "Creating exception advice example..."

EXCEPTIONS_CONTROLLER="src/main/java/$GROUP/$ARTIFACT/adapters/in/web/common/ExceptionControllerAdvice.java"

# Ensure the folder structure exists
# shellcheck disable=SC2046
mkdir -p $(dirname "$EXCEPTIONS_CONTROLLER")

cat > $EXCEPTIONS_CONTROLLER <<EOL
package hotel.reservations.infraestructure.web.common;

import hotel.reservations.domain.exceptions.ApplicationException;
import jakarta.validation.ValidationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.support.WebExchangeBindException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class ExceptionControllerAdvice {

    @ExceptionHandler(ApplicationException.class)
    public ResponseEntity<ResponseDTO> applicationException(ApplicationException ex){

        ResponseDTO responseDTO = ResponseDTO.builder()
                .message(ex.getMessage())
                .status(HttpStatus.BAD_GATEWAY.value())
                .build();
        return ResponseEntity.status(HttpStatus.BAD_GATEWAY).body(responseDTO);
    }

    @ExceptionHandler(WebExchangeBindException.class)
    public ResponseEntity<Map<String, Object>> handleValidationExceptions(WebExchangeBindException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error ->
                errors.put(error.getField(), error.getDefaultMessage())
        );
        Map<String, Object> response = new HashMap<>();
        response.put("data", errors);
        response.put("status", HttpStatus.BAD_REQUEST.value());
        response.put("message", "Validation error occurred");

        return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
    }
}
EOL

echo "Creating rest template example..."

REST_TEMPLATE="src/main/java/$GROUP/$ARTIFACT/adapters/rest/trivia/TriviaRepositoryAdapter.java"

# Ensure the folder structure exists
# shellcheck disable=SC2046
mkdir -p $(dirname "$REST_TEMPLATE")

# Create the Java file with the specified content
cat > $REST_TEMPLATE <<EOL

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class TriviaRepositoryAdapter {

    private final RestTemplate restTemplate;
    private String uri = "https://opentdb.com/api.php";

    public List<QuestionTrivia> questionTrivia(int amount){


        ResponseEntity<String> response = restTemplate.exchange(
                uri+"?amount="+amount, HttpMethod.GET, null, String.class);

        List<QuestionTrivia> questionTrivias = new ArrayList<>();
        try{
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());
            JsonNode results = root.path("results");
            System.out.println(results.toString());
            questionTrivias = mapper.readValue(results.toString(), new TypeReference<List<QuestionTrivia>>() {
            });
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return questionTrivias;
    }
}
EOL





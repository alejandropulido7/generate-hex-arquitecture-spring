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

create_dir "src/main/java/$GROUP/$ARTIFACT/domain/exceptions"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/gateway"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/model/service1"
create_dir "src/main/java/$GROUP/$ARTIFACT/domain/model/service2"

create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/persistence/config"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/persistence/service1"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/persistence/service2"

create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/web/common"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/web/service1"
create_dir "src/main/java/$GROUP/$ARTIFACT/adapters/web/service2"

rm "src/main/resources/application.properties"

# Print completion message
echo "Hexagonal Architecture Folder Structure created successfully in root directory"

echo "Creating application.yml..."
# Define the path for the YAML file
YML_FILE="src/main/resources/application.yml"

# Create the YAML file with the specified content
cat > $YML_FILE <<EOL
spring:
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: America/Bogota
  webflux:
    base-path: /api/hotel
  application:
    name: reservations
  r2dbc.url: "${POSTGRES_URL}"
  r2dbc.username: "${POSTGRES_USER}"
  r2dbc.password: "${POSTGRES_PASSWORD}"
server:
  port: 8085
  error:
    include-message: never
    include-binding-errors: always
constants:
  sql-schema: "${SCHEMA_SQL:src/main/resources/schema.sql}"
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
      - POSTGRES_URL=r2dbc:postgresql://postgres:5432/hotel-reservations
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
            return new BCryptPasswordEncoder();
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


EXCEPTIONS_CONTROLLER="src/main/java/$GROUP/$ARTIFACT/adapters/web/common/ExceptionControllerAdvice.java"

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





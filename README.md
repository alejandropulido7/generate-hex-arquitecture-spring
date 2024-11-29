# How bash file works

This is a bash script which will create a hexagonal arquitecture structure folder (It's just a template). 
Also, this script will create a dockerfile and docker-compose example, application.yml and some java classes configurations
like to connect a postgres database and initialize tables, basic spring security configuration and exception handler configuration.

## Note: All this is for a Spring webflux application

## Steps!
- Change the GROUP and ARTIFACT variables for your project names
  ```
  GROUP="com/example"
  ARTIFACT="demo"
  ```
- Paste the bash file in your root project
- Execute bash script (if you use Intellij you can execute from the IDE)
- Copy dependecies located in gradle-example file and paste to the gradle.build file
- Import classes that will be neccesary
- Correct package reference of SecurityBeans.java, InitializeDB.java and ExceptionControllerAdvice.java


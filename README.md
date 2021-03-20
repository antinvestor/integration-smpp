# integration-smpp

A camel route to send messages to an smpp connection either from being invoked or from pulling from a pub sub queue

## Building :
Locally you just run 
 
 `./gradlew jibDockerBuild --image=antinvestor/integration-smpp`

## Running :

    `docker run -e CONFIGURATION_FILE=/etc/smpp/config/service.ini  antinvestor/integration-smpp`

## Environment variables

- **CONFIGURATION_FILE** : References the file with config settings 

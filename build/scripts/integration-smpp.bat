@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  integration-smpp startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and INTEGRATION_SMPP_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\integration-smpp-v1.0.0.jar;%APP_HOME%\lib\camel-core-3.8.0.jar;%APP_HOME%\lib\camel-main-3.8.0.jar;%APP_HOME%\lib\camel-management-3.8.0.jar;%APP_HOME%\lib\camel-rest-3.8.0.jar;%APP_HOME%\lib\camel-netty-http-3.8.0.jar;%APP_HOME%\lib\camel-http-3.8.0.jar;%APP_HOME%\lib\camel-jackson-3.8.0.jar;%APP_HOME%\lib\camel-opentelemetry-3.8.0.jar;%APP_HOME%\lib\camel-log-3.8.0.jar;%APP_HOME%\lib\camel-nats-3.8.0.jar;%APP_HOME%\lib\camel-google-pubsub-3.8.0.jar;%APP_HOME%\lib\camel-smpp-3.8.0.jar;%APP_HOME%\lib\commons-configuration2-2.7.jar;%APP_HOME%\lib\commons-beanutils-1.9.4.jar;%APP_HOME%\lib\google-cloud-logging-logback-0.120.1-alpha.jar;%APP_HOME%\lib\camel-health-3.8.0.jar;%APP_HOME%\lib\camel-xml-jaxb-3.8.0.jar;%APP_HOME%\lib\camel-core-engine-3.8.0.jar;%APP_HOME%\lib\camel-core-languages-3.8.0.jar;%APP_HOME%\lib\camel-bean-3.8.0.jar;%APP_HOME%\lib\camel-browse-3.8.0.jar;%APP_HOME%\lib\camel-file-3.8.0.jar;%APP_HOME%\lib\camel-cluster-3.8.0.jar;%APP_HOME%\lib\camel-controlbus-3.8.0.jar;%APP_HOME%\lib\camel-dataformat-3.8.0.jar;%APP_HOME%\lib\camel-dataset-3.8.0.jar;%APP_HOME%\lib\camel-direct-3.8.0.jar;%APP_HOME%\lib\camel-directvm-3.8.0.jar;%APP_HOME%\lib\camel-language-3.8.0.jar;%APP_HOME%\lib\camel-mock-3.8.0.jar;%APP_HOME%\lib\camel-ref-3.8.0.jar;%APP_HOME%\lib\camel-saga-3.8.0.jar;%APP_HOME%\lib\camel-scheduler-3.8.0.jar;%APP_HOME%\lib\camel-stub-3.8.0.jar;%APP_HOME%\lib\camel-vm-3.8.0.jar;%APP_HOME%\lib\camel-seda-3.8.0.jar;%APP_HOME%\lib\camel-timer-3.8.0.jar;%APP_HOME%\lib\camel-validator-3.8.0.jar;%APP_HOME%\lib\camel-xpath-3.8.0.jar;%APP_HOME%\lib\camel-xslt-3.8.0.jar;%APP_HOME%\lib\camel-xml-jaxp-3.8.0.jar;%APP_HOME%\lib\camel-base-engine-3.8.0.jar;%APP_HOME%\lib\camel-base-3.8.0.jar;%APP_HOME%\lib\camel-netty-3.8.0.jar;%APP_HOME%\lib\camel-http-common-3.8.0.jar;%APP_HOME%\lib\camel-http-base-3.8.0.jar;%APP_HOME%\lib\camel-tracing-3.8.0.jar;%APP_HOME%\lib\camel-core-reifier-3.8.0.jar;%APP_HOME%\lib\camel-cloud-3.8.0.jar;%APP_HOME%\lib\camel-core-model-3.8.0.jar;%APP_HOME%\lib\camel-attachments-3.8.0.jar;%APP_HOME%\lib\camel-core-processor-3.8.0.jar;%APP_HOME%\lib\camel-support-3.8.0.jar;%APP_HOME%\lib\camel-api-3.8.0.jar;%APP_HOME%\lib\camel-management-api-3.8.0.jar;%APP_HOME%\lib\camel-util-3.8.0.jar;%APP_HOME%\lib\jsmpp-2.3.11.jar;%APP_HOME%\lib\slf4j-api-1.7.30.jar;%APP_HOME%\lib\camel-tooling-model-3.8.0.jar;%APP_HOME%\lib\netty-codec-http-4.1.59.Final.jar;%APP_HOME%\lib\javax.servlet-api-3.1.0.jar;%APP_HOME%\lib\google-cloud-pubsub-1.110.3.jar;%APP_HOME%\lib\httpclient-4.5.13.jar;%APP_HOME%\lib\jackson-core-2.12.1.jar;%APP_HOME%\lib\jackson-annotations-2.12.1.jar;%APP_HOME%\lib\jackson-databind-2.12.1.jar;%APP_HOME%\lib\grpc-netty-shaded-1.35.0.jar;%APP_HOME%\lib\opentelemetry-sdk-0.11.0.jar;%APP_HOME%\lib\opentelemetry-sdk-metrics-0.11.0.jar;%APP_HOME%\lib\opentelemetry-sdk-tracing-0.11.0.jar;%APP_HOME%\lib\opentelemetry-sdk-common-0.11.0.jar;%APP_HOME%\lib\opentelemetry-api-0.11.0.jar;%APP_HOME%\lib\jnats-2.8.0.jar;%APP_HOME%\lib\commons-text-1.8.jar;%APP_HOME%\lib\commons-lang3-3.9.jar;%APP_HOME%\lib\commons-logging-1.2.jar;%APP_HOME%\lib\commons-collections-3.2.2.jar;%APP_HOME%\lib\logback-classic-1.2.3.jar;%APP_HOME%\lib\logback-core-1.2.3.jar;%APP_HOME%\lib\google-cloud-logging-2.1.3.jar;%APP_HOME%\lib\grpc-core-1.35.0.jar;%APP_HOME%\lib\grpc-api-1.35.0.jar;%APP_HOME%\lib\guava-30.1-android.jar;%APP_HOME%\lib\proto-google-cloud-pubsub-v1-1.92.3.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\checker-compat-qual-2.5.5.jar;%APP_HOME%\lib\error_prone_annotations-2.5.1.jar;%APP_HOME%\lib\j2objc-annotations-1.3.jar;%APP_HOME%\lib\grpc-auth-1.35.0.jar;%APP_HOME%\lib\grpc-context-1.35.0.jar;%APP_HOME%\lib\animal-sniffer-annotations-1.20.jar;%APP_HOME%\lib\grpc-stub-1.35.0.jar;%APP_HOME%\lib\grpc-protobuf-1.35.0.jar;%APP_HOME%\lib\grpc-protobuf-lite-1.35.0.jar;%APP_HOME%\lib\javax.annotation-api-1.3.2.jar;%APP_HOME%\lib\auto-value-annotations-1.7.4.jar;%APP_HOME%\lib\protobuf-java-3.15.0.jar;%APP_HOME%\lib\protobuf-java-util-3.15.0.jar;%APP_HOME%\lib\google-auth-library-oauth2-http-0.23.0.jar;%APP_HOME%\lib\google-http-client-gson-1.38.1.jar;%APP_HOME%\lib\gson-2.8.6.jar;%APP_HOME%\lib\proto-google-common-protos-2.0.1.jar;%APP_HOME%\lib\proto-google-cloud-logging-v2-0.86.3.jar;%APP_HOME%\lib\gax-1.61.0.jar;%APP_HOME%\lib\opencensus-api-0.28.0.jar;%APP_HOME%\lib\gax-grpc-1.61.0.jar;%APP_HOME%\lib\google-auth-library-credentials-0.23.0.jar;%APP_HOME%\lib\grpc-alts-1.35.0.jar;%APP_HOME%\lib\grpc-grpclb-1.35.0.jar;%APP_HOME%\lib\conscrypt-openjdk-uber-2.5.1.jar;%APP_HOME%\lib\threetenbp-1.5.0.jar;%APP_HOME%\lib\google-cloud-core-grpc-1.94.1.jar;%APP_HOME%\lib\google-http-client-jackson2-1.38.1.jar;%APP_HOME%\lib\google-http-client-1.38.1.jar;%APP_HOME%\lib\commons-codec-1.15.jar;%APP_HOME%\lib\httpcore-4.4.13.jar;%APP_HOME%\lib\opencensus-contrib-http-util-0.28.0.jar;%APP_HOME%\lib\annotations-4.1.1.4.jar;%APP_HOME%\lib\perfmark-api-0.23.0.jar;%APP_HOME%\lib\proto-google-iam-v1-1.0.8.jar;%APP_HOME%\lib\api-common-1.10.1.jar;%APP_HOME%\lib\google-cloud-core-1.94.1.jar;%APP_HOME%\lib\jaxb-impl-2.3.3.jar;%APP_HOME%\lib\jakarta.xml.bind-api-2.3.3.jar;%APP_HOME%\lib\jaxb-core-2.3.0.jar;%APP_HOME%\lib\camel-util-json-3.8.0.jar;%APP_HOME%\lib\netty-handler-4.1.59.Final.jar;%APP_HOME%\lib\netty-codec-4.1.59.Final.jar;%APP_HOME%\lib\netty-transport-native-epoll-4.1.59.Final.jar;%APP_HOME%\lib\netty-transport-native-unix-common-4.1.59.Final.jar;%APP_HOME%\lib\netty-transport-4.1.59.Final.jar;%APP_HOME%\lib\netty-buffer-4.1.59.Final.jar;%APP_HOME%\lib\netty-resolver-4.1.59.Final.jar;%APP_HOME%\lib\netty-common-4.1.59.Final.jar;%APP_HOME%\lib\commons-pool-1.6.jar;%APP_HOME%\lib\opentelemetry-context-0.11.0.jar;%APP_HOME%\lib\eddsa-0.3.0.jar;%APP_HOME%\lib\jakarta.activation-api-1.2.2.jar;%APP_HOME%\lib\jakarta.activation-1.2.2.jar;%APP_HOME%\lib\javax.activation-1.2.0.jar


@rem Execute integration-smpp
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %INTEGRATION_SMPP_OPTS%  -classpath "%CLASSPATH%" com.antinvestor.integration.smpp.Application %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable INTEGRATION_SMPP_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
if  not "" == "%INTEGRATION_SMPP_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega

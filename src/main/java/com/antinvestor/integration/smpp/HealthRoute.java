package com.antinvestor.integration.smpp;

import org.apache.camel.Exchange;
import org.apache.camel.health.HealthCheck;
import org.apache.camel.health.HealthCheckHelper;

import java.util.Collection;
import java.util.stream.Collectors;

import static org.apache.camel.Exchange.HTTP_RESPONSE_CODE;
import static org.apache.http.HttpHeaders.CONTENT_TYPE;

public class HealthRoute extends org.apache.camel.builder.RouteBuilder {

    @Override
    public void configure() throws Exception {

        rest("/health/readiness").get().route()
                .setHeader(CONTENT_TYPE, constant("application/json"))
                .process(exchange -> setHealthCheckResult(exchange, HealthCheckHelper.invokeReadiness(getContext())))
                .marshal().json();

        rest("/health/liveliness").get().route()
                .setHeader(CONTENT_TYPE, constant("application/json"))
                .process(exchange -> setHealthCheckResult(exchange, HealthCheckHelper.invokeLiveness(getContext())))
                .marshal().json();


    }

    private void setHealthCheckResult(final Exchange exchange,
                                      final Collection<HealthCheck.Result> results) {
        if (results.stream().anyMatch(it -> it.getState() != HealthCheck.State.UP)) {
            exchange.getMessage().setHeader(HTTP_RESPONSE_CODE, 503);
        }
        exchange.getMessage().setBody(results.stream().map(HealthCheck.Result::getDetails).collect(Collectors.toList()));
    }
}

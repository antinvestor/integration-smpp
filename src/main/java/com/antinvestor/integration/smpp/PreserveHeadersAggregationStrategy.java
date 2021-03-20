package com.antinvestor.integration.smpp;

import org.apache.camel.Exchange;

import java.util.Map;

public class PreserveHeadersAggregationStrategy implements org.apache.camel.AggregationStrategy {
    @Override
    public Exchange aggregate(Exchange original, Exchange resource) {
        // use body from getIn() or getOut() depending on the exchange pattern...

        Map<String, Object> headersMap = resource.getIn().getHeaders();
        for (String header : headersMap.keySet()) {
            original.getIn().setHeader(header, headersMap.get(header));
        }

        original.getIn().setBody(resource.getIn().getBody());

        return original;
    }
}

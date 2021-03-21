package com.antinvestor.integration.smpp;

import org.apache.camel.Exchange;
import org.apache.camel.LoggingLevel;
import org.apache.camel.Message;
import org.apache.camel.Processor;
import org.apache.camel.component.smpp.SmppConstants;
import org.apache.camel.health.HealthCheck;
import org.apache.camel.health.HealthCheckHelper;
import org.apache.camel.model.dataformat.JsonLibrary;
import org.apache.camel.model.rest.RestBindingMode;
import org.apache.commons.configuration2.CompositeConfiguration;
import org.apache.commons.configuration2.EnvironmentConfiguration;
import org.apache.commons.configuration2.INIConfiguration;
import org.apache.commons.configuration2.builder.FileBasedConfigurationBuilder;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.ex.ConfigurationException;
import org.apache.http.util.TextUtils;

import java.io.File;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import static org.apache.camel.Exchange.HTTP_RESPONSE_CODE;
import static org.apache.http.HttpHeaders.CONTENT_TYPE;

public class SmppRouteBuilder extends org.apache.camel.builder.RouteBuilder {
    private final String ROUTE_ID_HEAD = "route_id_head";

    private String getRouteConnector() {
        return "direct:gateway-sms-route";
    }

    @Override
    public void configure() throws Exception {

        CompositeConfiguration configs = loadConfigs();

        restConfiguration()
                .component("netty-http")
                .host("0.0.0.0")
                .port(configs.getInt("PORT"))
                .bindingMode(RestBindingMode.auto)
                .clientRequestValidation(true);

        rest("/")
                .post()
                .type(Map.class)
                .to(getRouteConnector());


        from(getRouteConnector())
                .bean((Processor) exchange -> {

                    Message in = exchange.getIn();
                    Map<String, String> body = in.getBody(Map.class);

                    in.setHeader(ROUTE_ID_HEAD, getLastMileRoute(configs, body.get(configs.getString("FIELD_ROUTE_ID"))));
                    in.setHeader(SmppConstants.DEST_ADDR, body.get(configs.getString("FIELD_TO")));
                    in.setHeader(SmppConstants.SOURCE_ADDR, body.get(configs.getString("FIELD_FROM")));
                    in.setHeader("INTERNAL_SYSTEM_MESSAGE_ID", body.get(configs.getString("FIELD_MESSAGE_ID")));
                    in.setBody(body.get(configs.getString("FIELD_DATA")));

                })
                .log(LoggingLevel.INFO, "Outbound message : ${in.headers.CamelSmppMessageType} to : ${in.headers.CamelSmppDestAddr}")
                .toD(String.format("${header.%s}", ROUTE_ID_HEAD));

        for (String activeRoute : configs.getString("ACTIVE_ROUTES").split(",")) {

            if (TextUtils.isBlank(activeRoute)) {
                continue;
            }

            String smppConnectionRoute = String.format(
                    "smpp://%s@%s:%s?password=%s&enquireLinkTimer=%s&transactionTimer=%s" +
                            "&destAddrNpi=%s&destAddrTon=%s&sourceAddrNpi=%s&sourceAddrTon=%s" +
                            "&systemType=%s&priorityFlag=%s&registeredDelivery=%s",
                    configs.getString(getRouteConfigName(activeRoute, "USERNAME")),

                    configs.getString(getRouteConfigName(activeRoute, "HOST")),
                    configs.getString(getRouteConfigName(activeRoute, "PORT")),

                    configs.getString(getRouteConfigName(activeRoute, "PASSWORD")),
                    configs.getString(getRouteConfigName(activeRoute, "ENQUIRE_LINK_TIME")),
                    configs.getString(getRouteConfigName(activeRoute, "TRANSACTION_TIME")),
                    configs.getString(getRouteConfigName(activeRoute, "DESTINATION_ADDRESS_NPI")),
                    configs.getString(getRouteConfigName(activeRoute, "DESTINATION_ADDRESS_TON")),
                    configs.getString(getRouteConfigName(activeRoute, "SOURCE_ADDRESS_NPI")),
                    configs.getString(getRouteConfigName(activeRoute, "SOURCE_ADDRESS_TON")),
                    configs.getString(getRouteConfigName(activeRoute, "SYSTEM_TYPE")),
                    configs.getString(getRouteConfigName(activeRoute, "PRIORITY_FLAG")),
                    configs.getString(getRouteConfigName(activeRoute, "REGISTER_DELIVERY"))
            );


            long throttlingCount = configs.getLong(getRouteConfigName(activeRoute, "THROTTLING_COUNT"));
            from(getLastMileRoute(configs, activeRoute))
                    .throttle(throttlingCount)
                    .enrich(smppConnectionRoute, new PreserveHeadersAggregationStrategy())
                    .bean((Processor) exchange -> {
                        Message in = exchange.getIn();


                        String smppID = in.getHeader(SmppConstants.ID, String.class);
                        if (!TextUtils.isBlank(smppID)) {
                            smppID = smppID.replace("[", "").replace("]", "");
                        }

                        Map<String, String> result = new HashMap<>();
                        result.put(configs.getString("FIELD_TO"), in.getHeader(SmppConstants.DEST_ADDR, String.class));
                        result.put(configs.getString("FIELD_FROM"), in.getHeader(SmppConstants.DEST_ADDR, String.class));
                        result.put(configs.getString("FIELD_MESSAGE_ID"), in.getHeader("INTERNAL_SYSTEM_MESSAGE_ID", String.class));
                        result.put(configs.getString("FIELD_SMSC_ID"), smppID);
                        result.put(configs.getString("FIELD_SMSC_STATUS"), "Submitted");

                        in.setBody(result, Map.class);

                    })
                    .choice()
                    .when(exchange -> configs.getString(getRouteConfigName(activeRoute, "SMS_SEND_ACK_URL")).startsWith("http"))
                    .marshal().json()
                    .to(configs.getString(getRouteConfigName(activeRoute, "SMS_SEND_ACK_URL")))
                    .otherwise()
                    .to(configs.getString(getRouteConfigName(activeRoute, "SMS_SEND_ACK_URL")))
                    .endChoice();

            from(smppConnectionRoute)
                    .log(LoggingLevel.INFO, "Inbound message : ${in.headers.CamelSmppMessageType} for : ${in.headers.CamelSmppSourceAddr} ${in.headers.CamelSmppId}")
                    .bean((Processor) exchange -> {
                        Message in = exchange.getIn();

                        Map<String, String> result = new HashMap<>();

                        if (in.getHeaders().containsKey(SmppConstants.ID)) {
                            result.put(configs.getString("FIELD_SMSC_ID"), in.getHeader(SmppConstants.ID, String.class));
                        } else if (in.getHeaders().containsKey(SmppConstants.SEQUENCE_NUMBER)) {
                            result.put(configs.getString("FIELD_SMSC_ID"), in.getHeader(SmppConstants.SEQUENCE_NUMBER, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.FINAL_STATUS)) {
                            result.put(configs.getString("FIELD_SMSC_STATUS"), in.getHeader(SmppConstants.FINAL_STATUS, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.DELIVERED)) {
                            result.put("dlvrd", in.getHeader(SmppConstants.DELIVERED, String.class));
                        }


                        if (in.getHeaders().containsKey(SmppConstants.DELIVERED)) {
                            result.put("dlvrd", in.getHeader(SmppConstants.DELIVERED, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.SUBMITTED)) {
                            result.put("sub", in.getHeader(SmppConstants.SUBMITTED, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.SUBMIT_DATE)) {
                            result.put("submitted_date", in.getHeader(SmppConstants.SUBMIT_DATE, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.DONE_DATE)) {
                            result.put("done_date", in.getHeader(SmppConstants.DONE_DATE, String.class));
                        }


                        if (in.getHeaders().containsKey(SmppConstants.OPTIONAL_PARAMETERS)) {
                            result.put("smsc_extra", in.getHeader(SmppConstants.OPTIONAL_PARAMETERS, String.class));
                        }


                        if (in.getHeaders().containsKey(SmppConstants.DEST_ADDR)) {
                            result.put(configs.getString("FIELD_TO"), in.getHeader(SmppConstants.DEST_ADDR, String.class));
                        }

                        if (in.getHeaders().containsKey(SmppConstants.SOURCE_ADDR)) {
                            result.put(configs.getString("FIELD_FROM"), in.getHeader(SmppConstants.SOURCE_ADDR, String.class));
                        }

                        result.put("text", in.getBody(String.class));

                        in.setBody(result, Map.class);

                    }).marshal().json(JsonLibrary.Jackson).choice()
                    .when(header(SmppConstants.MESSAGE_TYPE).isEqualTo("DeliveryReceipt"))
                    .to(configs.getString(getRouteConfigName(activeRoute, "SMS_SEND_DLR_URL")))
                    .otherwise()
                    .to(configs.getString(getRouteConfigName(activeRoute, "SMS_RECEIVE_URL")))
                    .endChoice();

        }
    }

    private String getLastMileRoute(CompositeConfiguration configs, String routeId) {
        return String.format(configs.getString("LAST_MILE_CONNECTION"), routeId);
    }

    private String getRouteConfigName(String routeId, String config) {
        return String.format("%s.%s", routeId, config);
    }


    private CompositeConfiguration loadConfigs() throws ConfigurationException {
        CompositeConfiguration cc = new CompositeConfiguration();

        String configFile = System.getenv("CONFIGURATION_FILE");
        if (!TextUtils.isEmpty(configFile)) {
            File propertiesFile = new File(configFile);

            FileBasedConfigurationBuilder<INIConfiguration> builder =
                    new Configurations().fileBasedBuilder(INIConfiguration.class, propertiesFile);
            cc.addConfiguration(builder.getConfiguration());
        }

        cc.addConfiguration(new EnvironmentConfiguration());
        return cc;
    }


}

// SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
// SPDX-FileContributor: Andreas Schliebitz
// SPDX-FileContributor: Henri Graf
// SPDX-FileContributor: Jonas Tüpker
// SPDX-FileContributor: Lukas Hesse
// SPDX-FileContributor: Maik Fruhner
// SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
// SPDX-FileContributor: Tobias Wamhof
//
// SPDX-License-Identifier: MIT

package com.agri_gaia;

import org.jboss.logging.Logger;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpClient.Version;
import java.net.http.HttpRequest.BodyPublishers;
import java.util.HashMap;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

public class UserEventSender {

    private static final Logger LOGGER = Logger.getLogger(UserEventSender.class);

    private static final String TOKEN_ENDPOINT = "http://localhost:8080/realms/%s/protocol/openid-connect/token";
    private static final String HTTP_BODY_TEMPLATE = "client_id=%s&client_secret=%s&grant_type=client_credentials";

    private HttpClient client;
    private final URI registrationWebhookUri;
    private final URI deregistrationWebhookUri;
    private final String receiverClientId;
    private final String realmName;
    private final String clientSecret;

    public UserEventSender(String registrationWebhookUri, String deregistrationWebhookUri, String realmName,
            String receiverClientId, String clientSecret) {
        this.registrationWebhookUri = URI.create(registrationWebhookUri);
        this.deregistrationWebhookUri = URI.create(deregistrationWebhookUri);
        this.realmName = realmName;
        this.receiverClientId = receiverClientId;
        this.clientSecret = clientSecret;
    }

    private HttpClient httpClient() {
        if (this.client == null) {
            this.client = HttpClient.newHttpClient();
        }
        return this.client;
    }

    public void handleUserAdded(String username, String email, String fullName) {
        try {
            var accessToken = this.requestAccessToken();

            ObjectMapper jsonMapper = new ObjectMapper();
            var object = jsonMapper.createObjectNode();
            object.put("username", username);
            object.put("email", email);
            object.put("full_name", fullName);
            var payload = jsonMapper.writerWithDefaultPrettyPrinter().writeValueAsString(object);

            this.sendEventRequest(this.registrationWebhookUri, accessToken, payload);
        } catch (IOException | InterruptedException e) {
            LOGGER.error("ERROR: Error sending deregistration event request: " + e);
        }
    }

    public void handleUserRemoved(String username) {
        try {
            var accessToken = this.requestAccessToken();

            ObjectMapper jsonMapper = new ObjectMapper();
            var object = jsonMapper.createObjectNode();
            object.put("username", username);
            var payload = jsonMapper.writerWithDefaultPrettyPrinter().writeValueAsString(object);

            this.sendEventRequest(this.deregistrationWebhookUri, accessToken, payload);
        } catch (IOException | InterruptedException e) {
            LOGGER.error("ERROR: Error sending registration event request: " + e);
        }
    }

    private String requestAccessToken() throws IOException, InterruptedException {
        var httpBody = String.format(HTTP_BODY_TEMPLATE, this.receiverClientId, this.clientSecret);

        var request = HttpRequest.newBuilder()
                .uri(URI.create(String.format(TOKEN_ENDPOINT, this.realmName)))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(BodyPublishers.ofString(httpBody))
                .build();

        var response = httpClient().send(request, HttpResponse.BodyHandlers.ofString());
        var token = response.body();

        ObjectMapper jsonMapper = new ObjectMapper();
        TypeReference<HashMap<String, Object>> typeRef = new TypeReference<HashMap<String, Object>>() {
        };
        var tokenMap = jsonMapper.readValue(token, typeRef);
        String accessToken = tokenMap.get("access_token").toString();

        return accessToken;
    }

    private void sendEventRequest(URI uri, String accessToken, String payload)
            throws IOException, InterruptedException {

        var request = HttpRequest.newBuilder(uri)
                .version(Version.HTTP_1_1)
                .header("Authorization", "Bearer " + accessToken)
                .header("Content-Type", "application/json")
                .POST(BodyPublishers.ofString(payload))
                .build();

        var response = httpClient().send(request, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() != 200) {
            var formatString = "User event notification request to '%s' failed. Status code: %s. Payload: %s";
            LOGGER.errorf(formatString, uri, response.statusCode(), payload);
        }
    }
}

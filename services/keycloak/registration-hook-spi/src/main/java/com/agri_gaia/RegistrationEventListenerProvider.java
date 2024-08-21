// SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
// SPDX-FileContributor: Andreas Schliebitz
// SPDX-FileContributor: Henri Graf
// SPDX-FileContributor: Jonas Tüpker
// SPDX-FileContributor: Lukas Hesse
// SPDX-FileContributor: Maik Fruhner
// SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
// SPDX-FileContributor: Tobias Wamhof
//
// SPDX-License-Identifier: AGPL-3.0-or-later

package com.agri_gaia;

import java.util.Map;

import org.jboss.logging.Logger;
import org.keycloak.events.Event;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventType;
import org.keycloak.events.admin.AdminEvent;
import org.keycloak.events.admin.OperationType;
import org.keycloak.events.admin.ResourceType;
import org.keycloak.models.KeycloakSession;

class RegistrationEventListenerProvider implements EventListenerProvider {

    private static final Logger LOGGER = Logger.getLogger(RegistrationEventListenerProvider.class);

    private final UserEventSender eventSender;
    private final KeycloakSession session;

    public RegistrationEventListenerProvider(KeycloakSession session, UserEventSender eventSender) {
        this.eventSender = eventSender;
        this.session = session;
    }

    @Override
    public void onEvent(Event event) {
        LOGGER.debugf("event: %s", event.getType());
        if (EventType.REGISTER.equals(event.getType())) {
            var username = event.getDetails().get("username");
            if (!AgriGaiaUsernamePattern.isValidUsername(username)) {
                var realm = this.session.realms().getRealm(event.getRealmId());
                var user = this.session.users().getUserById(realm, event.getUserId());
                this.session.users().removeUser(realm, user);
                throw new IllegalArgumentException(
                        "Username has to be between 3 and 63 characters long and only lowercase letters, numbers, dots and hyphens are allowed.");
            }
            var email = event.getDetails().get("email");
            var fullName = event.getDetails().get("first_name") + " " + event.getDetails().get("last_name");
            if (this.eventSender != null) {
                this.eventSender.handleUserAdded(username, email, fullName);
            } else {
                LOGGER.warnf("Event sender is null. Shouldn't be at this point");
            }
        }
    }

    @Override
    public void onEvent(AdminEvent adminEvent, boolean includeRepresentation) {
        LOGGER.debugf("admin event: %s %s", adminEvent.getOperationType(), adminEvent.getResourceType());
        if (ResourceType.USER.equals(adminEvent.getResourceType())
                && OperationType.CREATE.equals(adminEvent.getOperationType())) {
            String resourcePath = adminEvent.getResourcePath();
            if (resourcePath.startsWith("users/")) {
                var userId = resourcePath.substring("users/".length());
                var realm = this.session.realms().getRealm(adminEvent.getRealmId());
                var user = this.session.users().getUserById(realm, userId);

                if (user != null) {
                    var username = user.getUsername();
                    if (!AgriGaiaUsernamePattern.isValidUsername(username)) {
                        this.session.users().removeUser(realm, user);
                        throw new IllegalArgumentException(
                                "Username has to be between 3 and 63 characters long and only lowercase letters, numbers, dots and hyphens are allowed.");
                    }
                    var email = user.getEmail();
                    var fullName = user.getFirstName() + " " + user.getLastName();
                    if (this.eventSender != null) {
                        this.eventSender.handleUserAdded(username, email, fullName);
                    } else {
                        LOGGER.warnf("Event sender is null. Shouldn't be at this point");
                    }
                } else {
                    LOGGER.warnf("User created by 'CREATE USER' Admin Event with the ID '%s' was not found", userId);
                }
            } else {
                LOGGER.warnf("AdminEvent was CREATE:USER without appropriate resourcePath=%s", resourcePath);
            }
        }
    }

    @SuppressWarnings("unused")
    private String eventToString(Event event) {

        StringBuilder sb = new StringBuilder();

        sb.append("type=");
        sb.append(event.getType());
        sb.append(", realmId=");
        sb.append(event.getRealmId());
        sb.append(", clientId=");
        sb.append(event.getClientId());
        sb.append(", userId=");
        sb.append(event.getUserId());
        sb.append(", ipAddress=");
        sb.append(event.getIpAddress());
        if (event.getError() != null) {
            sb.append(", error=");
            sb.append(event.getError());
        }
        if (event.getDetails() != null) {
            for (Map.Entry<String, String> e : event.getDetails().entrySet()) {
                sb.append(", ");
                sb.append(e.getKey());
                if (e.getValue() == null || e.getValue().indexOf(' ') == -1) {
                    sb.append("=");
                    sb.append(e.getValue());
                } else {
                    sb.append("='");
                    sb.append(e.getValue());
                    sb.append("'");
                }
            }
        }
        return sb.toString();
    }

    @Override
    public void close() {
        // Auto-generated method stub
    }

}
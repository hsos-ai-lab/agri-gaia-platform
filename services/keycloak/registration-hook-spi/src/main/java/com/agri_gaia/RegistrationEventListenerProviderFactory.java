// SPDX-FileCopyrightText: 2024 Osnabrück University of Applied Sciences
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

import java.util.LinkedHashMap;
import java.util.Map;

import org.jboss.logging.Logger;
import org.keycloak.Config;
import org.keycloak.events.EventListenerProvider;
import org.keycloak.events.EventListenerProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.UserModel;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.provider.ServerInfoAwareProviderFactory;

public class RegistrationEventListenerProviderFactory implements EventListenerProviderFactory, ServerInfoAwareProviderFactory {

    private static final Logger LOGGER = Logger.getLogger(RegistrationEventListenerProviderFactory.class);

    private String registrationWebhookUrl;
    private String deregistrationWebhookUrl;
    private String receiverClientId;
    private String realmName;

    @Override
    public EventListenerProvider create(KeycloakSession session) {
        UserEventSender eventSender = null;
        var realm = session.realms().getRealmByName(this.realmName);
        var client = realm.getClientByClientId(this.receiverClientId);
        if (client != null) {
            eventSender = new UserEventSender(registrationWebhookUrl, deregistrationWebhookUrl, this.realmName, this.receiverClientId, client.getSecret());
        }
        return new RegistrationEventListenerProvider(session, eventSender);
    }

    @Override
    public void init(Config.Scope config) {
        this.registrationWebhookUrl = System.getenv("REGISTRATION_EVENT_WEBHOOKURL");
        if (this.registrationWebhookUrl == null) {
            LOGGER.warn("Could not find env variable 'REGISTRATION_EVENT_WEBHOOKURL'!");
        }
        this.deregistrationWebhookUrl = System.getenv("DEREGISTRATION_EVENT_WEBHOOKURL");
        if (this.deregistrationWebhookUrl == null) {
            LOGGER.warn("Could not find env variable 'DEREGISTRATION_EVENT_WEBHOOKURL'!");
        }
        this.receiverClientId = System.getenv("WEBHOOK_RECEIVER_CLIENT_ID");
        if (this.receiverClientId == null) {
            LOGGER.warn("Could not find env variable 'WEBHOOK_RECEIVER_CLIENT_ID'!");
        }
        this.realmName = System.getenv("REALM_NAME");
        if (this.realmName == null) {
            LOGGER.warn("Could not find env variable 'REALM_NAME'!");
        }
    }

    @Override
    public void postInit(KeycloakSessionFactory ksFactory) {
        ksFactory.register(event -> {
            if (event instanceof UserModel.UserRemovedEvent) {
                UserModel.UserRemovedEvent removal = (UserModel.UserRemovedEvent) event;
                var realm = removal.getRealm();
                var clientSecret = realm.getClientByClientId(this.receiverClientId).getSecret();
                var eventSender = new UserEventSender(this.registrationWebhookUrl, this.deregistrationWebhookUrl, realm.getName(), this.receiverClientId, clientSecret);
                eventSender.handleUserRemoved(removal.getUser().getUsername());
            }
        });
    }

    @Override
    public void close() {
    }
    
    @Override
    public String getId() {
        return "registration-event-listener";
    }

    @Override
    public Map<String, String> getOperationalInfo() {
        Map<String, String> ret = new LinkedHashMap<>();
        ret.put("registrationWebhookUrl", this.registrationWebhookUrl);
        ret.put("deregistrationWebhookUrl", this.deregistrationWebhookUrl);
        return ret;
    }


}

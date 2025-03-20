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

import java.util.regex.Pattern;

public class AgriGaiaUsernamePattern {
    public static final Pattern PATTERN = Pattern.compile(
            "^(?!xn--)" + // Must not start with 'xn--'
                    "(?!.*\\d+\\.\\d+\\.\\d+\\.\\d+)" + // Must not be formatted as an IP address
                    "(?!.*[-.]{2,})" + // No consecutive hyphens or dots
                    "(?!.*[.-]$)" + // Must not end with a hyphen or dot
                    "[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$" // with a letter or number, length between 3 and 63
    );

    public static boolean isValidUsername(String username) {
        return PATTERN.matcher(username).matches();
    }
}

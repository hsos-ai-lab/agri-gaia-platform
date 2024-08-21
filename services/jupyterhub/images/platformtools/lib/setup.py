#!/usr/bin/env python

# SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# -*- coding: utf-8 -*-

from setuptools import setup

setup(
    name="platformtools",
    author='Maik Fruhner',
    author_email='m.fruhner@hs-osnabrueck.de',
    version="0.1",
    extras_require={"dev": ["black"]},
    packages=['platformtools'],
    install_requires=[
        'minio',
    ],
)

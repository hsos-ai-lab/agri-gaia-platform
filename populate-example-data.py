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

import json
import os
from typing import List
import requests
from dotenv import load_dotenv

load_dotenv()

import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

BASE_URL = os.environ.get("PROJECT_BASE_URL")
LOGIN_URL = (
    f"https://keycloak.{BASE_URL}/realms/test-realm/protocol/openid-connect/token"
)
BACKEND_URL = f"https://api.{BASE_URL}"
VERIFY_TLS = False
DATA_PATH = "data/example"

# login by querying the user for username and password and return the user's access token
def login() -> str:
    username = "Test"
    password = "Test"

    # username = input("Username:")
    # password = input("Password:")

    headers = {"Content-Type": "application/x-www-form-urlencoded"}

    data = f"grant_type=password&client_id=frontend&username={username}&password={password}"

    res = requests.post(LOGIN_URL, headers=headers, data=data, verify=VERIFY_TLS)
    return res.json()["access_token"]


def upload_dataset(
    access_token: str,
    name: str,
    description: str,
    semantic_labels: List[str] = [],
    annotation_labels: List[str] = [],
):
    print(f"Uploading Dataset {name}...")
    dataset_dir = f"{DATA_PATH}/datasets/{name}/"
    images = [
        f"{dataset_dir}{x}" for x in os.listdir(dataset_dir) if x.endswith(".jpg")
    ]

    annotation_file_paths = [
        f"{dataset_dir}{x}" for x in os.listdir(dataset_dir) if x.endswith(".xml")
    ]
    annotation_exists = len(annotation_file_paths) > 0

    headers = {"Authorization": f"Bearer {access_token}"}

    meta_data = (
        ("name", name),
        ("description", description),
        ("includes_annotation_file", annotation_exists),
    )

    for label in semantic_labels:
        new_label = ("semantic_labels", label)
        meta_data = meta_data + (new_label,)

    for label in annotation_labels:
        new_label = ("annotation_labels", label)
        meta_data = meta_data + (new_label,)

    files = [
        ("files", (img_path.split(os.sep)[-1], open(img_path, "rb")))
        for img_path in images
    ]

    if annotation_exists:
        annotation_file_path = annotation_file_paths[0]
        files.append(
            (
                "files",
                (
                    annotation_file_path.split(os.sep)[-1],
                    open(annotation_file_path, "rb"),
                    "text/xml",
                ),
            )
        )

    requests.post(
        f"{BACKEND_URL}/datasets",
        headers=headers,
        data=meta_data,
        files=files,
        verify=VERIFY_TLS,
    )


def upload_model(
    access_token: str,
    name: str,
    description: str,
    file_extension: str,
    model_format: str,
    semantic_labels: List[str] = [],
):
    print(f"Uploading Model {name}...")
    model = f"{DATA_PATH}/models/{name}.{file_extension}"

    headers = {"Authorization": f"Bearer {access_token}"}

    meta_data = (
        ("name", name),
        ("description", description),
        ("format", model_format),
    )

    for label in semantic_labels:
        new_label = ("labels", label)
        meta_data = meta_data + (new_label,)

    files = [("files", (model.split(os.sep)[-1], open(model, "rb")))]

    requests.post(
        f"{BACKEND_URL}/models",
        headers=headers,
        data=meta_data,
        files=files,
        verify=VERIFY_TLS,
    )


def create_edge_device(
    access_token: str,
    name: str,
    tags: List[str] = [],
):
    print(f"Creating Edge Device {name}...")

    headers = {"Authorization": f"Bearer {access_token}"}

    meta_data = {"name": name, "tags": tags}

    requests.post(
        f"{BACKEND_URL}/edge-devices",
        headers=headers,
        json=meta_data,
        verify=VERIFY_TLS,
    )


def create_edge_group(
    access_token: str,
    name: str,
):
    print(f"Creating Edge Group {name}...")

    headers = {"Authorization": f"Bearer {access_token}"}

    response_tags = requests.get(
        f"{BACKEND_URL}/tags",
        headers=headers,
        verify=VERIFY_TLS,
    )

    tag_ids = []

    for id in response_tags.json()[:5]:
        tag_ids.append(id["id"])

    meta_data = {"name": f"{name}", "tag_ids": tag_ids}

    requests.post(
        f"{BACKEND_URL}/edge-groups",
        headers=headers,
        json=meta_data,
        verify=VERIFY_TLS,
    )


def create_application(
    access_token: str,
    name: str,
    edge_groups: List[int] = [],
):
    print(f"Creating Application {name}...")

    headers = {"Authorization": f"Bearer {access_token}"}

    response_edge_groups = requests.get(
        f"{BACKEND_URL}/edge-groups",
        headers=headers,
        verify=VERIFY_TLS,
    )

    edge_group_ids = []

    for id in response_edge_groups.json()[:5]:
        edge_group_ids.append(id["id"])

    data = {
        "name": "Test-Application-2",
        "group_ids": edge_group_ids,
        "yaml": """version: '3'
    services:
        postgres_backend:
            image: postgres:14
            restart: unless-stopped
            expose:
              - "5432"
            volumes:
              - postgres-data:/var/lib/postgresql/data
                              
        reverse_proxy:
            image: traefik:v2.8.4
            restart: unless-stopped
            ports:
              # The React Frontend
              - "80:80"
              - "443:443"
              - "8000:8000"
              # The Traefik Web UI (enabled by --api.insecure=true)
              - "11000:8080"
            volumes:
              # So that Traefik can listen to the Docker events
              - /var/run/docker.sock:/var/run/docker.sock
              - ./config/traefik/dynamic/:/configuration/
    """,
    }

    requests.post(
        f"{BACKEND_URL}/applications",
        headers=headers,
        json=data,
        verify=VERIFY_TLS,
    )


if __name__ == "__main__":
    access_token = login()
    upload_dataset(
        access_token,
        "potatoes",
        "A Potato Dataset",
        ["http://aims.fao.org/aos/agrovoc/c_7221"],  # European Potato
        ["kartoffel_gut", "kartoffel_rot", "green"],
    )
    upload_dataset(
        access_token,
        "pigs",
        "A Pig Dataset",
        ["http://aims.fao.org/aos/agrovoc/c_59e0f842"],  # Fattening Pigs
        ["Pig", "Head", "Tail", "Ear-Tag"],
    )
    upload_dataset(
        access_token,
        "camera-calibration",
        "A Camera Calibration Dataset",
        ["http://aims.fao.org/aos/agrovoc/c_36549"],  # calibration
        ["Schachbrett"],
    )

    upload_model(
        access_token,
        "mnist",
        "Digit recognition",
        "onnx",
        "onnx",
        ["http://aims.fao.org/aos/agrovoc/c_1653"],  # classification
    )
    upload_model(
        access_token,
        "mobilenetv2-int8",
        "common classification in int8 precision",
        "onnx",
        "onnx",
        ["http://aims.fao.org/aos/agrovoc/c_1653"],  # classification
    )
    upload_model(
        access_token,
        "mobilenetv2",
        "common classification",
        "onnx",
        "onnx",
        ["http://aims.fao.org/aos/agrovoc/c_1653"],  # classification
    )
    create_edge_device(access_token, "Test-Edge-Device", ["Test 1", "Test 2"])
    create_edge_group(access_token, "Test-Edge-Group")
    create_application(access_token, "Test Application")
    print(f"Done.")

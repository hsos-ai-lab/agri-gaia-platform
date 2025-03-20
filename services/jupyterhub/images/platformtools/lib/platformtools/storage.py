# SPDX-FileCopyrightText: 2024 University of Applied Sciences Osnabrück
# SPDX-FileContributor: Andreas Schliebitz
# SPDX-FileContributor: Henri Graf
# SPDX-FileContributor: Jonas Tüpker
# SPDX-FileContributor: Lukas Hesse
# SPDX-FileContributor: Maik Fruhner
# SPDX-FileContributor: Prof. Dr.-Ing. Heiko Tapken
# SPDX-FileContributor: Tobias Wamhof
#
# SPDX-License-Identifier: MIT

import os
import json
import requests
import subprocess

from glob import glob

from minio import Minio
from minio.credentials import WebIdentityProvider

from platformtools.constants import BACKEND_URL, MOUNT_POINT
from platformtools.auth import (
    get_access_token,
    fetch_auth_tokens,
    load_tokens,
    BackendAuth,
)


class PlatformStorage(Minio):
    def __init__(self):
        fetch_auth_tokens()  # TODO: refresh
        self._endpoint = "minio:9000"
        self._endpoint_url = f"http://{self._endpoint}"

        self._credentials = self._get_credentials_provider(
            self._endpoint_url, load_tokens, secure=False
        )

        super().__init__(
            self._endpoint,
            access_key=None,
            secret_key=None,
            session_token=None,
            secure=False,
            region=None,
            http_client=None,
            credentials=self._credentials,
        )

        self.datasets = DatasetStorage(self)
        self.models = ModelStorage(self)
        self.inference = InferenceStorage(self)
        self.services = ServiceStorage(self)
        self.benchmarks = BenchmarkStorage(self)

    def _get_credentials_provider(
        self,
        s3_endpoint_url,
        credentials_func=None,
        secure=True,
    ):
        assert credentials_func
        return WebIdentityProvider(credentials_func, s3_endpoint_url, secure)

    def mount_bucket(self, bucket_name):
        bucket_mount_point = os.path.join(MOUNT_POINT, bucket_name)
        os.makedirs(bucket_mount_point, exist_ok=True)
        subprocess.run(
            [
                "mount-s3.sh",
                "-t",
                get_access_token(),
                "-s",
                self._endpoint_url,
                "-b",
                bucket_name,
                "-m",
                bucket_mount_point,
            ],
            check=True,
            text=True,
        )

    def mount_bucket_for_object(self, s3_object):
        return self.mount_bucket(s3_object["bucket_name"])

    def get_mounted_path_for_object(self, s3_object):
        bucket = s3_object["bucket_name"]
        loc = s3_object["minio_location"]
        return f"{MOUNT_POINT}/{bucket}/{loc}"

    def mount_bucket_for_service(self, service):
        return self.mount_bucket(service["bucket_name"])

    def get_mounted_path_for_service(self, service):
        bucket = service["bucket_name"]
        name = service["name"]
        return f"{MOUNT_POINT}/{bucket}/services/{name}/"


class DatasetStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/datasets", auth=BackendAuth())
        r.raise_for_status()
        return r.json()


class ModelStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/models", auth=BackendAuth())
        r.raise_for_status()
        return r.json()


class InferenceStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/triton", auth=BackendAuth())
        r.raise_for_status()
        return r.json()


class InferenceStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/triton", auth=BackendAuth())
        r.raise_for_status()
        return r.json()


class BenchmarkStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/edge-benchmark", auth=BackendAuth())
        r.raise_for_status()
        return r.json()


class ServiceStorage:
    def __init__(self, mc: PlatformStorage) -> None:
        self.mc = mc

    def list(self):
        r = requests.get(f"{BACKEND_URL}/integrated-services", auth=BackendAuth())
        r.raise_for_status()
        return r.json()

    def get_definition(self, service):
        sp = self.mc.get_mounted_path_for_service(
            service
        )  # '/home/jovyan/.buckets/maik/services/bright/'
        path_splits = sp.split(os.sep)
        path = path_splits[:-2]
        name = path_splits[-2]
        path.extend(["definitions", name, f"{name}.json"])
        sp = os.path.join("/", *path)
        with open(sp, "r") as sdf:
            return json.load(sdf)

    def list_endpoints(self, service):
        # '/home/jovyan/.buckets/maik/services/bright/'
        endpoints_path = self.mc.get_mounted_path_for_service(service)

        if not os.path.exists(endpoints_path):
            print("Service has no called endpoints, yet. Please do a request first.")

        return [call.split("/")[-1] for call in glob(f"{endpoints_path}/*")]

    def list_calls(self, service, endpoint):
        endpoints_path = self.mc.get_mounted_path_for_service(service)

        return [call.split("/")[-1] for call in glob(f"{endpoints_path}/{endpoint}/*")]

    def list_call_history(self, service, endpoint, call):
        endpoints_path = self.mc.get_mounted_path_for_service(service)

        return [
            call.split("/")[-1]
            for call in glob(f"{endpoints_path}/{endpoint}/{call}/*")
        ]

    def get_call_data(self, service, endpoint, call, time, requested_data="output"):
        file_path = os.path.join(
            self.mc.get_mounted_path_for_service(service),
            endpoint,
            call,
            time,
            f"{requested_data}.json",
        )

        if not os.path.exists(file_path):
            print("No such service call or data.")

        with open(file_path, "r") as data:
            return json.load(data)

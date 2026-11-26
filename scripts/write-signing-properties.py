"""Write Java Properties without misinterpreting signing passwords."""

import os
from pathlib import Path


def escape(value: str) -> str:
    encoded = value.encode("utf-16-be")
    return "".join(
        f"\\u{int.from_bytes(encoded[index:index + 2], 'big'):04x}"
        for index in range(0, len(encoded), 2)
    )


entries = {
    "storeFile": "upload.jks",
    "storePassword": os.environ["STORE_PASSWORD"],
    "keyAlias": os.environ["KEY_ALIAS"],
    "keyPassword": os.environ["KEY_PASSWORD"],
}
Path("android/key.properties").write_text(
    "".join(f"{key}={escape(value)}\n" for key, value in entries.items()),
    encoding="ascii",
)

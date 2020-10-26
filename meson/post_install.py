#!/usr/bin/env python3

import os
import subprocess

subprocess.call(
    [
        "glib-compile-schemas",
        os.path.join(
            os.environ["MESON_INSTALL_PREFIX"], "share", "glib-2.0", "schemas"
        ),
    ]
)

import os
import pathlib

from conans import ConanFile

class UraniumConan(ConanFile):
    name = "uranium"
    version = "5.0.0"
    license = "LGPL-3.0"
    author = "Ultimaker B.V."
    url = "https://github.com/Ultimaker/uranium"
    description = "A Python framework for building Desktop applications."
    topics = ("conan", "python", "pyqt6", "qt", "3d-graphics", "3d-models", "python-framework")
    settings = "os", "compiler", "build_type", "arch"
    revision_mode = "scm"
    build_policy = "missing"
    default_user = "ultimaker"
    default_channel = "testing"
    exports = "LICENSE*"
    python_requires = ["UltimakerBase/0.1@ultimaker/testing"]
    python_requires_extend = "UltimakerBase.UltimakerBase"
    options = {
        "testing": [True, False],
        "devtools": [True, False]
    }
    default_options = {
        "testing": False,
        "devtools": False
    }
    scm = {
        "type": "git",
        "subfolder": ".",
        "url": "auto",
        "revision": "auto"
    }

    def requirements(self):
        self.requires(f"python/3.10.2@python/stable")
        self.requires(f"pyqt6/6.2.2@python/stable")
        self.requires(f"pyarcus/5.0.0@ultimaker/testing")
        self.requires(f"scipy/1.8.0rc2@python/stable")
        self.requires(f"numpy/1.21.5@python/stable")
        self.requires(f"numpy-stl/2.10.1@python/stable")
        self.requires(f"cryptography/3.4.8@python/stable")
        self.requires(f"pyclipper/1.3.0.post2@python/stable")
        if self.options.testing:
            self.requires(f"pytest/5.2.1@python/stable")
            self.requires(f"twisted/21.2.0@python/stable")
            self.requires(f"zope_interface/5.4.0@python/stable")
        if self.options.devtools:
            self.requires(f"mypy/0.740@python/stable")
            self.requires(f"colorlog/6.6.0@python/stable")

    def package(self):
        self.copy("*", src = os.path.join(self.source_folder, "plugins"), dst = os.path.join("site-packages", "plugins"))
        self.copy("*", src = os.path.join(self.source_folder, "resources"), dst = os.path.join("site-packages", "resources"))
        self.copy("*", src = os.path.join(self.source_folder, "UM"), dst = os.path.join("site-packages", "UM"))
        self.copy("*.cmake", src = os.path.join(self.package_folder, "share"), dst = "cmake", keep_path=False)

    def package_info(self):
        if self.in_local_cache:
            self.user_info.URANIUM_CMAKE_PATH = str(os.path.join(self.package_folder, "cmake"))
            self.runenv_info.prepend_path("PYTHONPATH", os.path.join(self.package_folder, "site-packages"))
        else:
            self.user_info.URANIUM_CMAKE_PATH = str(os.path.join(str(pathlib.Path(__file__).parent.absolute()), "cmake"))
            self.runenv_info.prepend_path("PYTHONPATH",  str(pathlib.Path(__file__).parent.absolute()))

    def package_id(self):
        self.info.header_only()

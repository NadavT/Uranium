# Copyright (c) 2019 Ultimaker B.V.
# Uranium is released under the terms of the LGPLv3 or higher.
from typing import Union, Dict

from PyQt5.QtCore import QObject, pyqtSignal, pyqtProperty, QUrl

from UM.Decorators import deprecated
from UM.Logger import Logger
from UM.PluginObject import PluginObject
import warnings

class Stage(QObject, PluginObject):
    """Stages handle combined views in an Uranium application.

    The active stage decides which QML component to show where.
    Uranium has no notion of specific view locations as that's application specific.
    """

    iconSourceChanged = pyqtSignal()

    def __init__(self, parent = None) -> None:
        super().__init__(parent)
        self._components = {}  # type: Dict[str, QUrl]
        self._icon_source = QUrl()

    def onStageSelected(self) -> None:
        """Something to do when this Stage is selected"""
        pass

    def onStageDeselected(self) -> None:
        """Something to do when this Stage is deselected"""
        pass

    def addDisplayComponent(self, name: str, source: Union[str, QUrl]) -> None:
        """Add a QML component to the stage"""

        if type(source) == str:
            source = QUrl.fromLocalFile(source)
        self._components[name] = source

    def getDisplayComponent(self, name: str) -> QUrl:
        """Get a QUrl by name."""

        if name in self._components:
            return self._components[name]
        return QUrl()

    @pyqtProperty(QUrl, notify = iconSourceChanged)
    def iconSource(self) -> QUrl:
        # We can't use the deprecated decorator with pyqtProperty, so do it manually instead.
        warning = "{0} is deprecated (since {1}): {2}".format("iconSource", "4.13", "Stages no longer have icons")
        Logger.log("w_once", warning)
        warnings.warn(warning, DeprecationWarning, stacklevel=2)

        return self._icon_source

    @deprecated("Stages no longer have icons", "4.13")
    def setIconSource(self, source: Union[str, QUrl]) -> None:
        if type(source) == str:
            source = QUrl.fromLocalFile(source)

        if self._icon_source != source:
            self._icon_source = source
            self.iconSourceChanged.emit()

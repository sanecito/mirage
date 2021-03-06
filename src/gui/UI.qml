// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtGraphicalEffects 1.12
import "Base"
import "MainPane"

Item {
    id: mainUI
    focus: true

    Component.onCompleted: window.mainUI = mainUI


    property bool accountsPresent:
        ModelStore.get("accounts").count > 0 || py.startupAnyAccountsSaved

    readonly property alias shortcuts: shortcuts
    readonly property alias mainPane: mainPane
    readonly property alias pageLoader: pageLoader
    readonly property alias pressAnimation: pressAnimation


    function reloadSettings() {
        py.loadSettings(() => { mainUI.pressAnimation.start() })
    }


    SequentialAnimation {
        id: pressAnimation
        HNumberAnimation {
            target: mainUI; property: "scale";  from: 1.0; to: 0.9
        }
        HNumberAnimation {
            target: mainUI; property: "scale";  from: 0.9; to: 1.0
        }
    }

    GlobalShortcuts {
        id: shortcuts
        defaultDebugConsoleLoader: debugConsoleLoader
    }

    DebugConsoleLoader {
        id: debugConsoleLoader
        active: false
    }

    LinearGradient {
        id: mainUIGradient
        visible: ! image.visible
        anchors.fill: parent
        start: theme.ui.gradientStart
        end: theme.ui.gradientEnd

        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.ui.gradientStartColor }
            GradientStop { position: 1.0; color: theme.ui.gradientEndColor }
        }
    }

    HImage {
        id: image
        visible: Boolean(Qt.resolvedUrl(source))
        fillMode: Image.PreserveAspectCrop
        source: theme.ui.image
        sourceSize.width: Screen.width
        sourceSize.height: Screen.height
        anchors.fill: parent
        asynchronous: false
    }

    MainPane {
        id: mainPane
        maximumSize: parent.width - theme.minimumSupportedWidth * 1.5
    }

    PageLoader {
        id: pageLoader
        anchors.fill: parent
        anchors.leftMargin: mainPane.visibleSize
        visible: ! mainPane.hidden || anchors.leftMargin < width
    }
}

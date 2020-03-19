// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

HRowLayout {
    id: buttonContent
    spacing: button.spacing
    opacity: loading ? theme.loadingElementsOpacity :
             enabled ? 1 : theme.disabledElementsOpacity


    property AbstractButton button
    property QtObject buttonTheme

    readonly property alias icon: icon
    readonly property alias label: label


    Behavior on opacity { HNumberAnimation {} }


    Item {
        visible: button.icon.name || button.loading

        Layout.preferredWidth:
            button.loading ? busyIndicator.width : icon.width

        Layout.fillHeight: true
        Layout.alignment: Qt.AlignCenter

        HIcon {
            id: icon
            svgName: button.icon.name
            colorize: button.icon.color
            // cache: button.icon.cache  // TODO: need Qt 5.13+

            width: svgName ? implicitWidth : 0
            visible: width > 0

            opacity: button.loading ? 0 : 1

            Behavior on opacity { HNumberAnimation {} }
        }

        HBusyIndicator {
            id: busyIndicator
            width: height
            height: parent.height
            opacity: button.loading ? 1 : 0
            visible: opacity > 0

            Behavior on opacity { HNumberAnimation {} }
        }
    }

    HLabel {
        id: label
        text: button.text
        visible: Boolean(text)
        color: buttonTheme.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}

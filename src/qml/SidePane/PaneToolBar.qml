// Copyright 2019 miruka
// This file is part of harmonyqml, licensed under LGPLv3.

import QtQuick.Layouts 1.3
import "../Base"

HRowLayout {
    id: toolBar

    property alias roomFilter: filterField.text

    Layout.fillWidth: true
    Layout.preferredHeight: theme.bottomElementsHeight

    HButton {
        iconName: "settings"
        backgroundColor: theme.sidePane.settingsButton.background
        Layout.preferredHeight: parent.height
    }

    HTextField {
        id: filterField
        placeholderText: qsTr("Filter rooms")
        backgroundColor: theme.sidePane.filterRooms.background

        Layout.fillWidth: true
        Layout.preferredHeight: parent.height
    }
}
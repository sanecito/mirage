// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import CppUtils 0.1
import "../../../Base"

HTile {
    id: file
    width: Math.min(
        eventDelegate.width,
        eventContent.maxMessageWidth,
        Math.max(theme.chat.message.fileMinWidth, implicitWidth),
    )
    height: Math.max(theme.chat.message.avatarSize, implicitHeight)

    title.text: loader.singleMediaInfo.media_title || qsTr("Untitled file")
    title.elide: Text.ElideMiddle
    subtitle.text: CppUtils.formattedBytes(loader.singleMediaInfo.media_size)

    image: HIcon {
        svgName: "download"
    }

    onRightClicked: eventDelegate.openContextMenu()
    onLeftClicked:
        eventList.selectedCount ?
        eventDelegate.toggleChecked() : download(Qt.openUrlExternally)

    onHoveredChanged: {
        if (! hovered) {
            eventDelegate.hoveredMediaTypeUrl = []
            return
        }

        eventDelegate.hoveredMediaTypeUrl = [
            EventDelegate.Media.File,
            loader.downloadedPath.replace(/^file:\/\//, "") || loader.mediaUrl
        ]
    }


    property EventMediaLoader loader

    readonly property bool cryptDict:
        JSON.parse(loader.singleMediaInfo.media_crypt_dict)

    readonly property bool isEncrypted: ! utils.isEmptyObject(cryptDict)


    Binding on backgroundColor {
        value: theme.chat.message.checkedBackground
        when: eventDelegate.checked
    }

    Behavior on backgroundColor { HColorAnimation {} }
}

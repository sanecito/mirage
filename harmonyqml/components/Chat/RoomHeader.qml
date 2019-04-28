import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4
import "../Base" as Base

Base.HGlassRectangle {
    property string displayName: ""
    property string topic: ""

    id: root
    Layout.fillWidth: true
    Layout.minimumHeight: 36
    Layout.maximumHeight: Layout.minimumHeight
    color: Base.HStyle.chat.roomHeader.background

    RowLayout {
        id: row
        spacing: 12
        anchors.fill: parent

        Base.HAvatar {
            id: avatar
            Layout.alignment: Qt.AlignTop
            dimension: root.Layout.minimumHeight
            name: displayName
        }

        Base.HLabel {
            id: roomName
            text: displayName
            font.pixelSize: Base.HStyle.fontSize.big
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.maximumWidth:
                row.width - row.spacing * (row.children.length - 1) -
                avatar.width
        }

        Base.HLabel {
            id: roomTopic
            text: topic
            font.pixelSize: Base.HStyle.fontSize.small
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.maximumWidth:
                row.width -
                row.spacing * (row.children.length - 1) -
                avatar.width -
                roomName.width
        }

        Item { Layout.fillWidth: true }
    }
}
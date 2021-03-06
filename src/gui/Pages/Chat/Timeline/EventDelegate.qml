// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Clipboard 0.1
import "../../.."
import "../../../Base"

HColumnLayout {
    id: eventDelegate
    width: eventList.width

    ListView.onRemove: eventList.uncheck(model.id)


    enum Media { Page, File, Image, Video, Audio }

    property var hoveredMediaTypeUrl: []

    // Remember timeline goes from newest message at index 0 to oldest
    readonly property var previousModel: eventList.model.get(model.index + 1)
    readonly property var nextModel: eventList.model.get(model.index - 1)
    readonly property QtObject currentModel: model

    property bool checked: model.id in eventList.checked
    property bool compact: window.settings.compactMode
    property bool isOwn: chat.userId === model.sender_id
    property bool onRight: eventList.ownEventsOnRight && isOwn
    property bool combine: eventList.canCombine(previousModel, model)
    property bool talkBreak: eventList.canTalkBreak(previousModel, model)
    property bool dayBreak: eventList.canDayBreak(previousModel, model)

    readonly property bool smallAvatar: compact
    readonly property bool collapseAvatar: combine
    readonly property bool hideAvatar: onRight

    readonly property bool hideNameLine:
        model.event_type === "RoomMessageEmote" ||
        ! (
            model.event_type.startsWith("RoomMessage") ||
            model.event_type.startsWith("RoomEncrypted")
        ) ||
        onRight ||
        combine

    readonly property int cursorShape:
        eventContent.hoveredLink || hoveredMediaTypeUrl.length > 0 ?
        Qt.PointingHandCursor :

        eventContent.hoveredSelectable ? Qt.IBeamCursor :

        Qt.ArrowCursor

    readonly property int separationSpacing:
            dayBreak  ? theme.spacing * 4 :
            talkBreak ? theme.spacing * 6 :
            combine   ? theme.spacing / (compact ? 4 : 2) :
            theme.spacing * (compact ? 1 : 2)

    readonly property alias eventContent: eventContent

    // Needed because of eventList's MouseArea which steals the
    // HSelectableLabel's MouseArea hover events
    onCursorShapeChanged: eventList.cursorShape = cursorShape


    function json() {
        let event    = ModelStore.get(chat.userId, chat.roomId, "events")
                                 .get(model.index)
        event        = JSON.parse(JSON.stringify(event))
        event.source = JSON.parse(event.source)
        return JSON.stringify(event, null, 4)
    }

    function openContextMenu() {
        contextMenu.media = eventDelegate.hoveredMediaTypeUrl
        contextMenu.link  = eventContent.hoveredLink
        contextMenu.popup()
    }

    function toggleChecked() {
        eventList.toggleCheck(model.index)
    }


    Item {
        Layout.fillWidth: true
        Layout.preferredHeight:
            model.event_type === "RoomCreateEvent" ? 0 : separationSpacing
    }

    Daybreak {
        visible: dayBreak

        Layout.fillWidth: true
        Layout.minimumWidth: parent.width
    }

    Item {
        visible: dayBreak

        Layout.fillWidth: true
        Layout.preferredHeight: separationSpacing
    }

    EventContent {
        id: eventContent

        Layout.fillWidth: true

        Behavior on x { HNumberAnimation {} }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        acceptedModifiers: Qt.NoModifier
        onTapped: toggleChecked()
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        acceptedModifiers: Qt.ShiftModifier
        onTapped: eventList.checkFromLastToHere(model.index)
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        acceptedPointerTypes: PointerDevice.GenericPointer | PointerDevice.Pen
        onTapped: openContextMenu()
    }

    TapHandler {
        acceptedPointerTypes: PointerDevice.Finger | PointerDevice.Pen
        onLongPressed: openContextMenu()
    }

    HMenu {
        id: contextMenu

        property var media: []
        property string link: ""

        onClosed: { media = []; link = "" }

        HMenuItem {
            icon.name: "toggle-select-message"
            text: eventDelegate.checked ? qsTr("Deselect") : qsTr("Select")
            onTriggered: eventDelegate.toggleChecked()
        }

        HMenuItem {
            visible: eventList.selectedCount >= 2
            icon.name: "deselect-all-messages"
            text: qsTr("Deselect all")
            onTriggered: eventList.checked = {}
        }

        HMenuItem {
            visible: model.index !== 0
            icon.name: "select-until-here"
            text: qsTr("Select until here")
            onTriggered: eventList.checkFromLastToHere(model.index)
        }

        HMenuItem {
            id: copyMedia
            icon.name: "copy-link"
            text:
                contextMenu.media.length < 1 ? "" :

                contextMenu.media[0] === EventDelegate.Media.Page ?
                qsTr("Copy page address") :

                contextMenu.media[0] === EventDelegate.Media.File ?
                qsTr("Copy file address") :

                contextMenu.media[0] === EventDelegate.Media.Image ?
                qsTr("Copy image address") :

                contextMenu.media[0] === EventDelegate.Media.Video ?
                qsTr("Copy video address") :

                contextMenu.media[0] === EventDelegate.Media.Audio ?
                qsTr("Copy audio address") :

                qsTr("Copy media address")

            visible: Boolean(text)
            onTriggered: Clipboard.text = contextMenu.media[1]
        }

        HMenuItem {
            id: copyLink
            icon.name: "copy-link"
            text: qsTr("Copy link address")
            visible: Boolean(contextMenu.link)
            onTriggered: Clipboard.text = contextMenu.link
        }

        HMenuItem {
            icon.name: "copy-text"
            text:
                eventList.selectedCount ?
                qsTr("Copy selection") :

                copyMedia.visible ?
                qsTr("Copy filename") :

                qsTr("Copy text")

            onTriggered: {
                if (! eventList.selectedCount && eventList.currentItem === -1){
                    Clipboard.text = JSON.parse(model.source).body
                    return
                }

                eventList.copySelectedDelegates()
            }
        }

        HMenuItem {
            icon.name: "debug"
            text: qsTr("Debug this event")
            onTriggered: eventContent.debugConsoleLoader.toggle()
        }

        HMenuItemPopupSpawner {
            icon.name: "clear-messages"
            text: qsTr("Clear messages")

            popup: "Popups/ClearMessagesPopup.qml"
            popupParent: chat
            properties: ({userId: chat.userId, roomId: chat.roomId})
        }
    }
}

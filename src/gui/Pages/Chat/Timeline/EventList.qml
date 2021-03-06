// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import Clipboard 0.1
import "../../.."
import "../../../Base"

Rectangle {
    color: theme.chat.eventList.background


    property alias eventList: eventList


    HShortcut {
        sequences: window.settings.keys.unfocusOrDeselectAllMessages
        onActivated: {
            eventList.currentIndex !== -1 ?
            eventList.currentIndex = -1 :
            eventList.checked = {}
        }
    }

    HShortcut {
        sequences: window.settings.keys.focusPreviousMessage
        onActivated: eventList.incrementCurrentIndex()
    }

    HShortcut {
        sequences: window.settings.keys.focusNextMessage
        onActivated:
            eventList.currentIndex === 0 ?
            eventList.currentIndex = -1 :
            eventList.decrementCurrentIndex()
    }

    HShortcut {
        enabled: eventList.currentItem
        sequences: window.settings.keys.toggleSelectMessage
        onActivated: eventList.toggleCheck(eventList.currentIndex)
    }

    HShortcut {
        enabled: eventList.currentItem
        sequences: window.settings.keys.selectMessagesUntilHere
        onActivated:
            eventList.checkFromLastToHere(eventList.currentIndex)
    }

    HShortcut {
        enabled: eventList.currentItem
        sequences: window.settings.keys.debugFocusedMessage
        onActivated:
            eventList.currentItem.eventContent.debugConsoleLoader.toggle()
    }

    HListView {
        id: eventList
        clip: true
        keyNavigationWraps: false

        anchors.fill: parent
        anchors.leftMargin: theme.spacing
        anchors.rightMargin: theme.spacing

        topMargin: theme.spacing
        bottomMargin: theme.spacing
        verticalLayoutDirection: ListView.BottomToTop

        // Keep x scroll pages cached, to limit images having to be
        // reloaded from network.
        cacheBuffer: Screen.desktopAvailableHeight * 2

        model: ModelStore.get(chat.userId, chat.roomId, "events")
        delegate: EventDelegate {}

        highlight: Rectangle {
            color: theme.chat.message.focusedHighlight
            opacity: theme.chat.message.focusedHighlightOpacity
        }

        // Since the list is BottomToTop, this is actually a header
        footer: Item {
            width: eventList.width
            height: (button.height + theme.spacing * 2) * opacity
            opacity: eventList.loading ? 1 : 0
            visible: opacity > 0

            Behavior on opacity { HNumberAnimation {} }

            HButton {
                id: button
                width: Math.min(parent.width, implicitWidth)
                anchors.centerIn: parent

                loading: true
                text: qsTr("Loading previous messages...")
                enableRadius: true
                iconItem.small: true
            }
        }

        onYPosChanged:
            if (canLoad && yPos < 0.1) Qt.callLater(loadPastEvents)

        // When an invited room becomes joined, we should now be able to
        // fetch past events.
        onInviterChanged: canLoad = true

        Component.onCompleted: shortcuts.flickTarget = eventList


        property string inviter: chat.roomInfo.inviter || ""
        property real yPos: visibleArea.yPosition
        property bool canLoad: true
        property bool loading: false

        property bool ownEventsOnRight:
            width < theme.chat.eventList.ownEventsOnRightUnderWidth

        property string delegateWithSelectedText: ""
        property string selectedText: ""


        function copySelectedDelegates() {
            if (eventList.selectedText) {
                Clipboard.text = eventList.selectedText
                return
            }

            if (! eventList.selectedCount && eventList.currentIndex !== -1) {
                const model  = eventList.model.get(eventList.currentIndex)
                const source = JSON.parse(model.source)

                Clipboard.text =
                    "body" in source ?
                    source.body :
                    utils.stripHtmlTags(utils.processedEventText(model))

                return
            }

            const contents = []

            for (const model of eventList.getSortedChecked()) {
                const source = JSON.parse(model.source)

                contents.push(
                    "body" in source ?
                    source.body :
                    utils.stripHtmlTags(utils.processedEventText(model))
                )
            }

            Clipboard.text = contents.join("\n\n")
        }

        function canCombine(item, itemAfter) {
            if (! item || ! itemAfter) return false

            return Boolean(
                ! canTalkBreak(item, itemAfter) &&
                ! canDayBreak(item, itemAfter) &&
                item.sender_id === itemAfter.sender_id &&
                utils.minutesBetween(item.date, itemAfter.date) <= 5
            )
        }

        function canTalkBreak(item, itemAfter) {
            if (! item || ! itemAfter) return false

            return Boolean(
                ! canDayBreak(item, itemAfter) &&
                utils.minutesBetween(item.date, itemAfter.date) >= 20
            )
        }

        function canDayBreak(item, itemAfter) {
            if (itemAfter && itemAfter.event_type === "RoomCreateEvent")
                return true

            if (! item || ! itemAfter || ! item.date || ! itemAfter.date)
                return false

            return item.date.getDate() !== itemAfter.date.getDate()
        }

        function loadPastEvents() {
            // try/catch blocks to hide pyotherside error when the
            // component is destroyed but func is still running

            try {
                eventList.canLoad = false
                eventList.loading = true

                py.callClientCoro(
                    chat.userId,
                    "load_past_events",
                    [chat.roomId],
                    moreToLoad => {
                        try {
                            eventList.canLoad = moreToLoad

                            // Call yPosChanged() to run this func again
                            // if the loaded messages aren't enough to fill
                            // the screen.
                            if (moreToLoad) yPosChanged()

                            eventList.loading = false
                        } catch (err) {
                            return
                        }
                    }
                )
            } catch (err) {
                return
            }
        }
    }

    HNoticePage {
        text: qsTr("No messages to show yet")

        visible: eventList.model.count < 1
        anchors.fill: parent
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import QtQuick.Layouts 1.12
import "../../Base"
import "Banners"
import "Timeline"
import "FileTransfer"

HColumnPage {
    id: chatPage
    leftPadding: 0
    rightPadding: 0

    // The target will be our EventList, not the page itself
    becomeKeyboardFlickableTarget: false

    onLoadEventListChanged: if (loadEventList) loadedOnce = true


    property bool loadedOnce: false

    readonly property alias composer: composer
    readonly property bool loadEventList:
        mainUI.mainPane.collapse ?
        ! mainUI.mainPane.visible : ! pageLoader.appearAnimation.running


    RoomHeader {
        Layout.fillWidth: true
    }

    HLoader {
        id: eventListLoader
        opacity: loadEventList ? 1 : 0
        sourceComponent:
            loadedOnce || loadEventList ? evListComponent : placeholder

        Layout.fillWidth: true
        Layout.fillHeight: true

        Behavior on opacity { HNumberAnimation {} }

        Component {
            id: placeholder
            Item {}
        }

        Component {
            id: evListComponent
            EventList {}
        }
    }

    TypingMembersBar {
        Layout.fillWidth: true
    }

    TransferList {
        Layout.fillWidth: true
        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight * transferCount
        Layout.maximumHeight: chatPage.height / 6

        Behavior on Layout.preferredHeight { HNumberAnimation {} }
    }

    InviteBanner {
        id: inviteBanner
        visible: ! chat.roomInfo.left && inviterId
        inviterId: chat.roomInfo.inviter_id

        Layout.fillWidth: true
    }

    LeftBanner {
        id: leftBanner
        visible: chat.roomInfo.left
        Layout.fillWidth: true
    }

    Composer {
        id: composer
        eventList: loadEventList ? eventListLoader.item.eventList : null
        visible:
            ! chat.roomInfo.left && ! chat.roomInfo.inviter_id
    }

}

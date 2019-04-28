import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.4
import "../Base" as Base
import "utils.js" as ChatJS

Column {
    id: messageDelegate

    function minsBetween(date1, date2) {
        return Math.round((((date2 - date1) % 86400000) % 3600000) / 60000)
    }

    function getIsMessage(type_) { return type_.startsWith("RoomMessage") }

    function getPreviousItem() {
        return index < messageListView.model.count - 1 ?
                messageListView.model.get(index + 1) : null
    }

    property var previousItem: getPreviousItem()
    signal reloadPreviousItem()
    onReloadPreviousItem: previousItem = getPreviousItem()

    readonly property bool isMessage: getIsMessage(type)

    readonly property bool isUndecryptableEvent:
        type === "OlmEvent" || type === "MegolmEvent"

    readonly property var displayName:
        Backend.getUserDisplayName(dict.sender)

    readonly property bool isOwn:
        chatPage.userId === dict.sender

    readonly property bool isFirstEvent: type == "RoomCreateEvent"

    readonly property bool combine:
        previousItem &&
        ! talkBreak &&
        ! dayBreak &&
        getIsMessage(previousItem.type) === isMessage &&
        previousItem.dict.sender === dict.sender &&
        minsBetween(previousItem.dateTime, dateTime) <= 5

    readonly property bool dayBreak:
        isFirstEvent ||
        previousItem &&
        dateTime.getDate() != previousItem.dateTime.getDate()

    readonly property bool talkBreak:
        previousItem &&
        ! dayBreak &&
        minsBetween(previousItem.dateTime, dateTime) >= 20


    property int standardSpacing: 16
    property int horizontalPadding: 7
    property int verticalPadding: 5

    ListView.onAdd: {
        var nextDelegate = messageListView.contentItem.children[index]
        if (nextDelegate) { nextDelegate.reloadPreviousItem() }
    }

    width: parent.width

    topPadding:
        isFirstEvent ? 0 :
        dayBreak ? standardSpacing * 2 :
        talkBreak ? standardSpacing * 3 :
        combine ? standardSpacing / 4 :
        standardSpacing

    Daybreak { visible: dayBreak }

    Item {
        visible: dayBreak
        width: parent.width
        height: topPadding
    }

    MessageContent { visible: isMessage }

    EventContent { visible: ! isMessage }
}
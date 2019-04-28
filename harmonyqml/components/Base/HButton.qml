import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.4

Button {
    property string iconName: ""
    property var iconDimension: null
    property bool circle: false

    property int fontSize: HStyle.fontSize.normal
    property color backgroundColor: "lightgray"
    property alias overlayOpacity: buttonBackgroundOverlay.opacity

    property bool loading: false

    property int contentWidth: 0

    signal canceled
    signal clicked
    signal doubleClicked
    signal entered
    signal exited
    signal pressAndHold
    signal pressed
    signal released

    function loadingUntilFutureDone(future) {
        loading = true
        future.onGotResult.connect(function() { loading = false })
    }

    id: button
    display: Button.TextBesideIcon

    background: Rectangle {
        id: buttonBackground
        color: Qt.lighter(backgroundColor, checked ? 1.3 : 1.0)
        radius: circle ? height : 0

        Rectangle {
            id: buttonBackgroundOverlay
            anchors.fill: parent
            radius: parent.radius
            color: "black"
            opacity: 0
        }
    }

    Component {
        id: buttonContent

        HRowLayout {
            id: contentLayout
            spacing: button.text && iconName ? 5 : 0
            Component.onCompleted: contentWidth = implicitWidth

            HIcon {
                svgName: loading ? "hourglass" : iconName
                dimension: iconDimension || contentLayout.height
            }

            HLabel {
                text: button.text
                font.pixelSize: fontSize
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }

    Component {
        id: loadingOverlay
        HRowLayout {
            HIcon {
                svgName: "hourglass"
                Layout.preferredWidth: contentWidth || -1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }
    }

    contentItem: Loader {
        sourceComponent:
            loading && ! iconName ? loadingOverlay : buttonContent
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onCanceled: button.canceled()
        onClicked: button.clicked()
        onDoubleClicked: button.doubleClicked()
        onEntered: {
            overlayOpacity = checked ? 0 : 0.3
            button.entered()
        }
        onExited: {
            overlayOpacity = 0
            button.exited()
        }
        onPressAndHold: button.pressAndHold()
        onPressed: {
            overlayOpacity += 0.3
            button.pressed()
        }
        onReleased: {
            if (checkable) { checked = ! checked }
            overlayOpacity = checked ? 0 : 0.3
            button.released()
        }
    }
}
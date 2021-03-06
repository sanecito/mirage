// SPDX-License-Identifier: LGPL-3.0-or-later

import QtQuick 2.12
import "../../Base"

HUserAvatar {
    userId: addChatPage.userId
    displayName: addChatPage.account ? addChatPage.account.display_name : ""
    mxc: addChatPage.account ? addChatPage.account.avatar_url : ""
}

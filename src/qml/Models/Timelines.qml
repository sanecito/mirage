// Copyright 2019 miruka
// This file is part of harmonyqml, licensed under LGPLv3.

import QtQuick 2.12
import SortFilterProxyModel 0.2
import "../Base"

HListModel {
    function lastEventOf(roomId) {
        // Return an event item or undefined if none found

        for (var i = 0; i < count; i++) {
            var item = get(i) // TODO: standardize
            if (item.roomId == roomId) { return item }
        }
    }

    sorters: ExpressionSorter {
        expression: modelLeft.isLocalEcho && ! modelRight.isLocalEcho ?
                    true :
                    ! modelLeft.isLocalEcho && modelRight.isLocalEcho ?
                    false :
                    modelLeft.date > modelRight.date // descending order
    }
}

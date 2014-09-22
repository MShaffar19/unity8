/*
 * Copyright (C) 2014 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Dash 0.1

Item {
    id: root

    // Properties set by parent
    property var scope: null

    // Properties used by parent
    readonly property bool processing: false /*TODO*/

    // Signals
    signal backClicked()
    signal storeClicked()
    signal requestFavorite(string scopeId, bool favorite)

    state: "browse"

    ScopeStyle {
        id: scopeStyle
        style: { "foreground-color" : "gray",
                 "background-color" : "transparent",
                 "page-header": {
                    "background": "color:///transparent"
                 }
        }
    }

    DashBackground {
        anchors.fill: parent
    }

    Binding {
        target: root.scope
        property: "searchQuery"
        value: header.searchQuery
    }

    Binding {
        target: header
        property: "searchQuery"
        value: root.scope ? root.searchQuery : ""
    }

    PageHeader {
        id: header
        title: i18n.tr("My Feeds")
        width: parent.width
        showBackButton: true
        backIsClose: root.state == "edit"
        storeEntryEnabled: root.state == "browse"
        searchEntryEnabled: root.state == "browse"
        onBackClicked: {
            if (backIsClose) {
                root.state = "browse"
            } else {
                root.backClicked()
            }
        }
        onStoreClicked: root.storeClicked();
    }

    Flickable {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        contentWidth: root.width
        contentHeight: column.height
        Column {
            id: column
            Repeater {
                model: scope ? scope.categories : null

                delegate: Loader {
                    source: "ScopesListCategory.qml";
                    asynchronous: true
                    width: root.width
                    onLoaded: {
                        item.isFavoriteFeeds = index == 0;
                        item.scopeStyle = scopeStyle;
                        item.model = Qt.binding(function() { return results });
                        item.editMode = Qt.binding(function() { return root.state == "edit" });
                    }
                    Connections {
                        target: item
                        onRequestFavorite: root.requestFavorite(scopeId, favorite)
                        onRequestEditMode: root.state = "edit";
                    }
                }
            }
        }
    }
}

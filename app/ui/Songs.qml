/*
 * Copyright (C) 2013, 2014, 2015, 2016
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Daniel Holm <d.holmen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
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

import QtQuick 2.4
import Lomiri.Components 1.3
import MediaScanner 0.1
import Lomiri.Thumbnailer 0.1
import QtQuick.LocalStorage 2.0
import "../logic/playlists.js" as Playlists
import "../components"
import "../components/Delegates"
import "../components/Flickables"
import "../components/HeadState"
import "../components/ListItemActions"


MusicPage {
    id: songsPage
    objectName: "songsPage"
    title: i18n.tr("Tracks")
    searchable: true
    searchResultsCount: songsModelFilter.count
    state: "default"
    states: [
        SearchableHeadState {
            thisPage: songsPage
            searchEnabled: songsModelFilter.count > 0
        },
        MultiSelectHeadState {
            listview: tracklist
            thisPage: songsPage
        },
        SearchHeadState {
            id: searchHeader
            thisPage: songsPage
        }
    ]

    // Hack for autopilot otherwise Albums appears as MusicPage
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    MultiSelectListView {
        id: tracklist
        anchors {
            bottomMargin: units.gu(2)
            fill: parent
            topMargin: units.gu(2)
        }
        objectName: "trackstab-listview"
        model: SortFilterModel {
            id: songsModelFilter
            property alias rowCount: songsModel.rowCount
            model: SongsModel {
                id: songsModel
                store: musicStore
            }
            sort.property: "title"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
            filter.property: "title"
            filter.pattern: new RegExp(searchHeader.query, "i")
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        onStateChanged: {
            if (state === "multiselectable") {
                songsPage.state = "selection"
            } else {
                searchHeader.query = ""  // force query back to default
                songsPage.state = "default"
            }
        }

        delegate: MusicListItem {
            id: track
            objectName: "tracksPageListItem" + index
            imageSource: {"art": model.art}
            multiselectable: true
            subtitle {
                text: model.author + " - " + model.album
            }
            title {
                objectName: "tracktitle"
                text: model.title
            }
            trailingActions: AddToQueueAndPlaylist {
            }

            onItemClicked: {
                if (songsPage.state === "search") {  // only play single track when searching
                    player.mediaPlayer.playlist.clearWrapper();
                    player.mediaPlayer.playlist.addItem(Qt.resolvedUrl(songsModelFilter.get(index).filename));
                    trackQueueClick(0)
                } else {
                    trackClicked(songsModelFilter, index)  // play track
                }
            }
        }
    }
}


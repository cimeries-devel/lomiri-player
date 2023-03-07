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
import "../components"
import "../components/Delegates"
import "../components/Flickables"
import "../components/HeadState"


MusicPage {
    id: genresPage
    objectName: "genresPage"
    title: i18n.tr("Genres")
    searchable: true
    searchResultsCount: genresModelFilter.count
    state: "default"
    states: [
        SearchableHeadState {
            thisPage: genresPage
            searchEnabled: genresModelFilter.count > 0
        },
        SearchHeadState {
            id: searchHeader
            thisPage: genresPage
        }
    ]

    // Hack for autopilot otherwise Albums appears as MusicPage
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    MusicGridView {
        id: genreGridView
        itemWidth: units.gu(12)
        heightOffset: units.gu(7)
        model: SortFilterModel {
            id: genresModelFilter
            model: GenresModel {
                id: genresModel
                store: musicStore
            }
            filter.property: "genre"
            filter.pattern: searchHeader.query === "" ? /\S+/ : new RegExp(searchHeader.query, "i")
            filterCaseSensitivity: Qt.CaseInsensitive
            sort.property: "genre"
            sort.order: Qt.AscendingOrder
            sortCaseSensitivity: Qt.CaseInsensitive
        }

        delegate: Card {
            id: genreCard
            coverSources: []
            objectName: "genresPageGridItem" + index
            primaryText: model.genre
            secondaryTextVisible: false

            property string album: ""

            Repeater {
                id: albumGenreModelRepeater
                model: AlbumsModel {
                    genre: model.genre
                    store: musicStore
                }

                delegate: Item {
                    property string art: model.art
                }
                property var covers: []
                signal finished()

                onFinished: {
                    genreCard.coverSources = covers
                }
                onItemAdded: {
                    covers.push({art: item.art});

                    if (index === count - 1) {
                        finished();
                    }
                }
            }

            onClicked: {
                mainPageStack.push(Qt.resolvedUrl("SongsView.qml"),
                                   {
                                       "covers": genreCard.coverSources,
                                       "album": undefined,
                                       "isAlbum": true,
                                       "genre": model.genre,
                                       "title": i18n.tr("Genre"),
                                       "line2": model.genre,
                                       "line1": i18n.tr("Genre")
                                   })
            }
        }
    }
}


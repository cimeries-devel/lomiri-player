/*
 * Copyright (C) 2013, 2014, 2015
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

Page {
    id: libraryEmptyPage
    objectName: "emptyLibrary"
    anchors {
        fill: parent
    }

    // Do not show the Page Header
    head {
        visible: false
        locked: true
    }

    // Hack for autopilot otherwise LibraryEmptyState appears as Page
    // due to bug 1341671 it is required that there is a property so that
    // qml doesn't optimise using the parent type
    property bool bug1341671workaround: true

    // Overlay to show when no tracks detected on the device
    Rectangle {
        id: libraryEmpty
        anchors {
            fill: parent
            topMargin: -units.gu(8)  // FIXME: 6.125 is the header.height
        }
        color: mainView.backgroundColor

        Column {
            id: noMusicTextColumn
            anchors {
                centerIn: parent
            }
            spacing: units.gu(4)
            width: units.gu(36)

            Row {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                Item {
                    height: parent.height
                    width: imageEmptyDownload.width + units.gu(2)

                    Image {
                        id: imageEmptyDownload
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        antialiasing: true
                        fillMode: Image.PreserveAspectFit
                        height: units.gu(10)
                        smooth: true
                        source: "../graphics/music_download_icon.png"
                        asynchronous: true
                    }
                }

                Item {
                    height: parent.height
                    width: units.gu(7)

                    Image {
                        id: imageSep
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }
                        antialiasing: true
                        fillMode: Image.PreserveAspectFit
                        height: units.gu(6)
                        smooth: true
                        source: "../graphics/div.png"
                        asynchronous: true
                    }
                }

                Image {
                    id: imageEmptySD
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                    antialiasing: true
                    fillMode: Image.PreserveAspectFit
                    height: units.gu(7)
                    smooth: true
                    source: "../graphics/sd_phone_icon.png"
                    asynchronous: true
                }
            }

            Label {
                color: styleMusic.libraryEmpty.labelColor
                objectName: "titleText"
                elide: Text.ElideRight
                fontSize: "x-large"
                horizontalAlignment: Text.AlignLeft
                maximumLineCount: 2
                text: i18n.tr("No music found")
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Label {
                color: styleMusic.libraryEmpty.labelColor
                objectName:"descriptiveText"
                elide: Text.ElideRight
                fontSize: "large"
                horizontalAlignment: Text.AlignLeft
                maximumLineCount: 6
                text: i18n.tr("Connect your device to any computer and simply drag files to the Music folder or insert removable media with music.")
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
}

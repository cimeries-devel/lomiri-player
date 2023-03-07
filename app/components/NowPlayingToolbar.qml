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

import QtMultimedia 5.6
import QtQuick 2.4
import Lomiri.Components 1.3


/* Full toolbar */
Rectangle {
    id: musicToolbarFullContainer
    anchors {
        fill: parent
    }
    color: styleMusic.common.black

    property alias bottomProgressHint: playerControlsProgressBar.visible
    property int itemSize: units.gu(6)
    property int spacing: units.gu(1)

    /* Repeat button */
    MouseArea {
        id: nowPlayingRepeatButton
        anchors.right: nowPlayingPreviousButton.left
        anchors.rightMargin: spacing
        anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
        height: itemSize
        width: height
        onClicked: {
            // tap-order: repeat disabled -> repeat single -> repeat album -> repeat disabled
            if (player.repeat == "none") {
                player.repeat = "repeatSingle"
                repeatIcon.name = "media-playlist-repeat-one"
                repeatIcon.opacity = 1
            } else if (player.repeat == "repeatSingle") {
                player.repeat = "repeatAlbum"
                repeatIcon.name = "media-playlist-repeat"
                repeatIcon.opacity = 1
            } else if (player.repeat == "repeatAlbum") {
                player.repeat = "none"
                repeatIcon.name = "media-playlist-repeat"
                repeatIcon.opacity = .4
            } else {
                // in case of old bool values, use "none" as initial new setting
                player.repeat = "none"
                repeatIcon.name = "media-playlist-repeat"
                repeatIcon.opacity = .4
            }
        }

        Icon {
            id: repeatIcon
            height: itemSize / 2
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.pressed ? theme.palette.normal.focus : theme.palette.normal.foregroundText
            name: player.repeat == "repeatSingle" ? "media-playlist-repeat-one" : "media-playlist-repeat"
            objectName: "repeatShape"
            opacity: player.repeat == "none" ? .4 : 1
            asynchronous: true
        }
    }

    /* Previous button */
    MouseArea {
        id: nowPlayingPreviousButton
        enabled: player.mediaPlayer.playlist.canGoPrevious
        anchors.right: nowPlayingPlayButton.left
        anchors.rightMargin: spacing
        anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
        height: itemSize
        width: height
        onClicked: player.mediaPlayer.playlist.previousWrapper()

        Icon {
            id: nowPlayingPreviousIndicator
            height: itemSize / 2
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.pressed ? theme.palette.normal.focus : theme.palette.normal.foregroundText
            name: "media-skip-backward"
            objectName: "previousShape"
            opacity: parent.enabled ? 1 : .4
            asynchronous: true
        }
    }

    /* Play/Pause button */
    MouseArea {
        id: nowPlayingPlayButton
        anchors.centerIn: parent
        height: itemSize + (2 * spacing)
        width: height
        onClicked: player.mediaPlayer.toggle()

        Icon {
            id: nowPlayingPlayIndicator
            height: itemSize
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.pressed ? theme.palette.normal.focus : theme.palette.normal.foregroundText
            name: player.mediaPlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
            objectName: "playShape"
            asynchronous: true
        }
    }

    /* Next button */
    MouseArea {
        id: nowPlayingNextButton
        anchors.left: nowPlayingPlayButton.right
        anchors.leftMargin: spacing
        anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
        enabled: player.mediaPlayer.playlist.canGoNext
        height: itemSize
        width: height
        onClicked: player.mediaPlayer.playlist.nextWrapper()

        Icon {
            id: nowPlayingNextIndicator
            height: itemSize / 2
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.pressed ? theme.palette.normal.focus : theme.palette.normal.foregroundText
            name: "media-skip-forward"
            objectName: "forwardShape"
            opacity: parent.enabled ? 1 : .4
            asynchronous: true
        }
    }

    /* Shuffle button */
    MouseArea {
        id: nowPlayingShuffleButton
        anchors.left: nowPlayingNextButton.right
        anchors.leftMargin: spacing
        anchors.verticalCenter: nowPlayingPlayButton.verticalCenter
        height: itemSize
        width: height
        onClicked: player.shuffle = !player.shuffle

        Icon {
            id: shuffleIcon
            height: itemSize / 2
            width: height
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: parent.pressed ? theme.palette.normal.focus : theme.palette.normal.foregroundText
            name: "media-playlist-shuffle"
            objectName: "shuffleShape"
            opacity: player.shuffle ? 1 : .4
            asynchronous: true
        }
    }

    /* Object which provides the progress bar when in the queue */
    Rectangle {
        id: playerControlsProgressBar
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        color: styleMusic.common.black
        height: units.gu(0.25)
        visible: isListView

        Rectangle {
            id: playerControlsProgressBarHint
            anchors {
                left: parent.left
                bottom: parent.bottom
            }
            color: theme.palette.normal.focus
            height: parent.height
            width: player.mediaPlayer.progress * playerControlsProgressBar.width
        }
    }
}

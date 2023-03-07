/*
 * Copyright (C) 2014, 2015, 2016
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
import Lomiri.Components.Popups 1.3
import Lomiri.Content 1.4
import "../../logic/stored-request.js" as StoredRequest


Item {
    id: contentHubHelper
    property var activeImportTransfer
    property var activeExportTransfer

    property int importId: 0
    property list<ContentItem> importItems
    property list<ContentItem> exportItems
    property bool processing: contentHubWaitForFile.processId !== -1

    ContentTransferHint {
        anchors {
            fill: parent
        }
        activeTransfer: parent.activeImportTransfer
    }

    Component {
        id: resultComponent
        ContentItem {}
    }

    Connections {
        id: contentHub
        target: ContentHub

        property var searchPaths: []

        onExportRequested: {
            activeExportTransfer = transfer;

            if (mainPageStack.currentPage.objectName === "contentHubExportPage") {
                mainPageStack.pop()
            }

            mainPageStack.push(Qt.resolvedUrl("../../ui/ContentHubExport.qml"), {contentItemComponent: resultComponent, transfer: activeExportTransfer});
        }

        onImportRequested: {
            activeImportTransfer = transfer;

            if (activeImportTransfer.state === ContentTransfer.Charged) {
                importItems = activeImportTransfer.items;

                if (firstRun) {
                    console.debug("Delaying content-hub import")
                    StoredRequest.store(function() { return contentHub.importRequested(importItems); })
                } else {
                    contentHub.importRequested(importItems)
                }
            }
        }

        function importFile(contentItem, path) {
            var contentUrl = contentItem.url.toString()

            if (path.indexOf("~/Music/Imported/") !== 0) {
                console.debug("Invalid dest (not in ~/Music/Imported/)")

                // TRANSLATORS: This string represents that the target destination filepath does not start with ~/Music/Imported/
                return i18n.tr("Filepath must start with %1").arg(" ~/Music/Imported/")
            }
            else {
                // extract /home/$USER (or $HOME) from contentitem url
                var homepath = contentUrl.substring(7).split("/");

                if (homepath[1] === "home") {
                    homepath.splice(3, homepath.length - 3)
                    homepath = homepath.join("/")
                }
                else {
                    console.debug("/home/$USER not detecting in contentItem assuming /home/phablet/")
                    homepath = "/home/phablet"
                }

                console.debug("Copy:", contentUrl, "to", path)

                // Extract filename from path and replace ~ with $HOME
                var dir = path.split("/")
                var filename = dir.pop()
                dir = dir.join("/").replace("~/", homepath + "/")
                // Avoid decoding issue afterward when using decodeFileURI
                filename = filename.replace(/[&,+()$~%'":*?<>{}]/g, '')

                if (filename === "") {
                    console.debug("Invalid dest (filename blank)")

                    // TRANSLATORS: This string represents that a blank filepath destination has been used
                    return i18n.tr("Filepath must be a file")
                }
                else if (!contentItem.copy(dir, filename)) {
                    console.debug("Copy failed! DIR:", dir, "FILE:", filename)

                    // TRANSLATORS: This string represents that there was failure moving the file to the target destination
                    return i18n.tr("Failed to copy file")
                }
                else {
                    contentHub.searchPaths.push(dir + "/" + filename)
                    return true
                }
            }
        }

        function importRequested(importItems) {
            var processId = importId++;

            console.debug("Triggering content-hub import ID", processId);

            searchPaths = [];

            var err = [];
            var path;
            var res;
            var success = true;
            var url;

            for (var i=0; i < importItems.length; i++) {
                url = importItems[i].url.toString()
                console.debug("Triggered content-hub import for item", url)

                // fixed path allows for apparmor protection
                path = "~/Music/Imported/" + Qt.formatDateTime(new Date(), "yyyy/MM/dd/hhmmss") + "-" + url.split("/").pop()
                res = contentHub.importFile(importItems[i], path)

                if (res !== true) {
                    success = false;
                    err.push(url.split("/").pop() + " " + res)
                }
            }


            if (success === true) {
                if (contentHubWaitForFile.processId === -1) {
                    contentHubWaitForFile.dialog = PopupUtils.open(Qt.resolvedUrl("../Dialog/ContentHubWaitDialog.qml"), contentHubHelper)
                    contentHubWaitForFile.searchPaths = contentHub.searchPaths;
                    contentHubWaitForFile.processId = processId;
                    contentHubWaitForFile.start();
                } else {
                    contentHubWaitForFile.searchPaths.push.apply(contentHubWaitForFile.searchPaths, contentHub.searchPaths);
                    contentHubWaitForFile.count = 0;
                    contentHubWaitForFile.restart();
                }
            }
            else {
                var errordialog = PopupUtils.open(Qt.resolvedUrl("../Dialog/ContentHubErrorDialog.qml"), contentHubHelper)
                errordialog.errorText = err.join("\n")
            }

            // tell content-hub we are finished with the files
            activeImportTransfer.finalize();
        }
    }

    Timer {
        id: contentHubWaitForFile
        interval: 1000
        triggeredOnStart: false
        repeat: true

        property var dialog: null
        property var searchPaths
        property int count: 0
        property int processId: -1

        function stopTimer() {
            processId = -1;
            count = 0;
            stop();

            if (dialog) PopupUtils.close(dialog)
        }

        onTriggered: {
            var found = true
            var i;
            var model;

            for (i=0; i < searchPaths.length; i++) {
                model = musicStore.lookup(decodeFileURI(searchPaths[i]))

                console.debug("MusicStore model from lookup", JSON.stringify(model))

                if (!model) {
                    found = false
                }
            }

            if (!found) {
                count++;

                if (count >= 10) {  // wait for 10s
                    stopTimer();

                    console.debug("File(s) were not found", JSON.stringify(searchPaths))
                    PopupUtils.open(Qt.resolvedUrl("../Dialog/ContentHubNotFoundDialog.qml"), mainView)
                }
            }
            else {
                stopTimer();

                player.mediaPlayer.playlist.clearWrapper();

                var items = [];

                for (i=0; i < searchPaths.length; i++) {
                    // Don't need to check if in ms2 as that is done above
                    items.push(Qt.resolvedUrl(decodeURIComponent(searchPaths[i])))
                }

                player.mediaPlayer.playlist.addItems(items);

                trackQueueClick(0);

                // Show the Now playing page and make sure the track is visible
                tabs.pushNowPlaying();
            }
        }
    }
}

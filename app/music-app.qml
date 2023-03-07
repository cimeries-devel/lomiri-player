/*
 * Copyright (C) 2013, 2014, 2015, 2016
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Daniel Holm <d.holmen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 * Copyright: 2020 UBports
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
import MediaScanner 0.1
import Qt.labs.settings 1.0
import QtSystemInfo 5.0
import QtMultimedia 5.6
import QtQuick.LocalStorage 2.0
import QtGraphicalEffects 1.0
import "logic/stored-request.js" as StoredRequest
import "logic/meta-database.js" as Library
import "logic/playlists.js" as Playlists
import "components"
import "components/Helpers"
import "ui"

MainView {
    objectName: "musicMainView"
    applicationName: "music.ubports"
    id: mainView

    backgroundColor: styleMusic.mainView.backgroundColor
    theme.name: "Lomiri.Components.Themes.SuruDark"

    // Startup settings
    Settings {
        id: startupSettings
        category: "StartupSettings"

        property bool firstRun: true
        property int queueIndex: 0
        property int tabIndex: -1
        property bool keepDisplayOn: false

        onFirstRunChanged: {
            if (!firstRun) {
                StoredRequest.run()
            }
        }
    }

    ScreenSaver {
        id: screen_saver
        screenSaverEnabled: ((player.mediaPlayer.playbackState != MediaPlayer.PlayingState) || (!startupSettings.keepDisplayOn)) || Qt.application.state != Qt.ApplicationActive
    }

    Connections {  // save the current queueIndex for when the app restarts
        target: player.mediaPlayer.playlist
        onCurrentIndexChanged: startupSettings.queueIndex = player.mediaPlayer.playlist.currentIndex
    }

    // Global keyboard shortcuts
    focus: true
    Keys.onPressed: {
        if(event.key === Qt.Key_Escape) {
            if (mainPageStack.currentMusicPage.currentDialog !== null) {
                PopupUtils.close(mainPageStack.currentMusicPage.currentDialog)
            } else if (mainPageStack.currentMusicPage.searchable && mainPageStack.currentMusicPage.state === "search") {
                mainPageStack.currentMusicPage.state = "default"
            } else {
                mainPageStack.goBack();  // Esc      Go back
            }
        }
        else if(event.modifiers === Qt.AltModifier) {
            var position;

            switch (event.key) {
            case Qt.Key_Right:  //  Alt+Right   Seek forward +10secs
                position = player.mediaPlayer.position + 10000 < player.mediaPlayer.duration
                        ? player.mediaPlayer.position + 10000 : player.mediaPlayer.duration;
                player.mediaPlayer.seek(position);
                break;
            case Qt.Key_Left:  //   Alt+Left    Seek backwards -10secs
                position = player.mediaPlayer.position - 10000 > 0
                        ? player.mediaPlayer.position - 10000 : 0;
                player.mediaPlayer.seek(position);
                break;
            }
        }
        else if(event.modifiers === Qt.ControlModifier) {
            switch (event.key) {
            case Qt.Key_Left:   //  Ctrl+Left   Previous Song
                player.mediaPlayer.playlist.previousWrapper();
                break;
            case Qt.Key_Right:  //  Ctrl+Right  Next Song
                player.mediaPlayer.playlist.nextWrapper();
                break;
            case Qt.Key_Up:  //     Ctrl+Up     Volume up
                player.mediaPlayer.volume = player.mediaPlayer.volume + .1 > 1 ? 1 : player.mediaPlayer.volume + .1
                break;
            case Qt.Key_Down:  //   Ctrl+Down   Volume down
                player.mediaPlayer.volume = player.mediaPlayer.volume - .1 < 0 ? 0 : player.mediaPlayer.volume - .1
                break;
            case Qt.Key_R:  //      Ctrl+R      Repeat toggle
                if (player.mediaPlayer.repeat == "none") { player.mediaPlayer.repeat == "repeatSingle" }
                else if (player.mediaPlayer.repeat == "repeatSingle") { player.mediaPlayer.repeat == "repeatAlbum" }
                else if (player.mediaPlayer.repeat == "repeatAlbum") { player.mediaPlayer.repeat == "none" }
                else { player.mediaPlayer.repeat == "none" }
                break;
            case Qt.Key_F:  //      Ctrl+F      Show Search popup
                if (mainPageStack.currentMusicPage.searchable && mainPageStack.currentMusicPage.state === "default") {
                    mainPageStack.currentMusicPage.state = "search"
                    header.show()
                }

                break;
            case Qt.Key_J:  //      Ctrl+J      Jump to playing song
                tabs.pushNowPlaying()
                mainPageStack.currentPage.setListView(true)
                break;
            case Qt.Key_N:  //      Ctrl+N      Show Now playing
                tabs.pushNowPlaying()
                break;
            case Qt.Key_P:  //      Ctrl+P      Toggle playing state
                player.mediaPlayer.toggle();
                break;
            case Qt.Key_Q:  //      Ctrl+Q      Quit the app
                Qt.quit();
                break;
            case Qt.Key_U:  //      Ctrl+U      Shuffle toggle
                player.mediaPlayer.shuffle = !player.mediaPlayer.shuffle
                break;
            }
        }
        else {
            switch (event.key) {
            case Qt.Key_MediaPlay:  //   Play   Toggle playing state
            case Qt.Key_MediaPause:  //  Pause  Toggle playing state
                player.toggle();
                break;
            case Qt.Key_MediaPrev:   //  Prev   Previous Song
                player.previousSong(true);
                break;
            case Qt.Key_MediaNext:  //   Next   Next Song
                player.nextSong(true, true);
                break;
            }
        }
    }

    // Arguments during startup
    Arguments {
        id: args
        //defaultArgument.help: "Expects URI of the track to play." // should be used when bug is resolved
        //defaultArgument.valueNames: ["URI"] // should be used when bug is resolved
        // grab a file
        Argument {
            name: "url"
            help: "URI for track to run at start."
            required: false
            valueNames: ["track"]
        }
        // Debug/development mode
        Argument {
            name: "debug"
            help: "Start Music in a debug mode. Will show more output."
            required: false
        }
    }

    Action {
        id: nextAction
        text: i18n.tr("Next")
        keywords: i18n.tr("Next Track")
        onTriggered: player.mediaPlayer.playlist.nextWrapper()
    }
    Action {
        id: playsAction
        text: player.mediaPlayer.playbackState === MediaPlayer.PlayingState
              ? i18n.tr("Pause") : i18n.tr("Play")
        keywords: player.mediaPlayer.playbackState === MediaPlayer.PlayingState
                  ? i18n.tr("Pause Playback") : i18n.tr("Continue or start playback")
        onTriggered: player.mediaPlayer.toggle()
    }
    Action {
        id: backAction
        text: i18n.tr("Back")
        keywords: i18n.tr("Go back to last page")
        onTriggered: mainPageStack.goBack();
    }

    // With a default Quit action only the first 4 actions are displayed
    // until the user searches for them within the HUD
    Action {
        id: prevAction
        text: i18n.tr("Previous")
        keywords: i18n.tr("Previous Track")
        onTriggered: player.mediaPlayer.playlist.previousWrapper()
    }
    Action {
        id: stopAction
        text: i18n.tr("Stop")
        keywords: i18n.tr("Stop Playback")
        onTriggered: player.mediaPlayer.stop()
    }

    actions: [nextAction, playsAction, prevAction, stopAction, backAction]

    UriHandlerHelper {
        id: uriHandler
    }

    ContentHubHelper {
        id: contentHub
    }

    UserMetricsHelper {
        id: userMetrics
    }

    // Design stuff
    Style { id: styleMusic }
    width: units.gu(100)
    height: units.gu(80)

    WorkerWaiter {
        id: waitForWorker
    }

    // Run on startup
    Component.onCompleted: {
        i18n.domain = "lomiri-music-app";

        Library.createRecent()  // initialize recent
        Library.createQueue()  // create queue if it doesn't exist

        // initialize playlists
        Playlists.initializePlaylist()

        if (!args.values.url) {
            // load the previous queue as there are no args

            // FIXME: load and save do not work yet pad.lv/1510225
            // so use our localstorage method for now
            // player.mediaPlayer.playlist.load("/home/phablet/.local/share/music.ubports/queue.m3u")
            // use onloaded() and onLoadFailed() to confirm it is complete

            if (!Library.isQueueEmpty()) {
                console.debug("*** Restoring library queue");
                player.mediaPlayer.playlist.addItems(Library.getQueue());

                player.mediaPlayer.playlist.setCurrentIndex(queueIndex);
                player.mediaPlayer.playlist.setPendingCurrentState(MediaPlayer.PausedState);
            }
            else {
                console.debug("Queue is empty, not loading any recent tracks");
            }
        }

        // everything else
        loading.visible = true

        // push the page to view
        mainPageStack.push(tabs)

        // if a tab index exists restore it, otherwise goto Recent if there are items otherwise go to Albums
        tabs.selectedTabIndex = startupSettings.tabIndex === -1
                ? (Library.isRecentEmpty() ? albumsTab.index : 0)
                : (startupSettings.tabIndex > tabs.count - 1
                   ? tabs.count - 1 : startupSettings.tabIndex)

        loadedUI = true;

        // Run post load
        tabs.ensurePopulated(tabs.selectedTab);

        // Display walkthrough on first run, even if the user has music
        if (firstRun) {
            mainPageStack.push(Qt.resolvedUrl("components/Walkthrough/FirstRunWalkthrough.qml"), {})
        }

        if (args.values.url) {
            uriHandler.process(args.values.url, true);
        }
    }

    // VARIABLES
    property string musicName: i18n.tr("Music")
    property bool toolbarShown: musicToolbar.visible
    property bool selectedAlbum: false
    property alias firstRun: startupSettings.firstRun
    property alias queueIndex: startupSettings.queueIndex
    property bool noMusic: allSongsModel.rowCount === 0 && allSongsModelModel.status === SongsModel.Ready && loadedUI
    property bool emptyState: noMusic && !firstRun && !contentHub.processing
    property Page emptyPage

    signal listItemSwiping(int i)

    property bool wideAspect: width >= units.gu(95) && loadedUI
    property bool loadedUI: false  // property to detect if the UI has finished

    // FUNCTIONS

    onEmptyStateChanged: {
        if (emptyState) {
            emptyPage = mainPageStack.push(Qt.resolvedUrl("ui/LibraryEmptyState.qml"), {})
        } else {
            mainPageStack.popPage(emptyPage)
        }
    }

    // Custom debug funtion that's easier to shut off
    function customdebug(text) {
        var debug = true; // set to "0" for not debugging
        //if (args.values.debug) { // *USE LATER*
        if (debug) {
            console.debug(i18n.tr("Debug: ")+text);
        }
    }

    // Converts an duration in ms to a formated string ("minutes:seconds")
    function durationToString(duration) {
        var minutes = Math.floor((duration/1000) / 60);
        var seconds = Math.floor((duration/1000)) % 60;
        // Make sure that we never see "NaN:NaN"
        if (minutes.toString() == 'NaN')
            minutes = 0;
        if (seconds.toString() == 'NaN')
            seconds = 0;
        return minutes + ":" + (seconds<10 ? "0"+seconds : seconds);
    }

    // Make dictionary from model item
    function makeDict(model) {
        return {
            album: model.album,
            art: model.art,
            author: model.author,
            filename: model.filename || model.source,
            title: model.title
        };
    }

    // Clear the queue, queue this model and play the specific index
    function trackClicked(model, index, play) {
        // TODO: remove once playlists uses U1DB
        if (model.hasOwnProperty("linkLibraryListModel")) {
            model = model.linkLibraryListModel;
        }

        var file = Qt.resolvedUrl(model.get(index, model.RoleModelData).filename);

        play = play === undefined ? true : play  // default play to true

        player.mediaPlayer.playlist.clearWrapper();  // clear the old model
        player.mediaPlayer.playlist.setCurrentIndex(index);
        player.mediaPlayer.playlist.addItemsFromModel(model);

        if (play) {
            // Set the pending state for the playlist
            // this will be set once the currentIndex has been appened to the playlist
            player.mediaPlayer.playlist.setPendingCurrentState(MediaPlayer.PlayingState);

            // Show the Now playing page and make sure the track is visible
            tabs.pushNowPlaying();
        }
    }

    // Play or pause a current track in the queue
    // - the index has been tapped by the user
    function trackQueueClick(index) {
        if (player.mediaPlayer.playlist.currentIndex === index) {
            player.mediaPlayer.toggle();
        }  else {
            player.mediaPlayer.playlist.setCurrentIndex(index);
            player.mediaPlayer.playlist.setPendingCurrentState(MediaPlayer.PlayingState);
        }
    }

    // Clear the queue and play a random track from this model
    // - user has selected "Shuffle" in album/artists or "Tap to play random"
    function playRandomSong(model)
    {
        // If no model is given use all the tracks
        if (model === undefined) {
            model = allSongsModel;
        }

        player.mediaPlayer.playlist.clearWrapper();
        player.mediaPlayer.playlist.addItemsFromModel(model);
        player.shuffle = true;

        // Once the model count has been reached in the queue
        // shuffle the model
        player.mediaPlayer.playlist.setPendingShuffle(model.count);

        tabs.pushNowPlaying();
    }

    // Wrapper function around decodeURIComponent() to prevent exceptions
    // from bubbling up to the app.
    function decodeFileURI(filename)
    {
        var newFilename = "";
        try {
            newFilename = decodeURIComponent(filename);
        } catch (e) {
            newFilename = filename;
            console.log("Unicode decoding error:", filename, e.message)
        }

        return newFilename;
    }

    // Load mediascanner store
    MediaStore {
        id: musicStore
    }

    SortFilterModel {
        id: allSongsModel
        objectName: "allSongsModel"
        property alias rowCount: allSongsModelModel.rowCount
        model: SongsModel {
            id: allSongsModelModel
            objectName: "allSongsModelModel"
            store: musicStore

            // if any tracks are removed from ms2 then check they are not in the queue
            onFilled: {
                var i
                var removed = []

                // Find tracks from the queue that aren't in ms2 anymore
                for (i=0; i < player.mediaPlayer.playlist.count; i++) {
                    var file = decodeFileURI(player.mediaPlayer.playlist.itemSource(i));

                    // ms2 doesn't expect the URI scheme so strip file://
                    if (file.indexOf("file://") === 0) {
                        file = file.substr(7);
                    }

                    if (musicStore.lookup(file) === null) {
                        removed.push(i)
                    }
                }

                // If there are removed tracks then remove them from the queue and store
                if (removed.length > 0) {
                    console.debug("Removed queue:", JSON.stringify(removed))
                    player.mediaPlayer.playlist.removeItemsWrapper(removed.slice());
                }

                // Loop through playlists, getPlaylistTracks will remove any tracks that don't exist
                var playlists = Playlists.getPlaylists()

                for (i=0; i < playlists.length; i++) {
                    Playlists.getPlaylistTracks(playlists[i].name)
                }

                // TODO: improve in refactoring to be able detect when a track is removed
                // Update playlists page
                if (tabs.selectedTab == playlistsTab) {
                    playlistModel.filterPlaylists()
                }
            }
        }
        sort.property: "title"
        sort.order: Qt.AscendingOrder
        sortCaseSensitivity: Qt.CaseInsensitive
    }

    AlbumsModel {
        id: allAlbumsModel
        store: musicStore
        // if any tracks are removed from ms2 then check they are not in recent
        onFilled: {
            var albums = []
            var i
            var removed = []

            for (i=0; i < allAlbumsModel.count; i++) {
                albums.push(allAlbumsModel.get(i, allAlbumsModel.RoleTitle))
            }

            // Find albums from recent that aren't in ms2 anymore
            var recent = Library.getRecent()

            for (i=0; i < recent.length; i++) {
                if (recent[i].type === "album" && albums.indexOf(recent[i].data) === -1) {
                    removed.push(recent[i].data)
                }
            }

            // If there are removed tracks then remove them from recent
            if (removed.length > 0) {
                console.debug("Removed recent:", JSON.stringify(removed))
                Library.recentRemoveAlbums(removed)

                if (recentPage.visible) {
                    recentModel.filterRecent()
                } else {
                    recentPage.changed = true
                }
            }
        }
    }

    SongsModel {
        id: songsAlbumArtistModel
        store: musicStore
        onStatusChanged: {
            if (status === SongsModel.Ready) {
                // Play album it tracks exist
                if (rowCount > 0 && selectedAlbum) {
                    trackClicked(songsAlbumArtistModel, 0, true);

                    // Add album to recent list
                    Library.addRecent(songsAlbumArtistModel.get(0, SongsModel.RoleModelData).album, "album")
                    recentModel.filterRecent()
                } else if (selectedAlbum) {
                    console.debug("Unknown artist-album " + artist + "/" + album + ", skipping")
                }

                selectedAlbum = false;

                // Clear filter for artist and album
                songsAlbumArtistModel.albumArtist = ""
                songsAlbumArtistModel.album = ""
            }
        }
    }

    // WHERE THE MAGIC HAPPENS
    Player {
        id: player
    }

    // TODO: Used by playlisttracks move to U1DB
    LibraryListModel {
        id: albumTracksModel
    }

    // TODO: used by recent items move to U1DB
    LibraryListModel {
        id: recentModel
        property bool complete: false
        onPreLoadCompleteChanged: {
            complete = true;

            if (preLoadComplete)
            {
                loading.visible = false
                recentTabRepeater.loading = false
                recentTabRepeater.populated = true

                // Ensure any active tabs are insync as they use a copy of the repeater state
                for (var i=0; i < recentTabRepeater.count; i++) {
                    recentTabRepeater.itemAt(i).loading = false
                    recentTabRepeater.itemAt(i).populated = true
                }
            }
        }
    }

    // TODO: list of playlists move to U1DB
    // create the listmodel to use for playlists
    LibraryListModel {
        id: playlistModel
        syncFactor: 1

        onPreLoadCompleteChanged: {
            if (preLoadComplete)
            {
                loading.visible = false
                playlistsTab.loading = false
                playlistsTab.populated = true
            }
        }
    }

    PageStack {
        id: mainPageStack
        anchors {
            bottom: parent.bottom
            fill: undefined
            left: parent.left
            right: nowPlayingSidebarLoader.left
            top: parent.top
        }
        clip: true  // otherwise listitems actions overflow

        // Properties storing the current page info
        property Page currentMusicPage: null  // currentPage can be Tabs
        property bool popping: false

        /* Helper functions */

        // Go back up the stack if possible
        function goBack() {
            // Ensure in the case that goBack is called programmatically that any dialogs are closed
            if (mainPageStack.currentMusicPage && mainPageStack.currentMusicPage.currentDialog !== null) {
                PopupUtils.close(mainPageStack.currentMusicPage.currentDialog)
            }

            if (depth > 1) {
                pop()
            }
        }

        // Pop a specific page in the stack
        function popPage(page) {
            var tmpPages = []

            // Ensure in the case that popPage is called programmatically that any dialogs are closed
            if (page.currentDialog !== undefined && page.currentDialog !== null) {
                PopupUtils.close(page.currentDialog)
            }

            popping = true

            while (currentPage !== page && depth > 0) {
                tmpPages.push(currentPage)
                pop()
            }

            if (depth > 0) {
                pop()
            }

            for (var i=tmpPages.length - 1; i > -1; i--) {
                push(tmpPages[i])
            }

            popping = false
        }

        // Set the current page, and any parent/stacks
        function setPage(childPage) {
            if (!popping) {
                currentMusicPage = childPage;
            }
        }

        Tabs {
            id: tabs
            anchors {
                fill: parent
            }

            property Tab lastTab: selectedTab
            property list<Action> tabActions: [
                Action {
                    enabled: recentTabRepeater.count > 0
                    objectName: "recentTabAction"
                    text: enabled ? recentTabRepeater.itemAt(0).title : ""
                    visible: enabled

                    onTriggered: {
                        if (enabled) {
                            tabs.selectedTabIndex = recentTabRepeater.itemAt(0).index
                        }
                    }
                },
                Action {
                    objectName: "artistsTabAction"
                    text: artistsTab.title
                    onTriggered: tabs.selectedTabIndex = artistsTab.index
                },
                Action {
                    objectName: "albumsTabAction"
                    text: albumsTab.title
                    onTriggered: tabs.selectedTabIndex = albumsTab.index
                },
                Action {
                    objectName: "genresTabAction"
                    text: genresTab.title
                    onTriggered: tabs.selectedTabIndex = genresTab.index
                },
                Action {
                    objectName: "songsTabAction"
                    text: songsTab.title
                    onTriggered: tabs.selectedTabIndex = songsTab.index
                },
                Action {
                    objectName: "playlistsTabAction"
                    text: playlistsTab.title
                    onTriggered: tabs.selectedTabIndex = playlistsTab.index
                }
                // },
                // Action {
                //     objectName: "settingsTabAction"
                //     text: settingsTab.title
                //     onTriggered: tabs.selectedTabIndex = settingsTab.index
                // }
            ]

            property bool completed: false
            Component.onCompleted: completed = true

            onSelectedTabChanged: {
                // pause loading of the models in the old tab
                if (lastTab !== null && lastTab !== selectedTab) {
                    allowLoading(lastTab, false);
                }

                lastTab = selectedTab;

                ensurePopulated(selectedTab);
            }

            onSelectedTabIndexChanged: {
                if (loadedUI) {  // store the tab index if changed by the user
                    startupSettings.tabIndex = selectedTabIndex
                }
            }

            // Use a repeater to 'hide' the recent tab when the model is empty
            // A repeater is used because the Tabs component respects adds and
            // removes. Whereas replacing the list tabChildren does not appear
            // to respect removes and setting the page as active: false causes
            // the page to be blank but the action to still in the overflow
            Repeater {
                id: recentTabRepeater
                // If the model has not loaded and at startup the db was not empty
                // then show recent or
                // If the workerlist has been set and it has values then show recent
                model: (!recentModel.preLoadComplete && !startupRecentEmpty) ||
                       (recentModel.workerList !== undefined &&
                        recentModel.workerList.length > 0) ? 1 : 0
                delegate: Component {
                    // First tab is all music
                    Tab {
                        property bool populated: recentTabRepeater.populated
                        property var loader: [recentModel.filterRecent]
                        property bool loading: recentTabRepeater.loading
                        property var model: [recentModel, albumTracksModel]
                        id: recentTab
                        objectName: "recentTab"
                        anchors.fill: parent
                        title: i18n.tr("Recent")

                        // Tab content begins here
                        page: Loader {
                            width: mainPageStack.width
                            height: mainPageStack.height
                            active: tabs.selectedTab == recentTab
                            source: Qt.resolvedUrl("ui/Recent.qml")
                        }
                    }
                }

                // Store the startup state of the db separately otherwise
                // it breaks the binding of model
                property bool startupRecentEmpty: Library.isRecentEmpty()

                // cached values of the recent model that are copied when
                // the tab is created
                property bool loading: false
                property bool populated: false

                onCountChanged: {
                    if (count === 0 && loadedUI) {
                        // Jump to the albums tab when recent is empty
                        tabs.selectedTabIndex = albumsTab.index
                    } else if (count > 0 && !loadedUI) {
                        // UI is still loading and recent tab has been inserted
                        // so move the selected index 'down' as the value is
                        // not auto updated - this is for the case of loading
                        // directly to the recent tab (otherwise the content
                        // appears as the second tab but the tabs think they are
                        // on the first tab)
                        tabs.selectedTabIndex -= 1
                    } else if (count > 0 && loadedUI) {
                        // tab inserted while the app is running so move the
                        // selected index 'up' to keep the same position
                        tabs.selectedTabIndex += 1
                    }
                }
            }

            // Second tab is arists
            Tab {
                property bool populated: true
                property var loader: []
                property bool loading: false
                property var model: []
                id: artistsTab
                objectName: "artistsTab"
                anchors.fill: parent
                title: i18n.tr("Artists")

                // tab content
                page: Loader {
                    width: mainPageStack.width
                    height: mainPageStack.height
                    // condition on tabs.completed necessary to avoid QTBUG 54657
                    // https://bugreports.qt.io/browse/QTBUG-54657
                    active: tabs.completed && tabs.selectedTab == artistsTab
                    source: Qt.resolvedUrl("ui/Artists.qml")
                }
            }

            // third tab is albums
            Tab {
                property bool populated: true
                property var loader: []
                property bool loading: false
                property var model: []
                id: albumsTab
                objectName: "albumsTab"
                anchors.fill: parent
                title: i18n.tr("Albums")

                // Tab content begins here
                page: Loader {
                    width: mainPageStack.width
                    height: mainPageStack.height
                    // condition on tabs.completed necessary to avoid QTBUG 54657
                    // https://bugreports.qt.io/browse/QTBUG-54657
                    active: tabs.completed && tabs.selectedTab == albumsTab
                    source: Qt.resolvedUrl("ui/Albums.qml")
                }
            }

            // forth tab is genres
            Tab {
                property bool populated: true
                property var loader: []
                property bool loading: false
                property var model: []
                id: genresTab
                objectName: "genresTab"
                anchors.fill: parent
                title: i18n.tr("Genres")

                // Tab content begins here
                page: Loader {
                    width: mainPageStack.width
                    height: mainPageStack.height
                    // condition on tabs.completed necessary to avoid QTBUG 54657
                    // https://bugreports.qt.io/browse/QTBUG-54657
                    active: tabs.completed && tabs.selectedTab == genresTab
                    source: Qt.resolvedUrl("ui/Genres.qml")
                }
            }

            // fourth tab is all songs
            Tab {
                property bool populated: true
                property var loader: []
                property bool loading: false
                property var model: []
                id: songsTab
                objectName: "songsTab"
                anchors.fill: parent
                title: i18n.tr("Tracks")

                // Tab content begins here
                page: Loader {
                    width: mainPageStack.width
                    height: mainPageStack.height
                    // condition on tabs.completed necessary to avoid QTBUG 54657
                    // https://bugreports.qt.io/browse/QTBUG-54657
                    active: tabs.completed && tabs.selectedTab == songsTab
                    source: Qt.resolvedUrl("ui/Songs.qml")
                }
            }

            // fifth tab is the playlists
            Tab {
                property bool populated: false
                property var loader: [playlistModel.filterPlaylists]
                property bool loading: false
                property var model: [playlistModel, albumTracksModel]
                id: playlistsTab
                objectName: "playlistsTab"
                anchors.fill: parent
                title: i18n.tr("Playlists")

                // Tab content begins here
                page: Loader {
                    width: mainPageStack.width
                    height: mainPageStack.height
                    // condition on tabs.completed necessary to avoid QTBUG 54657
                    // https://bugreports.qt.io/browse/QTBUG-54657
                    active: tabs.completed && tabs.selectedTab == playlistsTab
                    source: Qt.resolvedUrl("ui/Playlists.qml")
                }
            }

            // // sixth tab is settings
            // Tab {
            //     property bool populated: true
            //     property bool loading: false
            //     id: settingsTab
            //     objectName: "settingsTab"
            //     anchors.fill: parent
            //     title: i18n.tr("Settings")
            //
            //     // Tab content begins here
            //     page: SettingsPage {
            //         id: settingsPage
            //     }
            // }

            // Set the models in the tab to allow/disallow loading
            function allowLoading(tabToLoad, state)
            {
                if (tabToLoad && tabToLoad.model !== undefined)
                {
                    for (var i=0; i < tabToLoad.model.length; i++)
                    {
                        tabToLoad.model[i].canLoad = state;
                    }
                }
            }

            function ensurePopulated(selectedTab)
            {
                if (selectedTab) {  // check not null or undefined
                    allowLoading(selectedTab, true);  // allow loading of the models

                    if (!selectedTab.populated && !selectedTab.loading && loadedUI) {
                        loading.visible = true
                        selectedTab.loading = true

                        if (selectedTab.loader !== undefined)
                        {
                            for (var i=0; i < selectedTab.loader.length; i++)
                            {
                                selectedTab.loader[i]();
                            }
                        }
                    }

                    loading.visible = selectedTab.loading || !selectedTab.populated
                }
            }

            function pushNowPlaying()
            {
                if (!wideAspect) {
                    // only push if on a different page
                    if (mainPageStack.currentPage.title !== i18n.tr("Now playing")) {
                        mainPageStack.push(Qt.resolvedUrl("ui/NowPlaying.qml"), {})
                    }

                    if (mainPageStack.currentPage.isListView === true) {
                        mainPageStack.currentPage.setListView(false);  // ensure full view
                    }
                }
            }
        } // end of tabs
    }

    //
    // Components that are ontop of the PageStack
    //

    Loader {
        id: nowPlayingSidebarLoader
        anchors {  // start offscreen
            bottom: parent.bottom
            left: parent.right
            leftMargin: shown && status === Loader.Ready ? -width : 0
            top: parent.top
        }
        asynchronous: true
        // use source as empty string instead of active false otherwise item
        // isn't fully unloaded and appears in autopilot twice
        // http://doc.qt.io/qt-5/qml-qtquick-loader.html#source-prop
        source: shown || anchors.leftMargin < 0 ? "components/NowPlayingSidebar.qml" : ""
        visible: width > 0
        width: units.gu(40)

        property bool shown: loadedUI && wideAspect && player.mediaPlayer.playlist.itemCount > 0

        Behavior on anchors.leftMargin {
            NumberAnimation {

            }
        }
    }

    Loader {
        id: musicToolbar
        anchors {
            left: parent.left
            right: parent.right
            top: parent.bottom
            topMargin: !wideAspect && status === Loader.Ready ? -height : 0
        }
        asynchronous: true
        // use source as empty string instead of active false otherwise item
        // isn't fully unloaded and appears in autopilot twice
        // http://doc.qt.io/qt-5/qml-qtquick-loader.html#source-prop
        source: !wideAspect || anchors.topMargin < 0 ? "components/MusicToolbar.qml" : ""
        visible: (mainPageStack.currentPage && (mainPageStack.currentPage.showToolbar || mainPageStack.currentPage.showToolbar === undefined)) &&
                 !firstRun &&
                 !noMusic &&
                 anchors.topMargin < 0

        Behavior on anchors.topMargin {
            NumberAnimation {

            }
        }
    }

    LoadingSpinnerComponent {
        id: loading
    }
} // end of main view

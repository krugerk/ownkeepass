/***************************************************************************
**
** Copyright (C) 2013 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Sailfish.Silica 1.0
import "../common"
import "../scripts/Global.js" as Global
import KeepassPlugin 1.0

Page {
    id: mainPage

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: col.height

        // Show a scollbar when the view is flicked, place this over all other content
        VerticalScrollDecorator {}

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        KpPushUpMenu {}

        Column {
            id: col
            width: parent.width
            spacing: Theme.paddingLarge

            PageHeaderExtended {
                title: "ownKeepass"
                subTitle: "Password Safe"
            }

        }
    }

    KdbDatabase {
        id: kdbDatabase
        onPreCheckDone: internal.preCheckDoneHandler(result)
        onDatabaseOpened: internal.databaseOpenedHandler(result, errorMsg)
        onNewDatabaseCreated: internal.newDatabaseCreatedHandler(result, errorMsg)
        onDatabaseClosed: internal.databaseClosedHandler(result, errorMsg)
    }

    Component.onCompleted: {
        Global.env.setKdbDatabase(kdbDatabase)
        Global.env.setKeepassSettings(keepassSettings)
    }

    onStatusChanged: {
        if (status === PageStatus.Active) internal.init()
    }

    QtObject {
        id: keepassSettings
        property bool simpleMode: true
        // default database and key file paths used in simple mode to create one database easily
        property bool loadDefault: true // if (simpleMode === true) this is ignored resp. always true
        property string defaultDatabasePath: "/home/nemo/Documents/notes.kdb"
        property string defaultKeyFilePath: ""
        // Default encryption: AES/Rijndael = 0, Twofish = 1
        property int defaultEncryption: 0
        property int defaultKeyTransfRounds: 50000
        // Other user settings
        // LockTime: min = 0, max = 10, default = 3
        property int locktime: 3
        // ShowUserPasswordInListView, default = false
        property bool showUserNamePasswordInListView: false

        function loadSettings() {
            var settingsDb = LocalStorage.openDatabaseSync("ownKeepassSettings", "1.00", "Application settings for ownKeepass", 100000)
            settingsDb.transaction(
                        function(tx) {
                            // Create the database if it doesn't already exist
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(version INTEGER PRIMARY KEY, simpleMode BOOLEAN, loadDefault BOOLEAN, defaultDatabasePath TEXT, defaultKeyFilePath TEXT, defaultEncryption INTEGER, defaultKeyTransfRounds INTEGER, locktime INTEGER, showUserNamePasswordInListView BOOLEAN)')
                            var settings = tx.executeSql('SELECT * FROM Settings')
                            if (settings.rows.length === 0) {
                                // Add default values for settings if it does not exist
                                tx.executeSql('INSERT INTO Settings VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                              ['100', '1', '1', '/home/nemo/Documents/notes.kdb', '', '0', '50000', '3', '0'])
                                settings = tx.executeSql('SELECT * FROM Settings')
                            }

                            // Show all added data
                            for(var i = 0; i < settings.rows.length; i++) {
                                console.log("Settings " + i + ": " + settings.rows.item(i).version + ", " +
                                            settings.rows.item(i).simpleMode + ", " +
                                            settings.rows.item(i).loadDefault + ", " +
                                            settings.rows.item(i).defaultDatabasePath + ", " +
                                            settings.rows.item(i).defaultKeyFilePath + ", " +
                                            settings.rows.item(i).defaultEncryption + ", " +
                                            settings.rows.item(i).defaultKeyTransfRounds + ", " +
                                            settings.rows.item(i).locktime + ", " +
                                            settings.rows.item(i).showUserNamePasswordInListView)
                            }
                            simpleMode = settings.rows.item(0).simpleMode === 0 ? false : true
                            loadDefault = settings.rows.item(0).loadDefault === 0 ? false : true
                            defaultDatabasePath = settings.rows.item(0).defaultDatabasePath
                            defaultKeyFilePath = settings.rows.item(0).defaultKeyFilePath
                            defaultEncryption = settings.rows.item(0).defaultEncryption
                            defaultKeyTransfRounds  = settings.rows.item(0).defaultKeyTransfRounds
                            locktime = settings.rows.item(0).locktime
                            showUserNamePasswordInListView = settings.rows.item(0).showUserNamePasswordInListView === 0 ? false : true
                        }
                        )
        }

        function saveSettings() {
            var settingsDb = LocalStorage.openDatabaseSync("ownKeepassSettings", "1.00", "Application settings for ownKeepass", 100000)
            settingsDb.transaction(
                        function(tx) {
                            // Create the database if it doesn't already exist
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(version INTEGER PRIMARY KEY, simpleMode BOOLEAN, loadDefault BOOLEAN, defaultDatabasePath TEXT, defaultKeyFilePath TEXT, defaultEncryption INTEGER, defaultKeyTransfRounds INTEGER, locktime INTEGER, showUserNamePasswordInListView BOOLEAN)')
                            // Save values for all settings
                            tx.executeSql('REPLACE INTO Settings VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)',
                                          ['100',
                                           simpleMode ? 1 : 0,
                                           loadDefault ? 1 : 0,
                                           defaultDatabasePath,
                                           defaultKeyFilePath,
                                           defaultEncryption,
                                           defaultKeyTransfRounds,
                                           locktime,
                                           showUserNamePasswordInListView ? 1 : 0])

                            // Show all added data
                            var settings = tx.executeSql('SELECT * FROM Settings')
                            for(var i = 0; i < settings.rows.length; i++) {
                                console.log("Settings " + i + ": " + settings.rows.item(i).version + ", " +
                                            settings.rows.item(i).simpleMode + ", " +
                                            settings.rows.item(i).loadDefault + ", " +
                                            settings.rows.item(i).defaultDatabasePath + ", " +
                                            settings.rows.item(i).defaultKeyFilePath + ", " +
                                            settings.rows.item(i).defaultEncryption + ", " +
                                            settings.rows.item(i).defaultKeyTransfRounds + ", " +
                                            settings.rows.item(i).locktime + ", " +
                                            settings.rows.item(i).showUserNamePasswordInListView)
                            }
                        }
                        )
        }

                        Component.onCompleted: loadSettings()
    }

    // internal stuff
    QtObject {
        id: internal
        property bool createNewDatabase: true
        property string databasePath: ""
        property string keyFilePath: ""
        property Page masterGroupsPage

        function openKeepassDatabase(password, createNewDatabase) {
            if (password === "") console.log("ERROR: Password is empty")
            if (createNewDatabase) {
                // set default values for encryption and key transformation rounds
                kdbDatabase.keyTransfRounds = keepassSettings.defaultKeyTransfRounds
                kdbDatabase.cryptAlgorithm = keepassSettings.defaultEncryption
                // create new Keepass database
                kdbDatabase.create(databasePath, keyFilePath, password)
            } else {
                // open existing Keepass database
                kdbDatabase.open(databasePath, keyFilePath, password, false)
            }
        }

        function init() {
            // load settings into kdbDatabase
            kdbDatabase.showUserNamePasswordsInListView = keepassSettings.showUserNamePasswordInListView

            if (keepassSettings.loadDefault) {
                databasePath = keepassSettings.defaultDatabasePath
                keyFilePath  = keepassSettings.defaultKeyFilePath
            } else {
                // check if some other recently opened database is set as default = !simpleMode
// TODO

            }
            kdbDatabase.preCheck(databasePath, keyFilePath)
        }

        function preCheckDoneHandler(result) {
            var dialog
            console.log("onPreCheckDone: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // files exists so open query password dialog
                createNewDatabase = false
                dialog = pageStack.push("QueryPasswordDialog.qml", {"createNewDatabase": createNewDatabase})
                            dialog.accepted.connect(function() {
                                openKeepassDatabase(dialog.password, createNewDatabase)
                                // delete password once used
                                dialog.password = ""
                                masterGroupsPage = dialog.acceptDestinationInstance
                            })
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_ERROR: {
                // in this case the database file does not exists so let the user create a new keepass database
                createNewDatabase = true
                dialog = pageStack.push("QueryPasswordDialog.qml", {"createNewDatabase": createNewDatabase})
                            dialog.accepted.connect(function() {
                                openKeepassDatabase(dialog.password, createNewDatabase)
                                // delete password once used
                                dialog.password = ""
                                masterGroupsPage = dialog.acceptDestinationInstance
                            })
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_ERROR: {
                // in this case database file exists but not key file
                createNewDatabase = true
                Global.env.infoPopup.show("Key File Error", "Database path is ok, but your key file is not present. Please check ownKeepass Settings for correct path to the key file or leave key file path empty if you don't use a key file with your database.", 30000)
                break; }
            case KdbDatabase.RE_PRECHECK_DB_PATH_CREATION_ERROR: {
                console.log("ERROR: Cannot create path directories to database file, check your file permissions")
                createNewDatabase = true
                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your Keepass database file. Please choose another path.", 30000)
                break; }
            case KdbDatabase.RE_PRECHECK_KEY_FILE_PATH_CREATION_ERROR: {
                createNewDatabase = true
                Global.env.infoPopup.show("Permission Error", "Cannot create directories for your key file. Please choose another path.", 30000)
                break; }
            default: {
                console.log("ERROR: unknown result on onPreCheckDone")
                break; }
            }
        }

        function databaseOpenedHandler(result, errorMsg) {
            var dialog
            console.log("onDatabaseOpened: " + result)
            switch (result) {
            case KdbDatabase.RE_OK:
                // init master groups page
                masterGroupsPage.init()
                break
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Password Error", "The following error occured during opening of database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Keyfile Error", "The following error occured during opening of database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_LOAD_ERROR:
                // show error to the user
                Global.env.infoPopup.show("Password Error", errorMsg + " Please try again.")
                masterGroupsPage.closeOnError()
                break
            default:
                console.log("ERROR: unknown result on databaseOpened")
                break
            }
        }

        function newDatabaseCreatedHandler(result, errorMsg) {
            var page
            console.log("onNewDatabaseCreated: " + result)
            switch (result) {
            case KdbDatabase.RE_OK: {
                // open database groups main page and replace password page in page stack
                page = pageStack.push(Qt.resolvedUrl("GroupsAndEntriesPage.qml").toString(),
                               { pageTitle: "Password groups",
                                 groupId: 0,
                                 loadMasterGroups: true }, false, true);
                masterGroupsPage = page
                // database is now created
                internal.createNewDatabase = false
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Could not close the previous opened database. Please try again. Error message: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_FILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal File Error", "The following error occured during creation of database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETPW_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Password Error", "The following error occured during creation of database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SETKEYFILE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Keyfile Error", "The following error occured during creation of database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_CREATE_BACKUPGROUP_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Internal Database Error", "Creation of backup group failed with following error: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_SAVE_ERROR: {
                // show error to the user
                Global.env.infoPopup.show("Save Database Error", "Could not save database with following error: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            default:
                console.log("ERROR: unknown result on databaseCreated")
                break
            }
        }

        function databaseClosedHandler(result, errorMsg) {
            switch (result) {
            case KdbDatabase.RE_OK:
                console.log("Database closed")
                break
            case KdbDatabase.RE_DB_ALREADY_CLOSED: {
                // show error to the user
                Global.env.infoPopup.show("Database Error", "Database was already closed. Nothing serious, but please submit a bug report.")
                masterGroupsPage.closeOnError()
                break }
            case KdbDatabase.RE_DB_CLOSE_FAILED: {
                // show error to the user
                Global.env.infoPopup.show("Database Error", "An error occured on closing your database: " + errorMsg)
                masterGroupsPage.closeOnError()
                break }
            default:
                console.log("ERROR: unknown result on databaseClosed")
                break
            }
        }
    }
}



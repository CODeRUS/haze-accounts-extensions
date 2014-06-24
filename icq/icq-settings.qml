import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountSettingsDialog {
    id: root
    anchors.fill: parent
    canAccept: settings.acceptableInput

    property string __defaultServiceName: "icq"
    property string originalUsername

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            settings.acceptAttempted = true
        }
    }

    onAccepted: {
        account.enabled = mainAccountSettings.accountEnabled
        account.displayName = mainAccountSettings.accountDisplayName
        account.enableWithService(__defaultServiceName)
        _saveServiceSettings()
    }

    function _populateServiceSettings() {
        var serviceSettings = account.configurationValues(__defaultServiceName)
        settings.username = account.configurationValues("")["default_credentials_username"]
        if (serviceSettings["telepathy/param-server"])
            settings.server = serviceSettings["telepathy/param-server"]
        if (serviceSettings["telepathy/param-ignore-ssl-errors"])
            settings.ignoreSslErrors = serviceSettings["telepathy/param-ignore-ssl-errors"]
        if (serviceSettings["telepathy/param-port"])
            settings.port = serviceSettings["telepathy/param-port"]
        if (serviceSettings["telepathy/param-priority"])
            settings.priority = serviceSettings["telepathy/param-priority"]

        originalUsername = settings.username
        settings.password = "default"
    }

    function _saveServiceSettings() {
        account.setConfigurationValue("", "default_credentials_username", settings.username)
        // param-account is required by Telepathy; it's generated from credentials on creation, but
        // needs to be updated manually
        account.setConfigurationValue(__defaultServiceName, "telepathy/param-account", settings.username)

        if (settings.server === "")
            account.removeConfigurationValue(__defaultServiceName, "telepathy/param-server")
        else
            account.setConfigurationValue(__defaultServiceName, "telepathy/param-server", settings.server)
        if (settings.port === "")
            settings.port = "5222"
        account.setConfigurationValue(__defaultServiceName, "telepathy/param-port", settings.port)
        account.setConfigurationValue(__defaultServiceName, "telepathy/param-ignore-ssl-errors", settings.ignoreSslErrors)
        if (settings.priority === "" || settings.priority == 0)
            account.removeConfigurationValue(__defaultServiceName, "telepathy/param-priority")
        else
            account.setConfigurationValue(__defaultServiceName, "telepathy/param-priority", settings.priority)

        account.sync()
    }

    function _updateCredentials() {
        var password = ""
        if (settings.passwordEdited) {
            password = settings.password
            settings.passwordEdited = false
        }
        account.updateSignInCredentials("Jolla", "Jolla",
                                        account.signInParameters(__defaultServiceName, settings.username, password))
    }

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        PullDownMenu {
            // 'Delete' is the only menu option; only show pulley menu if this action is allowed
            visible: enabled
            enabled: !root.isNewAccount

            MenuItem {
                //: Deletes the account
                //% "Delete Account"
                text: qsTrId("accounts-me-delete_account")
                onClicked: {
                    root.accountDeletionRequested()
                    pageStack.pop()
                }
            }
        }

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                //: Save the account settings
                //% "Save"
                acceptText: qsTrId("accounts-me-save")
                dialog: root
            }

            AccountAddedLabel {
                x: Theme.paddingLarge
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                visible: root.isNewAccount
            }

            AccountMainSettingsDisplay {
                id: mainAccountSettings
                accountProvider: root.accountProvider
                accountUserName: account.defaultCredentialsUserName
                accountDisplayName: account.displayName
            }

            SectionHeader {
                text: "Credentials"
                opacity: mainAccountSettings.accountEnabled ? 1 : 0

                Behavior on opacity { FadeAnimation { } }
            }

            ICQCommon {
                id: settings
                enabled: mainAccountSettings.accountEnabled
                opacity: enabled ? 1 : 0

                Behavior on opacity { FadeAnimation { } }
            }
        }
    }

    Account {
        id: account

        identifier: root.accountId
        property bool needToUpdate

        onStatusChanged: {
            if (status === Account.Initialized) {
                mainAccountSettings.accountEnabled = root.isNewAccount || account.enabled
                root._populateServiceSettings()
            } else if (status === Account.Synced) {
                if (originalUsername != settings.username || settings.passwordEdited) {
                    needToUpdate = true
                }
                updateCredentials()
            } else if (status === Account.Error) {
                // display "error" dialog
            } else if (status === Account.Invalid) {
                // successfully deleted
            }
        }

        function updateCredentials() {
            if (needToUpdate) {
                needToUpdate = false
                originalUsername = settings.username
                _updateCredentials()
            }
        }
    }
}

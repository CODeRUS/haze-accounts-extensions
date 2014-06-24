import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountCreationDialog {
    id: root
    anchors.fill: parent
    canAccept: canSkip || settings.acceptableInput
    canSkip: settings.username == "" && settings.password == "" && settings.server == ""

    property string name: accountProvider.displayName
    property string iconSource: accountProvider.iconName

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            settings.acceptAttempted = true
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Inactive
                && result == DialogResult.Accepted
                && !canSkip) {
            // Start the account creation process when the next page becomes active to ensure the
            // account is not created if user quits app on this screen and also to prevent
            // synchronous account creation from causing a jerky page transition
            accountFactory.beginCreation()
        }
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}
        Column {
            id: contentColumn

            spacing: Theme.paddingLarge
            width: parent.width

            DialogHeader {
                dialog: root
                title: root.canSkip ? root.skipText : defaultAcceptText
            }

            Item {
                width: parent.width
                height: Theme.itemSizeSmall
                x: Theme.paddingLarge

                Image {
                    id: icon
                    width: Theme.iconSizeMedium
                    height: Theme.iconSizeMedium
                    anchors.verticalCenter: parent.verticalCenter
                    source: root.iconSource
                }
                Label {
                    anchors.left: icon.right
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.name
                    color: Theme.highlightColor
                }
            }

            ICQCommon {
                id: settings
            }
        }
    }

    AccountFactory {
        id: accountFactory

        function beginCreation() {
            var configuration = {}
            if (settings.server != "")
                configuration["telepathy/param-server"] = settings.server
            if (settings.port != "")
                configuration["telepathy/param-port"] = settings.port

            createAccount(root.accountProvider.name,
                root.accountProvider.serviceNames[0],
                settings.username, settings.password,
                settings.username,
                { "icq": configuration },       // configuration map
                "Jolla",  // applicationName
                "",       // symmetricKey
                "Jolla")  // credentialsName
        }

        onError: {
            console.log("ICQ creation error:", message)
            root.accountCreationError(message)
        }

        onSuccess: {
            root.accountCreated(newAccountId)
        }
    }
}

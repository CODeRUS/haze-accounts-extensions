import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountCreationAgent {
    id: root

    property Item _settingsDialog

    initialPage: Dialog {
        allowedOrientations: Orientation.Portrait
        canAccept: settings.acceptableInput
        acceptDestination: busyComponent

        SilicaFlickable {
            anchors.fill: parent
            contentHeight: contentColumn.height + Theme.paddingLarge

            Column {
                id: contentColumn
                width: parent.width

                DialogHeader {
                    dialog: initialPage
                }

                Item {
                    x: Theme.paddingLarge
                    width: parent.width - x*2
                    height: icon.height + Theme.paddingLarge

                    Image {
                        id: icon
                        width: Theme.iconSizeLarge
                        height: width
                        anchors.top: parent.top
                        source: root.accountProvider.iconName
                    }
                    Label {
                        anchors {
                            left: icon.right
                            leftMargin: Theme.paddingLarge
                            right: parent.right
                            verticalCenter: icon.verticalCenter
                        }
                        text: root.accountProvider.displayName
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                    }
                }

                ICQCommon {
                    id: settings
                }
            }

            VerticalScrollDecorator {}
        }
    }

    Component {
        id: busyComponent
        AccountBusyPage {
            onStatusChanged: {
                if (status == PageStatus.Active) {
                    accountFactory.beginCreation()
                }
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
            initialPage.acceptDestinationInstance.state = "info"
            root.accountCreationError(message)
        }

        onSuccess: {
            root._settingsDialog = settingsComponent.createObject(root, {"accountId": newAccountId})
            pageStack.push(root._settingsDialog)
            root.accountCreated(newAccountId)
        }
    }

    Component {
        id: settingsComponent
        Dialog {
            property alias accountId: settingsDisplay.accountId

            allowedOrientations: Orientation.Portrait
            acceptDestination: root.endDestination
            acceptDestinationAction: root.endDestinationAction
            acceptDestinationProperties: root.endDestinationProperties
            acceptDestinationReplaceTarget: root.endDestinationReplaceTarget
            backNavigation: false

            onAccepted: {
                root.delayDeletion = true
                settingsDisplay.saveAccount()
            }

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: header.height + settingsDisplay.height + Theme.paddingLarge

                DialogHeader {
                    id: header
                }

                ICQSettingsDisplay {
                    id: settingsDisplay
                    anchors.top: header.bottom
                    accountProvider: root.accountProvider
                    autoEnableAccount: true

                    onAccountSaveCompleted: {
                        root.delayDeletion = false
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}

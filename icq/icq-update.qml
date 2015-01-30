import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountCredentialsAgent {
    id: root

    property bool _ready: newAccount.saved && oldAccount.deleted

    function _handleUpdateError(errorMessage) {
        console.log("Jolla account update error:", errorMessage)
        initialPage.acceptDestinationInstance.state = "info"
        initialPage.acceptDestinationInstance.infoDescription = errorMessage
        root.credentialsUpdateError(errorMessage)
    }

    // we don't delete the old credentials until the new account is deleted
    canCancelUpdate: true

    initialPage: JollaAccountSignInDialog {
        accountProvider: root.accountProvider
        accountManager: root.accountManager
        acceptDestination: busyComponent
        createAccountOnAccept: false

        onAccountCreated: {
            // We've created a new account. Remove the old one.
            // When it's removed, we update the account id to point to the new one.
            newAccount.identifier = newAccountId
            oldAccount.remove()
        }
        onAccountCreationTypedError: {
            _handleUpdateError(errorMessage)
        }
    }

    on_ReadyChanged: {
        if (_ready) {
            credentialsUpdated(newAccount.identifier)
            goToEndDestination()
        }
    }

    Component {
        id: busyComponent
        AccountBusyPage {
            onStatusChanged: {
                if (status == PageStatus.Active) {
                    initialPage.startAccountCreation()
                }
            }
        }
    }

    Account {
        id: newAccount

        property bool saving
        property bool saved

        onStatusChanged: {
            if (saving && status != Account.SyncInProgress) {
                saving = false
                saved = true
            } else if (status === Account.Initialized) {
                var services = supportedServiceNames
                for (var i in services) {
                    // enable the services ("jolla-store" in practice)
                    var service = accountManager.service(services[i])
                    enableWithService(service.name)
                }
                // enable the global service
                enabled = true
                sync()
                saving = true
            }
        }
    }

    Account {
        id: oldAccount
        identifier: root.accountId

        property bool deleted

        onStatusChanged: {
            if (status === Account.Invalid && newAccount.identifier > 0) {
                // successfully deleted the (old) account after creating the new (replacement) one.
                deleted = true
            }
        }
    }
}

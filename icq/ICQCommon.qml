import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.accounts 1.0

Column {
    property bool editMode
    property bool usernameEdited
    property bool passwordEdited
    property bool acceptAttempted
    property alias username: usernameField.text
    property alias password: passwordField.text
    property alias server: serverField.text
    property alias port: portField.text
    property bool acceptableInput: username != "" && password != ""

    spacing: Theme.paddingLarge
    width: parent.width

    TextField {
        id: usernameField
        width: parent.width
        inputMethodHints: Qt.ImhDigitsOnly
        errorHighlight: !text && acceptAttempted

        placeholderText: "Enter username"
        label: "Username"
        onTextChanged: {
            if (focus) {
                usernameEdited = true
                // Updating username also updates password; clear it if it's default value
                if (!passwordEdited)
                    passwordField.text = ""
            }
        }
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: passwordField.focus = true
    }

    TextField {
        id: passwordField
        width: parent.width
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        echoMode: TextInput.Password
        errorHighlight: !text && acceptAttempted

        placeholderText: "Enter password"
        label: "Password"
        onTextChanged: {
            if (focus && !passwordEdited) {
                passwordEdited = true
            }
        }
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: serverField.focus = true
    }

    SectionHeader {
        text: "Advanced settings"
    }

    TextField {
        id: serverField
        width: parent.width
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        placeholderText: "Enter server address (Optional)"
        label: "Server address"
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: portField.focus = true
    }

    TextField {
        id: portField
        width: parent.width
        inputMethodHints: Qt.ImhDigitsOnly
        placeholderText: "Enter port"
        label: "Port"
        text: "5190"
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: priorityField.focus = true
    }
}

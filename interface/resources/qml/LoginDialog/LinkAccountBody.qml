//
//  linkAccountBody.qml
//
//  Created by Wayne Chen on 10/18/18
//  Copyright 2018 High Fidelity, Inc.
//
//  Distributed under the Apache License, Version 2.0.
//  See the accompanying file LICENSE or http://www.apache.org/licenses/LICENSE-2.0.html
//

import Hifi 1.0
import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4 as OriginalStyles

import controlsUit 1.0 as HifiControlsUit
import stylesUit 1.0 as HifiStylesUit
import TabletScriptingInterface 1.0

Item {
    id: linkAccountBody
    clip: true
    height: root.height
    width: root.width
    property int textFieldHeight: 31
    property string fontFamily: "Raleway"
    property int fontSize: 15
    property bool fontBold: true

    property bool keyboardEnabled: false
    property bool keyboardRaised: false
    property bool punctuationMode: false

    onKeyboardRaisedChanged: d.resize();

    property bool withSteam: false
    property bool withOculus: false
    property string errorString: errorString

    QtObject {
        id: d
        readonly property int minWidth: 480
        readonly property int minWidthButton: !root.isTablet ? 256 : 174
        property int maxWidth: root.isTablet ? 1280 : root.width
        readonly property int minHeight: 120
        readonly property int minHeightButton: !root.isTablet ? 56 : 42
        property int maxHeight: root.isTablet ? 720 : root.height

        function resize() {
            maxWidth = root.isTablet ? 1280 : root.width;
            maxHeight = root.isTablet ? 720 : root.height;
            var targetWidth = Math.max(titleWidth, mainContainer.width);
            var targetHeight =  hifi.dimensions.contentSpacing.y + mainContainer.height +
                    4 * hifi.dimensions.contentSpacing.y;

            var newWidth = Math.max(d.minWidth, Math.min(d.maxWidth, targetWidth));
            if (!isNaN(newWidth)) {
                parent.width = root.width = newWidth;
            }

            parent.height = root.height = Math.max(d.minHeight, Math.min(d.maxHeight, targetHeight))
                    + (keyboardEnabled && keyboardRaised ? (200 + 2 * hifi.dimensions.contentSpacing.y) : hifi.dimensions.contentSpacing.y);
        }
    }

    function login() {
        loginDialog.login(emailField.text, passwordField.text);
        bodyLoader.setSource("LoggingInBody.qml", { "loginDialog": loginDialog, "root": root, "bodyLoader": bodyLoader, "withSteam": false, "withOculus": false, "fromBody": "" });
    }

    function init() {
        // going to/from sign in/up dialog.
        loginDialog.isLogIn = true;
        loginErrorMessage.visible = (linkAccountBody.errorString !== "");
        if (linkAccountBody.errorString !== "") {
            loginErrorMessage.text = linkAccountBody.errorString;
            errorContainer.anchors.bottom = emailField.top;
            errorContainer.anchors.left = emailField.left;
        }
        loginButton.text = "Log In";
        loginButton.color = hifi.buttons.blue;
        emailField.placeholderText = "Username or Email";
        var savedUsername = Settings.getValue("keepMeLoggedIn/savedUsername", "");
        emailField.text = keepMeLoggedInCheckbox.checked ? savedUsername === "Unknown user" ? "" : savedUsername : "";
        emailField.anchors.top = loginContainer.top;
        emailField.anchors.topMargin = !root.isTablet ? 0.2 * root.height : 0.24 * root.height;
        loginContainer.visible = true;
    }

    Item {
        id: mainContainer
        width: root.width
        height: root.height
        onHeightChanged: d.resize(); onWidthChanged: d.resize();

        Rectangle {
            id: opaqueRect
            height: parent.height
            width: parent.width
            opacity: 0.9
            color: "black"
        }

        Item {
            id: bannerContainer
            width: parent.width
            height: banner.height
            anchors {
                top: parent.top
                topMargin: 85
            }
            Image {
                id: banner
                anchors.centerIn: parent
                source: "../../images/high-fidelity-banner.svg"
                horizontalAlignment: Image.AlignHCenter
            }
        }

        Item {
            id: loginContainer
            width: parent.width
            height: parent.height - (bannerContainer.height + 1.5 * hifi.dimensions.contentSpacing.y)
            anchors {
                top: bannerContainer.bottom
                topMargin: 1.5 * hifi.dimensions.contentSpacing.y
            }

            Item {
                id: errorContainer
                width: loginErrorMessageTextMetrics.width
                height: loginErrorMessageTextMetrics.height
                anchors {
                    bottom: emailField.top;
                    bottomMargin: 2;
                    left: emailField.left;
                }
                TextMetrics {
                    id: loginErrorMessageTextMetrics
                    font: loginErrorMessage.font
                    text: loginErrorMessage.text
                }
                Text {
                    id: loginErrorMessage;
                    color: "red";
                    font.family: linkAccountBody.fontFamily
                    font.pixelSize: 12
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: ""
                    visible: false
                }
            }

            HifiControlsUit.TextField {
                id: emailField
                width: banner.width
                height: linkAccountBody.textFieldHeight
                font.family: linkAccountBody.fontFamily
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: (parent.width - emailField.width) / 2
                }
                placeholderText: "Username or Email"
                activeFocusOnPress: true
                Keys.onPressed: {
                    switch (event.key) {
                        case Qt.Key_Tab:
                            event.accepted = true;
                            passwordField.focus = true;
                            break;
                        case Qt.Key_Backtab:
                            event.accepted = true;
                            passwordField.focus = true;
                            break;
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                            event.accepted = true;
                            if (keepMeLoggedInCheckbox.checked) {
                                Settings.setValue("keepMeLoggedIn/savedUsername", emailField.text);
                            }
                            linkAccountBody.login();
                            break;
                    }
                }
                onFocusChanged: {
                    root.text = "";
                    root.isPassword = !focus;
                }
            }
            HifiControlsUit.TextField {
                id: passwordField
                width: banner.width
                height: linkAccountBody.textFieldHeight
                font.family: linkAccountBody.fontFamily
                placeholderText: "Password"
                activeFocusOnPress: true
                echoMode: passwordFieldMouseArea.showPassword ? TextInput.Normal : TextInput.Password
                anchors {
                    top: emailField.bottom
                    topMargin: 1.5 * hifi.dimensions.contentSpacing.y
                    left: parent.left
                    leftMargin: (parent.width - emailField.width) / 2
                }

                onFocusChanged: {
                    root.text = "";
                    root.isPassword = focus;
                }

                Item {
                    id: showPasswordContainer
                    z: 10
                    // width + image's rightMargin
                    width: showPasswordImage.width + 8
                    height: parent.height
                    anchors {
                        right: parent.right
                    }

                    Image {
                        id: showPasswordImage
                        width: passwordField.height * 16 / 23
                        height: passwordField.height * 16 / 23
                        anchors {
                            right: parent.right
                            rightMargin: 8
                            top: parent.top
                            topMargin: passwordFieldMouseArea.showPassword ? 6 : 8
                            bottom: parent.bottom
                            bottomMargin: passwordFieldMouseArea.showPassword ? 5 : 8
                        }
                        source: passwordFieldMouseArea.showPassword ?  "../../images/eyeClosed.svg" : "../../images/eyeOpen.svg"
                        MouseArea {
                            id: passwordFieldMouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            property bool showPassword: false
                            onClicked: {
                                showPassword = !showPassword;
                            }
                        }
                    }
                }
                Keys.onPressed: {
                    switch (event.key) {
                        case Qt.Key_Tab:
                        case Qt.Key_Backtab:
                            event.accepted = true;
                            emailField.focus = true;
                            break;
                        case Qt.Key_Enter:
                        case Qt.Key_Return:
                            event.accepted = true;
                            if (keepMeLoggedInCheckbox.checked) {
                                Settings.setValue("keepMeLoggedIn/savedUsername", emailField.text);
                            }
                            linkAccountBody.login();
                            break;
                    }
                }
            }
            HifiControlsUit.CheckBox {
                id: keepMeLoggedInCheckbox
                checked: Settings.getValue("keepMeLoggedIn", false);
                text: qsTr("Keep Me Logged In");
                boxSize: 18;
                labelFontFamily: linkAccountBody.fontFamily
                labelFontSize: 18;
                color: hifi.colors.white;
                anchors {
                    top: passwordField.bottom;
                    topMargin: hifi.dimensions.contentSpacing.y;
                    left: passwordField.left;
                }
                onCheckedChanged: {
                    Settings.setValue("keepMeLoggedIn", checked);
                    if (checked) {
                        Settings.setValue("keepMeLoggedIn/savedUsername", Account.username);
                        var savedUsername = Settings.getValue("keepMeLoggedIn/savedUsername", "");
                        emailField.text = savedUsername === "Unknown user" ? "" : savedUsername;
                    } else {
                        Settings.setValue("keepMeLoggedIn/savedUsername", "");
                    }
                }
                Component.onDestruction: {
                    Settings.setValue("keepMeLoggedIn", checked);
                }
            }
            HifiControlsUit.Button {
                id: loginButton
                width: passwordField.width
                height: d.minHeightButton
                text: qsTr("Log In")
                fontFamily: linkAccountBody.fontFamily
                fontSize: linkAccountBody.fontSize
                fontBold: linkAccountBody.fontBold
                anchors {
                    top: keepMeLoggedInCheckbox.bottom
                    topMargin: hifi.dimensions.contentSpacing.y
                    left: emailField.left
                }
                onClicked: {
                    linkAccountBody.login()
                }
            }
            Item {
                id: cantAccessContainer
                width: parent.width
                height: emailField.height
                anchors {
                    top: loginButton.bottom
                    topMargin: hifi.dimensions.contentSpacing.y
                }
                HifiStylesUit.ShortcutText {
                    id: cantAccessText
                    z: 10
                    anchors.centerIn: parent
                    font.family: linkAccountBody.fontFamily
                    font.pixelSize: 18

                    text: "<a href='https://highfidelity.com/users/password/new'> Can't access your account?</a>"

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    linkColor: hifi.colors.blueAccent
                    onLinkActivated: {
                        Tablet.playSound(TabletEnums.ButtonClick);
                        loginDialog.openUrl(link)
                    }
                }
            }
            HifiControlsUit.Button {
                id: continueButton;
                width: emailField.width;
                height: d.minHeightButton
                color: hifi.buttons.none;
                anchors {
                    top: cantAccessContainer.bottom
                    topMargin: hifi.dimensions.contentSpacing.y
                    left: emailField.left
                }
                text: qsTr("CONTINUE WITH STEAM")
                fontFamily: linkAccountBody.fontFamily
                fontSize: linkAccountBody.fontSize
                fontBold: linkAccountBody.fontBold
                buttonGlyph: hifi.glyphs.steamSquare
                buttonGlyphRightMargin: 10
                onClicked: {
                    if (loginDialog.isOculusStoreRunning()) {
                        linkAccountBody.withOculus = true;
                        loginDialog.loginThroughSteam();
                    } else if (loginDialog.isSteamRunning()) {
                        linkAccountBody.withSteam = true;
                        loginDialog.loginThroughSteam();
                    }

                    print("withSteam " + linkAccountBody.withSteam);
                    print("withOculus " + linkAccountBody.withOculus);
                    bodyLoader.setSource("LoggingInBody.qml", { "loginDialog": loginDialog, "root": root, "bodyLoader": bodyLoader,
                        "withSteam": linkAccountBody.withSteam, "withOculus": linkAccountBody.withOculus, "fromBody": "LinkAccountBody" });
                }
                Component.onCompleted: {
                    if (loginDialog.isOculusStoreRunning()) {
                        continueButton.text = qsTr("CONTINUE WITH OCULUS");
                        continueButton.buttonGlyph = hifi.glyphs.oculus;
                    } else if (loginDialog.isSteamRunning()) {
                        continueButton.text = qsTr("CONTINUE WITH STEAM");
                        continueButton.buttonGlyph = hifi.glyphs.steamSquare;
                    } else {
                        continueButton.visible = false;
                    }

                }
            }
            Item {
                id: signUpContainer
                width: emailField.width
                height: emailField.height

                anchors {
                    left: emailField.left
                    bottom: parent.bottom
                    bottomMargin: 0.25 * parent.height
                }
                TextMetrics {
                    id: signUpTextMetrics
                    font: signUpText.font
                    text: signUpText.text
                }
                Text {
                    id: signUpText
                    text: qsTr("Don't have an account?")
                    anchors {
                        left: parent.left
                    }
                    lineHeight: 1
                    color: "white"
                    font.family: linkAccountBody.fontFamily
                    font.pixelSize: 18
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                HifiStylesUit.ShortcutText {
                    id: signUpShortcutText
                    z: 10
                    font.family: linkAccountBody.fontFamily
                    font.pixelSize: 18
                    anchors {
                         left: signUpText.right
                         leftMargin: hifi.dimensions.contentSpacing.x
                    }

                    text: "<a href='https://highfidelity.com'>Sign Up</a>"

                    linkColor: hifi.colors.blueAccent
                    onLinkActivated: {
                        Tablet.playSound(TabletEnums.ButtonClick);
                        bodyLoader.setSource("SignUpBody.qml", { "loginDialog": loginDialog, "root": root, "bodyLoader": bodyLoader,
                            "errorString": "" });
                    }
                }
            }
        }
        Item {
            id: dismissTextContainer
            width: dismissText.width
            height: dismissText.height
            anchors {
                bottom: parent.bottom
                right: parent.right
                margins: 3 * hifi.dimensions.contentSpacing.y
            }
            Text {
                id: dismissText
                text: qsTr("No thanks, take me in-world! >")

                lineHeight: 1
                color: "white"
                font.family: linkAccountBody.fontFamily
                font.pixelSize: 20
                font.bold: linkAccountBody.fontBold
                lineHeightMode: Text.ProportionalHeight
                horizontalAlignment: Text.AlignHCenter
            }
            MouseArea {
                id: dismissMouseArea
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                hoverEnabled: true
                onEntered: {
                    Tablet.playSound(TabletEnums.ButtonHover);
                }
                onClicked: {
                    Tablet.playSound(TabletEnums.ButtonClick);
                    if (loginDialog.getLoginDialogPoppedUp()) {
                        console.log("[ENCOURAGELOGINDIALOG]: user dismissed login screen")
                        var data = {
                            "action": "user dismissed login screen"
                        };
                        UserActivityLogger.logAction("encourageLoginDialog", data);
                        loginDialog.dismissLoginDialog();
                    }
                    root.tryDestroy();
                }
            }
        }
    }

    Component.onCompleted: {
        //but rise Tablet's one instead for Tablet interface
        root.keyboardEnabled = HMD.active;
        root.keyboardRaised = Qt.binding( function() { return keyboardRaised; })
        root.text = "";
        d.resize();
        init();
        emailField.focus = true;
    }

    Keys.onPressed: {
        if (!visible) {
            return;
        }

        switch (event.key) {
            case Qt.Key_Enter:
            case Qt.Key_Return:
                event.accepted = true;
                Settings.setValue("keepMeLoggedIn/savedUsername", emailField.text);
                linkAccountBody.login();
                break;
        }
    }
}

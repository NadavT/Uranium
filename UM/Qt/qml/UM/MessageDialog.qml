//Copyright (c) 2022 Ultimaker B.V.
//Uranium is released under the terms of the LGPLv3 or higher.

import QtQuick 2.15
import QtQuick.Controls 2.15

import UM 1.5 as UM

/*
* A small dialog that shows a message to the user, and provides several options on how to proceed.
*
* This functions as a normal dialog with its standard buttons, but also allows defining a text to show in the dialog.
*/
Dialog
{
    /*
    Other properties you might want to set from Dialog itself:
    - title
    - standardButtons
    - onAccepted
    - onRejected
    */
    id: root

    property alias text: content.text //The text to show in the body of the dialogue.

    width: UM.Theme.getSize("small_popup_dialog").width

    property alias buttonSpacing: buttonsRow.spacing
    property alias buttonPadding: buttonsRow.padding

    // Overlay.overlay holds the "window overlay item"; the window container
    // https://doc.qt.io/qt-5/qml-qtquick-controls2-overlay.html#overlay-attached-prop
    anchors.centerIn: Overlay.overlay

    modal: true

    contentItem: UM.Label
    {
        onLinkActivated: function(link)
        {
            Qt.openUrlExternally(link)
        }
        id: content
    }

    // the primaryButton and secondaryButtons are the components used to display the standard buttons
    // the default button (the button-action that gets actived when the return key is pressed) is rendered using the
    // primary button all other buttons are secondary buttons
    property Component primaryButton: Button
    {
        highlighted: true
        text: model.text
    }

    property Component secondaryButton: Button
    {
        text: model.text
    }

    // Change the buttonsModel in the event that the standardButtons property changes
    Connections {
        target: root
        onStandardButtonsChanged: buttonsModel.update()
    }

    property int defaultAction: 0;

    ListModel
    {
        id: buttonsModel

        // All possible buttons with i18n translated copy
        // Order of these buttons is importatant; sub set of buttons to be displayed are added from right to left
        // in the bottom right of the dialog. The first of these button gets the role of "default button"
        property var buttons: [
            { standardButton: Dialog.Ok, text: catalog.i18nc("@option", "OK") },
            { standardButton: Dialog.Open, text: catalog.i18nc("@option", "Open") },
            { standardButton: Dialog.Save, text: catalog.i18nc("@option", "Save") },
            { standardButton: Dialog.Cancel, text: catalog.i18nc("@option", "Cancel") },
            { standardButton: Dialog.Close, text: catalog.i18nc("@option", "Close") },
            { standardButton: Dialog.Discard, text: catalog.i18nc("@option", "Discard") },
            { standardButton: Dialog.Apply, text: catalog.i18nc("@option", "Apply") },
            { standardButton: Dialog.Reset, text: catalog.i18nc("@option", "Reset") },
            { standardButton: Dialog.RestoreDefaults, text: catalog.i18nc("@option", "Restore Defaults") },
            { standardButton: Dialog.Help, text: catalog.i18nc("@option", "Help") },
            { standardButton: Dialog.SaveAll, text: catalog.i18nc("@option", "Save All") },
            { standardButton: Dialog.Yes, text: catalog.i18nc("@option", "Yes") },
            { standardButton: Dialog.YesToAll, text: catalog.i18nc("@option", "Yes to All") },
            { standardButton: Dialog.No, text: catalog.i18nc("@option", "No") },
            { standardButton: Dialog.NoToAll, text: catalog.i18nc("@option", "No to All") },
            { standardButton: Dialog.Abort, text: catalog.i18nc("@option", "Abort") },
            { standardButton: Dialog.Retry, text: catalog.i18nc("@option", "Retry") },
            { standardButton: Dialog.Ignore, text: catalog.i18nc("@option", "Ignore") }
        ]

        Component.onCompleted: update()

        function update()
        {
            clear();

            // reset the default action
            root.defaultAction = 0;

            for (let i = 0; i < buttons.length; i ++)
            {
                const button = buttons[i];
                if (root.standardButtons & button.standardButton)
                {
                    append(button);

                    // if default action is not set, set it
                    if (root.defaultAction == 0)
                    {
                        root.defaultAction = button.standardButton;
                    }
                }
            }
        }
    }

    // Key press doens't work as of yet
    // https://forum.qt.io/topic/114405/messagedialog-responsive-to-keyboard-events/4
    Keys.onReturnPressed: root.click(root.defaultAction)

    // map each standard button type to an action
    // https://doc.qt.io/qt-5/qml-qtquick-controls2-dialogbuttonbox.html#details
    function click(standardButton)
    {
        switch (button.standardButton)
        {
            case Dialog.Ok:
            case Dialog.Open:
            case Dialog.Save:
            case Dialog.SaveAll:
            case Dialog.Yes:
            case Dialog.YesToAll:
            case Dialog.Retry:
            case Dialog.Ignore:
                root.accepted();
                break;

            case Dialog.Cancel:
            case Dialog.Close:
                root.rejected();
                break;

            case Dialog.Discard:
                root.discarted();
                break;

            case Dialog.Apply:
                root.applied();
                break;

            case Dialog.Reset:
            case Dialog.RestoreDefaults:
                root.reset();
                break;

            case Dialog.Help:
                root.helpRequested();
                break;

            case Dialog.No:
            case Dialog.NoToAll:
            case Dialog.Abort:
                root.rejected();
                break;
        }

        // close the dialog after a click event
        root.close();
    }

    footer: Row
    {
        id: buttonsRow
        spacing: UM.Theme.getSize("default_margin").width
        padding: UM.Theme.getSize("default_margin").width

        layoutDirection: Qt.RightToLeft
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        Repeater
        {
            model: buttonsModel

            delegate: Item
            {
                height: childrenRect.height
                width: childrenRect.width

                Loader
                {
                    sourceComponent: index == 0 ? root.primaryButton : root.secondaryButton
                    onLoaded:
                    {
                        item.text = text;
                    }
                }

                MouseArea
                {
                    anchors.fill: parent
                    onClicked: root.click(standardButton)
                }
            }
        }
   }
}
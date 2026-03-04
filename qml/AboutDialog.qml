import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: aboutDialog
    title: qsTr("Acerca de Generador SHA")
    modal: true
    standardButtons: Dialog.Ok

    contentItem: ColumnLayout {
        spacing: 15
        width: 350

        Label {
            id: aboutTextLabel
            text: qsTr("Cargando...")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.minimumWidth: 300
        }
    }

    // Leemos el archivo usando el bridge seguro de C++
    onOpened: {
        aboutTextLabel.text = shaController.readAboutText();
    }
}

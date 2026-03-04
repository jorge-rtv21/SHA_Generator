import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
    id: window
    width: 650
    height: 480
    visible: true
    title: qsTr("Generador SHA")
    color: "#f0f2f5"

    menuBar: MenuBar {
        Menu {
            title: qsTr("&Ayuda")
            MenuItem {
                text: qsTr("Acerca de...")
                onTriggered: aboutDialog.open()
            }
        }
    }

    AboutDialog {
        id: aboutDialog
        anchors.centerIn: parent
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Seleccione un archivo")
        onAccepted: {
            selectedFileField.text = fileDialog.selectedFile
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 15

        Label {
            text: qsTr("Calculadora de Hashes Criptográficos")
            font.pixelSize: 22
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 10
            color: "#333333"
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            TextField {
                id: selectedFileField
                Layout.fillWidth: true
                placeholderText: qsTr("Ningún archivo seleccionado...")
                readOnly: true
                color: "#555"
            }

            Button {
                text: qsTr("Examinar...")
                onClicked: fileDialog.open()
                enabled: !shaController.isProcessing
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: qsTr("Algoritmo de Hash:")
                font.bold: true
            }

            ComboBox {
                id: algoCombo
                Layout.fillWidth: true
                model: ["MD5", "SHA-1", "SHA-224", "SHA-256", "SHA-384", "SHA-512"]
                currentIndex: 3 // SHA-256 preseleccionado
                enabled: !shaController.isProcessing
            }
        }

        ProgressBar {
            id: progressBar
            Layout.fillWidth: true
            from: 0
            to: 100
            value: shaController.progress
            visible: shaController.isProcessing
        }

        Label {
            text: shaController.statusMessage
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: "#0066cc"
            font.italic: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: "#ffffff"
            border.color: "#cccccc"
            border.width: 1
            radius: 6

            TextInput {
                anchors.fill: parent
                anchors.margins: 10
                text: shaController.hashResult
                readOnly: true
                selectByMouse: true
                wrapMode: TextInput.WrapAnywhere
                font.family: "Consolas"
                font.pixelSize: 15
                verticalAlignment: TextInput.AlignVCenter
                color: "#111111"
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            spacing: 20

            Button {
                text: qsTr("Calcular Hash")
                highlighted: true
                enabled: selectedFileField.text !== "" && !shaController.isProcessing
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                onClicked: {
                    shaController.calculateSha(selectedFileField.text, algoCombo.currentIndex)
                }
            }

            Button {
                text: qsTr("Guardar en Archivo")
                enabled: shaController.hashResult !== "" && !shaController.isProcessing
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                onClicked: {
                    shaController.saveShaToFile(selectedFileField.text, shaController.hashResult, algoCombo.currentIndex)
                }
            }
        }
        
        Item {
            // Spacer para empujar todo hacia arriba
            Layout.fillHeight: true
        }
    }
}

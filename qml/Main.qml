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

    Component.onCompleted: {
        shaController.checkForUpdates()
    }

    Connections {
        target: shaController
        function onUpdateAvailable(newVersion, downloadUrl) {
            updateBanner.versionText = newVersion
            updateBanner.downloadUrl = downloadUrl
            updateBanner.visible = true
            updateBanner.downloading = false
            updateBanner.progressValue = 0
            updateBanner.statusText = ""
        }
        function onUpdateDownloadProgress(percent) {
            updateBanner.progressValue = percent
        }
        function onUpdateDownloadFinished(success, message) {
            updateBanner.downloading = false
            updateBanner.statusText = message
        }
    }

    header: Rectangle {
        id: updateBanner
        width: parent.width
        height: 65
        color: "#fff3cd"
        visible: false
        border.color: "#ffeeba"
        border.width: 1
        
        property string versionText: ""
        property string downloadUrl: ""
        property bool downloading: false
        property int progressValue: 0
        property string statusText: ""
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15
                Label {
                    text: updateBanner.statusText !== "" ? updateBanner.statusText : (qsTr("¡Nueva versión disponible! (") + updateBanner.versionText + qsTr(")"))
                    color: "#856404"
                    font.bold: true
                    font.pixelSize: 13
                }
                Button {
                    text: updateBanner.downloading ? (updateBanner.progressValue + "%") : (updateBanner.statusText !== "" ? qsTr("Cerrar") : qsTr("Actualizar Automáticamente"))
                    enabled: !updateBanner.downloading
                    height: 30
                    visible: true
                    onClicked: {
                        if (updateBanner.statusText !== "") {
                            updateBanner.visible = false
                        } else {
                            updateBanner.downloading = true
                            shaController.downloadUpdate(updateBanner.downloadUrl)
                        }
                    }
                }
                Button {
                    text: qsTr("✕")
                    flat: true
                    width: 30
                    height: 30
                    visible: !updateBanner.downloading && updateBanner.statusText === ""
                    onClicked: updateBanner.visible = false
                }
            }
            
            ProgressBar {
                Layout.fillWidth: true
                Layout.preferredWidth: 350
                from: 0
                to: 100
                value: updateBanner.progressValue
                visible: updateBanner.downloading
            }
        }
    }

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

    // Fondo interactivo para Drag & Drop
    Rectangle {
        id: dropBackground
        anchors.fill: parent
        color: dropArea.containsDrag ? "#e6f7ff" : "transparent"
        border.color: dropArea.containsDrag ? "#0066cc" : "transparent"
        border.width: 3
        z: -1
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        
        onEntered: (drag) => {
            if (drag.hasUrls) {
                drag.accept()
            }
        }
        
        onDropped: (drop) => {
            if (drop.hasUrls && drop.urls.length > 0) {
                let cleanPath = shaController.cleanDropUrl(drop.urls[0])
                selectedFileField.text = cleanPath
                // Auto-iniciar si no está procesando nada
                if (!shaController.isProcessing) {
                    shaController.calculateSha(cleanPath, algoCombo.currentIndex)
                }
            }
        }
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
                placeholderText: qsTr("Arrastra o selecciona un archivo...")
                readOnly: true
                color: "#555"
                text: typeof initialFilePath !== "undefined" ? initialFilePath : ""
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
        
        // --- SECCIÓN: VERIFICADOR DE HASHES ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#d0d0d0"
            Layout.topMargin: 5
            Layout.bottomMargin: 5
        }

        Label {
            text: qsTr("Verificación (Opcional):")
            font.bold: true
            Layout.topMargin: 5
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            TextField {
                id: targetHashField
                Layout.fillWidth: true
                placeholderText: qsTr("Pegue aquí un Hash para verificar su autenticidad...")
                font.family: "Consolas"
                color: "#111111"
                
                // Dispara validación en vivo mientras el usuario pega o borra, o al terminar
                onTextChanged: shaController.verifyHash(text)
            }

            Rectangle {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 35
                radius: 4
                color: targetHashField.text === "" ? "#e0e0e0" : (shaController.isHashValid ? "#d4edda" : "#f8d7da")
                border.color: targetHashField.text === "" ? "#cccccc" : (shaController.isHashValid ? "#c3e6cb" : "#f5c6cb")

                Label {
                    anchors.centerIn: parent
                    text: targetHashField.text === "" ? qsTr("Sin comparar") : (shaController.isHashValid ? qsTr("✔ COINCIDE") : qsTr("✖ NO COINCIDE"))
                    font.bold: true
                    color: targetHashField.text === "" ? "#666666" : (shaController.isHashValid ? "#155724" : "#721c24")
                }
            }
        }
        
        Item {
            // Spacer para empujar todo hacia arriba
            Layout.fillHeight: true
        }
    }
}

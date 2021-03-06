import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.3

import IRQtModules 1.0 as IRQM

import "../components" as Comp

Window {
    id: container
    visible: true
    width: 640
    height: 480
    title: "MMRClient"

    property var clientIdentifiers: []

    property var componentsOfModalityTypes: ({
        "mmrdata": componentModalityMMRData,
        "kinect": componentModalityKinect,
        "qtsensor": componentModalityQtSensor,
        "bitalino": componentModalityBITalino,
        "fitbit": componentModalityFitbit
    })

    property bool isMMRDataLoaded: false
    property ComboBox fileModalityListComboBox

    property TextArea logTextArea

    Component.onCompleted: {
        IRQM.SignalHandler.bindSignal("main", "log", this, "log");

        IRQM.SignalHandler.bindSignal("main", "destroyClient", this, "destroyClient");

        IRQM.SignalHandler.bindSignal("main", "mmrDataLoaded", this, "slotMMRDataLoaded");
        IRQM.SignalHandler.bindSignal("main", "mmrDataUnloaded", this, "slotMMRDataUnloaded");
    }

    Component.onDestruction: {
        IRQM.SignalHandler.unbindAllSignalsForSlot(this);
    }

    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function log(text) {
        logTextArea.append(text);
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function createClient(modality) {
        var identifier = qMain.createClient(modality);
        if (!identifier) return;

        var text = modality["text"];
        var type = modality["type"];

        var tabObject = tabView.addTab(text);
        tabObject.anchors.fill = Qt.binding(function() { return tabObject.parent; });

        clientIdentifiers.push(identifier);

        var modalityObject = componentsOfModalityTypes[type].createObject(tabObject);
        if (!modalityObject) return;

        modalityObject.title = text;
        modalityObject.identifier = identifier;

        modalityObject.initialize();

        tabView.currentIndex = tabView.count - 1;
    }
    //---------------------------------------------------------------------------
    function createMMRDataClient(modalityInfo) {
        var identifier = qMain.createMMRDataClient(modalityInfo);
        if (!identifier) return;

        var text = "MMRData";

        var tabObject = tabView.addTab(text);
        tabObject.anchors.fill = Qt.binding(function() { return tabObject.parent; });

        clientIdentifiers.push(identifier);

        var modalityObject = componentsOfModalityTypes["mmrdata"].createObject(tabObject);
        if (!modalityObject) return;

        modalityObject.title = text;
        modalityObject.identifier = identifier;

        modalityObject.initialize();

        tabView.currentIndex = tabView.count - 1;
    }
    //---------------------------------------------------------------------------
    function destroyClient(identifier) {
        var tabIndex = clientIdentifiers.indexOf(identifier) + 1;
        if (tabIndex <= 0) return;

        console.log("destroyClient");
        console.log(identifier);

        qMain.destroyClient(identifier);
        tabView.removeTab(tabIndex);

        clientIdentifiers.splice(tabIndex, 1);
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------
    function slotMMRDataLoaded() {
        isMMRDataLoaded = true;

        fileModalityListComboBox.updateList();
    }
    //---------------------------------------------------------------------------
    function slotMMRDataUnloaded() {
        isMMRDataLoaded = false;
    }
    //---------------------------------------------------------------------------
    //---------------------------------------------------------------------------

    Component {
        id: componentModalityMMRData
        ModalityMMRDataPage {}
    }
    Component {
        id: componentModalityKinect
        ModalityKinectPage {}
    }
    Component {
        id: componentModalityQtSensor
        ModalityQtSensorPage {}
    }
    Component {
        id: componentModalityBITalino
        ModalityBITalinoPage {}
    }
    Component {
        id: componentModalityFitbit
        ModalityFitbitPage {}
    }

    SplitView {
        anchors.fill: parent
        orientation: Qt.Vertical

        TabView {
            id: tabView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 8

            Tab {
                id: mainTab
                anchors.fill: parent
                title: "Main"

                ScrollView {
                    id: mainScrollView
                    anchors.fill: parent
                    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
                    verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn

                    Comp.Flickable {
                        id: mainFlickable
                        anchors.fill: parent
                        anchors.margins: 8

                        ColumnLayout {
                            width: mainFlickable.width
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "New modality: "
                                }
                                ComboBox {
                                    id: newModalityComboBox
                                    Layout.fillWidth: true
                                    model: []

                                    property var modalities: []

                                    Component.onCompleted: {
                                        modalities = qMain.getAvailableModalities();

                                        var modelTextList = [];
                                        for (var i in modalities) {
                                            var modality = modalities[i];
                                            modelTextList.push(modality["text"]);
                                        }

                                        model = modelTextList;
                                    }
                                }
                                Button {
                                    text: "Add"

                                    onClicked: {
                                        if (newModalityComboBox.currentIndex < 0) return;
                                        var modality = newModalityComboBox.modalities[newModalityComboBox.currentIndex];
                                        container.createClient(modality);
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: "Load from file: "
                                }
                                Button {
                                    id: mmrPathBrowseButton
                                    text: "Browse"
                                    enabled: !container.isMMRDataLoaded

                                    Component.onCompleted: {
                                    }
                                    onClicked: {
                                        openDialog.open();
                                    }

                                    FileDialog {
                                        id: openDialog
                                        nameFilters: ["mmr.sqlite"]

                                        onAccepted: {
                                            var path = fileUrl.toString();
                                            if (path.startsWith("file:///")) {
                                                path = path.replace(/^(file:\/{3})/, "");
                                            }
                                            else if (path.startsWith("file:")) {
                                                path = path.replace(/^(file:)/, "");
                                            }
                                            path = path.replace(/mmr\.sqlite$/, "");
                                            path = decodeURIComponent(path);

                                            qMain.loadMMRData(path);
                                            log("Load MMR file: " + path);
                                        }
                                    }
                                }
                                ComboBox {
                                    id: fileModalityListComboBox
                                    Layout.fillWidth: true
                                    model: []

                                    property var modalities: []

                                    Component.onCompleted: {
                                        container.fileModalityListComboBox = this;
                                    }

                                    function updateList() {
                                        modalities = qMain.getMMRModalities();

                                        var modelTextList = [];
                                        for (var i in modalities) {
                                            var modality = modalities[i];
                                            modelTextList.push(modality["type"] + " (" + modality["identifier"] + ")");
                                        }

                                        model = modelTextList;
                                    }
                                }
                                Button {
                                    text: "Add"
                                    enabled: container.isMMRDataLoaded

                                    onClicked: {
                                        if (fileModalityListComboBox.currentIndex < 0) return;
                                        var modalityInfo = fileModalityListComboBox.modalities[fileModalityListComboBox.currentIndex];
                                        container.createMMRDataClient(modalityInfo);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        TextArea {
            id: logTextArea
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            Layout.margins: 8
            wrapMode: TextEdit.Wrap
            readOnly: true
            text: "MultiModalRecorderClient (v" + qMain.getAppVersionString() + ")"

            Component.onCompleted: {
                container.logTextArea = logTextArea
            }
        }
    }
}

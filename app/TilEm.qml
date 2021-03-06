import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Utils 1.0
import QtQuick.Window 2.2

Window {
    id: window
    width: units.gu(40)
    height: units.gu(70)

    visibility: calcPage.fullscreen ? Window.FullScreen : Window.AutomaticVisibility

    property string appDir: {
        var home = Env.readEnvVar("XDG_DATA_HOME")
        if(home == "") {
            home = Env.readEnvVar("HOME") + "/.local/share"
        }

        var appPkgName = Env.readEnvVar("APP_ID").split('_')[0]
        if(appPkgName == "") {
            appPkgName = "TilEm"
        }

        var appDir = home + "/" + appPkgName
        print("appDir: " + appDir)
        return appDir
    }

    MainView {
        id: mainView
        anchors.fill: parent

        property var ct // ContentTransfer
        objectName: "mainView"

        // Note! applicationName needs to match the "name" field of the click manifest
        applicationName: "com.ubuntu.developer.labsin.tilem"



        Component {
            id: pickerComponent

            PopupBase {
                id: picker

                ContentPeerPicker {
                    id: peerPicker
                    contentType: ContentType.Documents
                    handler: ContentHandler.Source
                    anchors.fill: parent
                    visible: true

                    onPeerSelected: {
                        ct = peer.request(contentStore)
                        PopupUtils.close(picker)
                    }

                    onCancelPressed: {
                        PopupUtils.close(picker)
                    }
                }
            }
        }

        ContentStore {
            id: contentStore
            scope: ContentScope.App
            onUriChanged: print("Store, uri changed: " + contentStore.uri)
        }

        ContentTransferHint {
            id: importHint
            anchors.fill: parent
            activeTransfer: ct
        }

        Connections {
            target: ct
            onStateChanged: {
                print("ct state " + ct.state)
                print("ContentTransfer.Created\t" + ContentTransfer.Created)
                print("ContentTransfer.Initiated\t" + ContentTransfer.Initiated)
                print("ContentTransfer.InProgress\t" + ContentTransfer.InProgress)
                print("ContentTransfer.Charged\t" + ContentTransfer.Charged)
                print("ContentTransfer.Collected\t" + ContentTransfer.Collected)
                print("ContentTransfer.Aborted\t" + ContentTransfer.Aborted)
                print("ContentTransfer.Finalized\t" + ContentTransfer.Finalized)
                print("ContentTransfer.Downloading\t" + ContentTransfer.Downloading)
                print("ContentTransfer.Downloaded\t" + ContentTransfer.Downloaded)
            }
        }

        AdaptivePageLayout {
            id: apl
            anchors.fill: parent
            primaryPage: folderPage

            FolderPage {
                id: folderPage
                anchors.fill: parent
                onRequest: {
                    PopupUtils.open(pickerComponent)
                }
                onLoadRomFile: {
                    apl.addPageToNextColumn(apl.primaryPage, calcPage)
                    calcPage.romFile = romFile
                }
            }

            CalcPage {
                id: calcPage
            }
        }
    }
}

//#import VPlay 2.0
import QtQuick 2.7
import QtQuick.Window 2.2
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1

import "./scenes"
import "./common"

ApplicationWindow {
    id:root
    //AW: Duplication vs SceneBase - need to fix
    property real default_pix_density: 4  //pixel density of my current screen
    property real scale_factor: {
        var sfDen   = Screen.pixelDensity/default_pix_density
        var sfWidth = Screen.width / 1080
        var sfHeight  = Screen.height / 1776
        return Math.min(/*sfDen, */sfWidth, sfHeight)
    }
    property int firstTime:1
    function dp(pix){
        if (firstTime){
            console.log("Screen.pixelDensity = ", Screen.pixelDensity, "scale_factor = ", scale_factor)
            firstTime = 0
        }
        return pix * scale_factor
    }
    //Is set, when RunSessionScene is loaded
    property int typesDim
    visible:true
    //for some reason dp(1920) created binding loop and dependence of NONNotifiable factor
    height: Screen.height
    width: Screen.height > Screen.width ? Screen.width : Screen.height * 9/16
    header:TabBar {
        id: tabView
        position:TabBar.Header
        //anchors.fill: parent
        //anchors.margins: 4
        background: Rectangle {
            color: tabView.enabled ? "steelblue" :"lightsteelblue"
            border.color:  "steelblue"
            border.width: dp(4)
            implicitWidth: Math.max(text.width + dp(20), dp(100))
            implicitHeight: dp(100)
            radius: dp(4)
            Text {
                id: text
                anchors.centerIn: parent
                //text: styleData.title
                //color: styleData.selected ? "white" : "black"
            }
        }
        Component.onCompleted:  {
            //those 2 functions provide different functionslity
            conf.sessionSelected.connect( run.setupSession);
            conf.sessionSelected.connect(run.currentHrPlot.setupSession)
            hrm.startHrmDemo.connect(run.currentHrPlot.demoHrm)
            hrm.startHrmSearch.connect(run.currentHrPlot.realHrm)
        }
        //style: TabViewStyle {
            //frameOverlap: dp(0)
//            frame:     Image {
//                //z:90
//                id: bkgImg
//                source: "../../assets/img/surface.png"
//                fillMode: Image.PreserveAspectCrop
//                opacity: 0.4
//                anchors.fill: parent
//            }

        TabButton { id: confTab; text: qsTr("Conf")}
        TabButton { id: runTab; text: qsTr("Run")}
        TabButton { id: hrmTab; text: qsTr("HRM")}
        TabButton { id: browseResTab; text: qsTr("Browse")}
        TabButton { id: aboutTab; text: qsTr("About")}
        TabButton { id: finishTab; text: qsTr("Finish")}
    }
    StackLayout {
        id:stackLayout
        width: parent.width
        currentIndex: tabView.currentIndex

        ConfigSeriesScene{ id:conf; }
        RunSessionScene{ id:run;    }
        HrmSetupScene{  id:hrm;     }
        BrowseResultsScene{  id:browseRes; }
        AboutScene{  id:about;      }
        SceneBase {
            z:100
            id:finish;
            width: root.width
            height: root.height
            visible:true
            //anchors.leftMargin: dp(20)
            //Text {text:qsTr("Finish")}
            Item {
                id: quit
                visible:true
                anchors.fill: parent
                MenuButton{
                    z:100
                    id:quitButton
                    width:parent.width/3
                    height: parent.height/3
                    border.width: dp(4)
                    border.color: "black"
                    text: qsTr("Quit")
                    anchors.centerIn: parent
                    onClicked: {
                        heartRate.disconnectService();
                        Qt.quit()
                    }
                }
            }
        }
    }
    Loader {
        id: pageLoader
        anchors.fill: parent
    }
}



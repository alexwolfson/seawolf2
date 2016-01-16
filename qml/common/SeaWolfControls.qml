import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtMultimedia 5.0
import VPlay 2.0

CircularGauge {
    id: gauge
    property real valueChange: 0
    value: 0
    anchors.verticalCenter: parent.verticalCenter
    property string gaugeName: "brth"
    property  SoundEffectVPlay enterStateSndEffect
    property GridView gridView
    property ListModel gaugeModel: gridView.model
    property CircularGauge nextGauge
    //property var gaugeModelElement: gaugeModel.get(modelIndex)
    property bool isCurrent: false
    property real minAngle: -45
    property real maxAngle:  45
    property color needleColor: runColors[gaugeName]
    property int modelIndex:0
    property int maximumValue: gaugeModel.get(modelIndex).time
    onModelIndexChanged:{gaugeModel.get(modelIndex).time}
    style: CircularGaugeStyle {
        id: gaugeStyle
        minimumValueAngle: gauge.minAngle
        maximumValueAngle: gauge.maxAngle
        labelStepSize: ((maximumValue - minimumValue) /8 + 0.5).toFixed()
        tickmarkStepSize: labelStepSize
        minorTickmarkCount: 1
        function toPixels(percentage) {
            return percentage * outerRadius;
        }
        needle: Rectangle {
            id: gaugeNeedle
            property color needleColor: color
            y: outerRadius * 0.15
            implicitWidth: outerRadius * 0.03
            implicitHeight: outerRadius * 0.9
            antialiasing: true
            color: gauge.needleColor
        }
        tickmark: Rectangle {
            implicitWidth: toPixels(0.06)
            antialiasing: true
            implicitHeight: toPixels(0.06)
            color: gauge.needleColor
            border.color: "black"
        }
        minorTickmark: Rectangle{
            implicitWidth: toPixels(0.03)
            antialiasing: true
            implicitHeight: toPixels(0.08)
            color: gauge.needleColor
            border.color: "black"
        }
        tickmarkLabel: Text {
            color: "white"
            text: styleData.value
            style: Text.Outline
            styleColor: gauge.needleColor
        }
    }
    SoundEffectVPlay {
            id: thirtysnd
            volume: 1.0
            source: "../../assets/sounds/30sec.wav"
    }
    SoundEffectVPlay {
            id: tensnd
            volume: 1.0
            source: "../../assets/sounds/10sec.wav"
    }
    states:[
        State {
            name: "stateRun"
            //when: isCurrent
            PropertyChanges {
                target: gauge
                value: maximumValue
                isCurrent: true
            }
        },
        State {
            name: "initial"
            //when: !isCurrent
            PropertyChanges {
                target: gauge
                value: 0
                isCurrent: false
            }
        }
    ]
    Timer{
        id: thirtyTimer
        interval:30000
        onTriggered:{
                //when timer expired set it to 20 sec to play 10 sec left
                thirtysnd.play()
        }
    }
    Timer{
        id: tenTimer
        interval:20000
        onTriggered:{
            tensnd.play()
        }
    }
    function isLastInCycle(){
        if (nextGauge.modelIndex % 3 ===  0)
            return true
        else
            return false
    }
    //trick to pass by reference
    function loadNextCycle(gauge){
       if ((gauge[0].modelIndex + 3 < gaugeModel.count))
        {
            gauge[0].modelIndex += 3;
            //gauge[0].maximumValue = gaugeModel.get(gauge[0].modelIndex).time

        }
   }
    function loadIfNot0(gauge, ind){
        //if (gauge[0] !== 0){
            gauge[0].modelIndex = ind
            //gauge[0].maximumValue = gaugeModel.get(gauge[0].modelIndex).time
        //}
    }

    transitions:[
        Transition {
            from: "*"
            to: "stateRun"
            // SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
            NumberAnimation{
                target: gauge
                property: "value"
                duration: Math.abs(maximumValue - gauge.value) * 1000
            }
            onRunningChanged: {
                // the step is over - go to the next step
                if (running){
                    thirtyTimer.interval= maximumValue * 1000 - 30000
                    if (thirtyTimer.interval > 0){
                        thirtyTimer.start()
                    }
                    tenTimer.interval = maximumValue * 1000 - 10000
                    if (tenTimer.interval > 0){
                        tenTimer.start()
                    }
                    enterStateSndEffect.play()
                 }

                if ((!running) /*&& (gaugeModelElement.typeName === gaugeName)*/) {
                    //console.log("running=", running, "modelIndex=", modelIndex, "index=", gridView.delegate.index)
                    state = "initial";
                    gaugeModel.get(modelIndex).isCurrent = false
                    // update 3 gauges if we are about to run the "breath"gauge
                    var bContinue = true
                    if (isLastInCycle()){
                        loadNextCycle([gauge])
                        var prevNextModelIndex = nextGauge.modelIndex
                        console.log("prevNextModelIndex=", prevNextModelIndex)
                        loadNextCycle([nextGauge])
                        console.log("******nextGauge.modelIndex=", nextGauge.modelIndex)
                        if (prevNextModelIndex === nextGauge.modelIndex) bContinue = false
                        loadNextCycle([nextGauge.nextGauge])
                    }
                    console.log("bContinue=", bContinue)
                    //var nextActiveGauge = nextGauge.maximumValue != 0 ? nextGauge : nextGauge.nextGauge
                    if ((nextGauge.modelIndex < gaugeModel.count) && bContinue){
                        //nextGauge.modelIndex = modelIndex + 1
                        //skip the next gauge if it has 0 maximum value
                        gaugeModel.get(nextGauge.modelIndex).isCurrent = true
                        //seting up next gauge as current if it's time is not 0
                        nextGauge.state = "stateRun"
                    }
                    else {
                        loadIfNot0([nextGauge], 0)
                        loadIfNot0([nextGauge.nextGauge], 1)
                        loadIfNot0([nextGauge.nextGauge.nextGauge], 2)

                    }
                }
                // we are here as part of the transaction to running, so in case of next serie
                // we change all times!
            }
        },
        Transition {
            from: "*"
            to: "initial"
             NumberAnimation{
                target: gauge
                property: "value"
                duration: 1000
            }
        }
    ]
    //Behavior on value { NumberAnimation { duration: gauge.valueChange * 1000 } }
    //style: IntervalGaugeStyle {}
}

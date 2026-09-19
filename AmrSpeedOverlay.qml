import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// AMR engineering instrument – premium, restrained, motorsport.
// Dark British racing green / almost-black / white numbers / tiny lime highlight. No neon.

PanelWindow {
  id: root

  required property string fontFamily
  required property bool running
  required property string leftLabel
  required property string rightLabel
  property string unit: "Mbps"
  property string title: ""
  property string layerNamespace: "omarchy-speed-test"
  property string runAgainTooltip: "Measure again"
  property real leftValue: 0
  property real rightValue: 0
  property bool leftLive: false
  property bool rightLive: false
  property string error: ""
  property bool open: false
  property string amrHeader: "AMR // NETWORK"
  property var scaleStops: [100, 250, 500, 1000, 2500, 5000, 10000]
  property real fullScale: scaleStops[0]

  signal closeRequested()
  signal runAgainRequested()

  readonly property bool failed: error !== ""
  function resetScale() { fullScale = scaleStops[0] }
  function expandScale(value) {
    for (var i = 0; i < scaleStops.length; i++) {
      if (value <= scaleStops[i] * 0.92) { if (scaleStops[i] > fullScale) fullScale = scaleStops[i]; return }
    }
    fullScale = scaleStops[scaleStops.length - 1]
  }
  onRunningChanged: if (running) resetScale()
  onScaleStopsChanged: resetScale()
  onLeftValueChanged: expandScale(leftValue)
  onRightValueChanged: expandScale(rightValue)
  Behavior on fullScale { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

  readonly property color onScrim: "white"
  readonly property color onScrimDim: Qt.rgba(1,1,1,0.50)
  readonly property color onScrimFaint: Qt.rgba(1,1,1,0.32)
  readonly property color onScrimUrgent: "#ff6b6b"
  // housing – dark glass mounted in dashboard
  readonly property color housingFill: Qt.rgba(0x06/255,0x0E/255,0x0C/255,0.56)
  readonly property color housingBorder: Qt.rgba(0x1D/255,0x38/255,0x31/255,0.34)
  readonly property color racingGreen: "#00352F"
  readonly property color lime: "#B7D635"

  visible: open
  onOpenChanged: {
    if (open) Qt.callLater(function() {
      if (!root.open) return
      keyCatcher.forceActiveFocus()
      leftDial.ignite(); rightDial.ignite()
    })
  }
  anchors { top: true; bottom: true; left: true; right: true }
  color: "transparent"
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.namespace: root.layerNamespace
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0x04/255,0x08/255,0x07/255,0.78)
    MouseArea { anchors.fill: parent; onClicked: root.closeRequested() }
  }

  Item {
    id: keyCatcher
    anchors.fill: parent
    focus: true
    Keys.onEscapePressed: root.closeRequested()
    Keys.onReturnPressed: if (!root.running) root.runAgainRequested()
    Keys.onEnterPressed: if (!root.running) root.runAgainRequested()

    Item {
      id: cluster
      anchors.centerIn: parent
      width: housing.implicitWidth
      height: housing.implicitHeight
      scale: Math.min(1, (keyCatcher.width - Style.space(32))/Math.max(1,width), (keyCatcher.height - Style.space(32))/Math.max(1,height))
      MouseArea { anchors.fill: parent; onClicked: {} }

      Rectangle {
        id: housing
        anchors.centerIn: parent
        implicitWidth: content.implicitWidth + Style.space(44)
        implicitHeight: content.implicitHeight + Style.space(28)
        color: root.housingFill
        border.color: root.housingBorder
        border.width: 1
        radius: 10

        // subtle carbon – almost invisible, not sci-fi
        Item {
          anchors.fill: parent; anchors.margins: 8; clip: true; opacity: 0.022
          Canvas {
            anchors.fill: parent
            onPaint: {
              var ctx=getContext("2d"); ctx.clearRect(0,0,width,height)
              ctx.strokeStyle="#C6D0CB"; ctx.lineWidth=0.5; var s=12
              for(var x=-height;x<width;x+=s){ ctx.beginPath(); ctx.moveTo(x,0); ctx.lineTo(x+height,height); ctx.stroke() }
              for(var y=-width;y<height;y+=s){ ctx.beginPath(); ctx.moveTo(0,y); ctx.lineTo(width,y+width); ctx.stroke() }
            }
          }
        }
        Rectangle { anchors.fill: parent; anchors.margins: 1; radius: parent.radius-1; color: "transparent"; border.color: Qt.rgba(1,1,1,0.04); border.width: 1 }

        // restrained thin corner ticks – not cyan
        Item { anchors.fill: parent
          Item{ x:10; y:10; width:10; height:10; Rectangle{ width:10; height:0.8; color: Qt.rgba(1,1,1,0.16) } Rectangle{ width:0.8; height:10; color: Qt.rgba(1,1,1,0.16)}}
          Item{ x:parent.width-20; y:10; width:10; height:10; Rectangle{ width:10; height:0.8; color: Qt.rgba(1,1,1,0.16)} Rectangle{ x:9.2; width:0.8; height:10; color: Qt.rgba(1,1,1,0.16)}}
          Item{ x:10; y:parent.height-20; width:10; height:10; Rectangle{ y:9.2; width:10; height:0.8; color: Qt.rgba(1,1,1,0.16)} Rectangle{ width:0.8; height:10; color: Qt.rgba(1,1,1,0.16)}}
          Item{ x:parent.width-20; y:parent.height-20; width:10; height:10; Rectangle{ y:9.2; width:10; height:0.8; color: Qt.rgba(1,1,1,0.16)} Rectangle{ x:9.2; width:0.8; height:10; color: Qt.rgba(1,1,1,0.16)}}
        }

        ColumnLayout {
          id: content
          anchors.centerIn: parent
          spacing: Style.space(14)

          // Header – restrained: left AMR // NETWORK, right tiny AMR mark
          RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.space(14)
            Layout.rightMargin: Style.space(14)
            spacing: Style.space(12)
            Text {
              textFormat: Text.PlainText
              text: root.amrHeader
              color: Qt.rgba(1,1,1,0.38)
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 3.0
              Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            }
            Item { Layout.fillWidth: true }
            Row {
              spacing: Style.space(6)
              Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
              // tiny wing – understated, not logo repeat
              Shape {
                width: 18; height: 8; anchors.verticalCenter: parent.verticalCenter
                preferredRendererType: Shape.CurveRenderer
                ShapePath { strokeWidth: 0; fillColor: Qt.rgba(1,1,1,0.22)
                  PathSvg { path: "M9 1 L2 3.5 L3 4.6 L9 3.2 L15 4.6 L16 3.5 Z M9 3.2 L4.5 5.6 L5.5 6.4 L9 5 L12.5 6.4 L13.5 5.6 Z" }
                }
              }
              Text {
                textFormat: Text.PlainText
                text: "ASTON MARTIN"
                color: Qt.rgba(1,1,1,0.28)
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption - 3
                font.letterSpacing: 2.0
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }

          // gauges – one instrument, breathing room
          Row {
            spacing: Style.space(44)
            Layout.alignment: Qt.AlignHCenter
            AmrDial { id: leftDial; label: root.leftLabel; value: root.leftValue; live: root.leftLive }
            AmrDial { id: rightDial; label: root.rightLabel; value: root.rightValue; live: root.rightLive }
          }

          Text {
            textFormat: Text.PlainText
            visible: root.title !== ""
            text: root.title.toUpperCase()
            color: Qt.rgba(1,1,1,0.30)
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption - 2
            font.letterSpacing: 1.4
            Layout.alignment: Qt.AlignHCenter
          }

          // footer – FA14 + subtle Alonso tribute integrated at edge
          RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.space(14)
            Layout.rightMargin: Style.space(14)
            spacing: Style.space(10)
            Text {
              textFormat: Text.PlainText
              text: "FA14"
              color: Qt.rgba(1,1,1,0.34)
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption - 1
              font.letterSpacing: 1.6
              Layout.alignment: Qt.AlignVCenter
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.07); Layout.alignment: Qt.AlignVCenter }
            Text {
              textFormat: Text.PlainText
              text: "Alonso"
              color: Qt.rgba(1,1,1,0.42)
              font.family: root.fontFamily
              font.pixelSize: Style.font.bodySmall
              font.italic: true
              font.letterSpacing: 0.4
              Layout.alignment: Qt.AlignVCenter
              opacity: 0.9
            }
          }

          Button {
            text: "Run Again"
            tooltipText: root.runAgainTooltip
            bordered: true
            enabled: !root.running
            opacity: root.running ? 0 : 1
            foreground: root.onScrim
            fontFamily: root.fontFamily
            fontSize: Style.font.bodySmall
            horizontalPadding: Style.space(14)
            verticalPadding: Style.space(4)
            Layout.alignment: Qt.AlignHCenter
            onClicked: root.runAgainRequested()
            Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
          }
          Text {
            textFormat: Text.PlainText
            visible: root.failed
            text: root.error
            color: root.onScrimUrgent
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            Layout.maximumWidth: Style.space(460)
            horizontalAlignment: Text.AlignHCenter
          }
        }
      }
    }
  }

  component AmrDial: Item {
    id: dial
    required property string label
    required property real value
    required property bool live
    readonly property real diameter: Style.space(214)
    readonly property real dialStart: 135
    readonly property real dialSweep: 270
    readonly property int tickCount: 54
    readonly property real arcWidth: Style.space(1.9)
    readonly property real arcRadius: diameter/2 - arcWidth - Style.space(4)
    readonly property color trackColor: Qt.rgba(1,1,1,0.08)
    readonly property color minorTickColor: Qt.rgba(1,1,1,0.09)
    readonly property color majorTickColor: Qt.rgba(1,1,1,0.22)
    readonly property bool engaged: live || value > 0
    property real shown: 0
    readonly property real reading: ignition.running ? value : shown
    readonly property real fullScale: root.fullScale
    readonly property real fraction: fullScale>0 ? Math.max(0,Math.min(1, shown/fullScale)) : 0
    readonly property bool arcVisible: fraction>0.004
    width: diameter; height: diameter
    opacity: engaged ? 1 : 0.48
    Behavior on opacity { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
    Behavior on shown { enabled: !ignition.running; NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
    onValueChanged: if (!ignition.running) shown = value
    function ignite() { ignition.restart() }
    SequentialAnimation {
      id: ignition
      NumberAnimation { target: dial; property: "shown"; to: dial.fullScale; duration: 520; easing.type: Easing.InOutCubic }
      NumberAnimation { target: dial; property: "shown"; to: 0; duration: 620; easing.type: Easing.OutCubic }
      onFinished: dial.shown = dial.value
    }

    // machined bezel – very thin
    Rectangle {
      anchors.centerIn: parent
      width: dial.diameter - 0.5
      height: dial.diameter - 0.5
      radius: width/2
      color: "transparent"
      border.color: Qt.rgba(1,1,1,0.06)
      border.width: 1
    }
    // inner subtle ring for depth
    Rectangle {
      anchors.centerIn: parent
      width: dial.diameter - Style.space(18)
      height: dial.diameter - Style.space(18)
      radius: width/2
      color: "transparent"
      border.color: Qt.rgba(1,1,1,0.03)
      border.width: 1
    }

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeWidth: dial.arcWidth; strokeColor: dial.trackColor; fillColor: "transparent"; capStyle: ShapePath.RoundCap
        PathAngleArc { centerX: dial.width/2; centerY: dial.height/2; radiusX: dial.arcRadius; radiusY: dial.arcRadius; startAngle: dial.dialStart; sweepAngle: dial.dialSweep }
      }
      ShapePath {
        strokeWidth: dial.arcWidth; strokeColor: dial.arcVisible ? "#0A4A3A" : "transparent"; fillColor: "transparent"; capStyle: ShapePath.RoundCap
        PathAngleArc { centerX: dial.width/2; centerY: dial.height/2; radiusX: dial.arcRadius; radiusY: dial.arcRadius; startAngle: dial.dialStart; sweepAngle: dial.dialSweep*dial.fraction }
      }
      // restrained lime highlight only on leading edge, not full glow
      ShapePath {
        strokeWidth: dial.arcWidth * 0.9; strokeColor: dial.arcVisible && dial.fraction>0.02 ? Qt.rgba(0xB7/255,0xD6/255,0x35/255,0.78) : "transparent"; fillColor: "transparent"; capStyle: ShapePath.RoundCap
        PathAngleArc { centerX: dial.width/2; centerY: dial.height/2; radiusX: dial.arcRadius; radiusY: dial.arcRadius; startAngle: dial.dialStart + dial.dialSweep*dial.fraction - 6; sweepAngle: 6 }
      }
    }

    Repeater {
      model: dial.tickCount
      Item {
        required property int index
        readonly property bool major: index % 9 === 0
        readonly property bool mid: !major && index % 3 === 0
        anchors.fill: parent
        rotation: dial.dialStart + (index/(dial.tickCount-1))*dial.dialSweep - 270
        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          y: dial.arcWidth*2 + Style.space(10) + (parent.major ? 0 : parent.mid ? Style.space(1.5) : Style.space(2.8))
          width: parent.major ? 1.4 : parent.mid ? 0.9 : 0.7
          height: parent.major ? Style.space(10) : parent.mid ? Style.space(6.5) : Style.space(4.2)
          radius: width/2
          color: parent.major ? dial.majorTickColor : parent.mid ? Qt.rgba(1,1,1,0.13) : dial.minorTickColor
        }
      }
    }

    Repeater {
      model: 5
      Item {
        required property int index
        readonly property real f: index/4
        readonly property real v: dial.fullScale * f
        readonly property real ang: dial.dialStart + f*dial.dialSweep
        anchors.fill: parent
        rotation: ang - 270
        Text {
          textFormat: Text.PlainText
          text: Math.round(v).toLocaleString(Qt.locale(),'f',0)
          color: index===2 ? Qt.rgba(1,1,1,0.62) : index===0 || index===4 ? Qt.rgba(1,1,1,0.38) : Qt.rgba(1,1,1,0.44)
          font.family: root.fontFamily
          font.pixelSize: index===2 ? Style.font.bodySmall : Style.font.caption - 1
          font.bold: index===2
          anchors.horizontalCenter: parent.horizontalCenter
          y: dial.arcWidth*2 + Style.space(1.5)
          rotation: -parent.rotation
        }
      }
    }

    Item {
      anchors.fill: parent
      rotation: dial.dialStart + dial.fraction*dial.dialSweep - 270
      Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: dial.arcWidth*2 + Style.space(11)
        width: 1.4; height: dial.diameter*0.32; radius: 0.7
        color: Qt.rgba(0xB7/255,0xD6/255,0x35/255,0.92)
      }
    }
    Rectangle {
      anchors.centerIn: parent
      width: Style.space(7); height: Style.space(7); radius: width/2
      color: "#080C0A"; border.color: Qt.rgba(1,1,1,0.10); border.width: 0.8
      Rectangle { anchors.centerIn: parent; width: 2.2; height: 2.2; radius: 1.1; color: Qt.rgba(0xB7/255,0xD6/255,0x35/255,0.9) }
    }

    // hierarchy: SPEED NUMBER dominant, centered in gauge
    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.verticalCenter
      anchors.topMargin: Style.space(10)
      spacing: 1
      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: dial.reading < 10 ? dial.reading.toLocaleString(Qt.locale(),'f',1) : Math.round(dial.reading).toLocaleString(Qt.locale(),'f',0)
        color: root.onScrim
        font.family: root.fontFamily
        font.pixelSize: Style.font.displayLarge
        font.bold: true
        font.letterSpacing: -0.4
      }
      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.unit
        color: Qt.rgba(1,1,1,0.38)
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption - 1
        font.letterSpacing: 1.2
      }
    }
    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: Style.space(6)
      spacing: 3
      Text {
        textFormat: Text.PlainText
        anchors.horizontalCenter: parent.horizontalCenter
        text: dial.label
        color: Qt.rgba(1,1,1,0.52)
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption - 1
        font.bold: true
        font.letterSpacing: 2.6
      }
      Rectangle { width: Style.space(18); height: 1; color: Qt.rgba(1,1,1,0.08); anchors.horizontalCenter: parent.horizontalCenter }
    }
  }
}

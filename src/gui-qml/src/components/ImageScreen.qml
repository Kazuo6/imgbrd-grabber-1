import Grabber 1.0
import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Page {
    id: root

    signal closed()

    property var images
    property int index
    property var image: images[index]

    property bool showHd: false
    property bool showTags: false

    ShareUtils {
        id: shareUtils
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent

            ToolButton {
                icon.source: "/images/icons/back.png"
                onClicked: root.closed()
            }

            Label {
                text: qsTr("Image") // TODO: add more info about the image
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }

            ToolButton {
                icon.source: showTags ? "/images/icons/image.png" : "/images/icons/tags.png"
                onClicked: showTags = !showTags
            }

            ToolButton {
                icon.source: "/images/icons/share.png"
                onClicked: shareUtils.share("Image", image.fileUrl)
            }

            ToolButton {
                icon.source: "/images/icons/download.png"
                onClicked: backend.downloadImage(image.image)
            }

            ToolButton {
                visible: image.sampleUrl !== image.fileUrl
                icon.source: showHd ? "/images/icons/ld.png" : "/images/icons/hd.png"
                onClicked: showHd = !showHd
            }
        }
    }


    SwipeView {
        id: swipeView
        currentIndex: root.index
        anchors.fill: parent
        clip: true
        onCurrentIndexChanged: { showHd = false; showTags = false }

        Repeater {
            model: root.images

            Loader {
                active: SwipeView.isPreviousItem || SwipeView.isCurrentItem || SwipeView.isNextItem

                sourceComponent: StackLayout {
                    id: stackLayout
                    //anchors.fill: parent
                    clip: true
                    currentIndex: showTags && index == swipeView.currentIndex ? 1 : 0

                    ColumnLayout {
                        ZoomableImage {
                            id: img
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            source: showHd && index == swipeView.currentIndex ? modelData.fileUrl : modelData.sampleUrl
                            clip: true
                        }

                        ProgressBar {
                            value: img.progress
                            visible: img.status != Image.Ready
                            Layout.fillWidth: true
                        }
                    }

                    ScrollView {
                        clip: true
                        padding: 8

                        Text {
                            text: modelData.tags.join("<br/>")
                            textFormat: Text.RichText
                            lineHeight: 1.1

                            onLinkActivated: {
                                root.closed()
                                searchTab.load(link)
                            }
                        }
                    }
                }
            }
        }
    }
}
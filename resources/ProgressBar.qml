import QtQuick 2.4
import QtQuick.Controls 1.4


Item {
    Column {
        ProgressBar {
            value: 0.5
        }
        ProgressBar {
            indeterminate: true
        }
    }
}

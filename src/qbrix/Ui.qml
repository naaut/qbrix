import QtQuick 2.4

QtObject {

    property var dip: dpm(dpimult);

    /*!
     \brief переводит пиксели `px` в проценты относительно высоты документа
     \param type:real
     \return type:real
     */
    property var px2pph: {
        return function(px) {
            if (__rootItem)
                return px / __rootItem.height * 100;
            else
                return px;
        }
    }

    /*!
     * \brief "фабрика" по созданию функций-множителей
     * \param type:real
     * \return type:function
     * \see dip()
     */
    function dpm(dp) {
        return function (pn) {
            return Math.ceil(pn * dp);
        }
    }
}


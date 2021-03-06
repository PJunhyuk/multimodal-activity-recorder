# general
HEADERS += $$PWD/sources/shared/modality/modality.h \
    $$PWD/sources/shared/modality/modalitymmrfile.h \
    $$PWD/sources/shared/modality/modalityconfigurator.h \
    $$PWD/sources/shared/modality/parser/modalityparser.h
SOURCES += $$PWD/sources/shared/modality/modality.cpp \
    $$PWD/sources/shared/modality/modalitymmrfile.cpp \
    $$PWD/sources/shared/modality/modalityconfigurator.cpp \
    $$PWD/sources/shared/modality/parser/modalityparser.cpp


# kinect
contains(MMRModalities, "kinect") {
    HEADERS += $$PWD/sources/shared/modality/modalitykinect.h \
        $$PWD/sources/shared/modality/parser/modalitykinectparser.h
    SOURCES += $$PWD/sources/shared/modality/modalitykinect.cpp \
        $$PWD/sources/shared/modality/parser/modalitykinectparser.cpp

    win32 {
        DEFINES += MMR_MODALITY_KINECT
        INCLUDEPATH += "$$(KINECTSDK20_DIR)\\inc"
    }

    win32:contains(QMAKE_HOST.arch, x86_64) {
        LIBS += -L"$$(KINECTSDK20_DIR)\\Lib\\x64" -lKinect20
    } else:win32 {
        LIBS += -L"$$(KINECTSDK20_DIR)\\Lib\\x86" -lKinect20
    }
}


# Qt sensor
contains(MMRModalities, "qtsensor") {
    QT += sensors

    HEADERS += $$PWD/sources/shared/modality/modalityqtsensor.h \
        $$PWD/sources/shared/modality/parser/modalityqtsensorparser.h
    SOURCES += $$PWD/sources/shared/modality/modalityqtsensor.cpp \
        $$PWD/sources/shared/modality/parser/modalityqtsensorparser.cpp

    DEFINES += MMR_MODALITY_QTSENSOR
}


# BITalino
contains(MMRModalities, "bitalino") {
    HEADERS += $$PWD/sources/shared/modality/modalitybitalino.h \
        $$PWD/sources/shared/modality/parser/modalitybitalinoparser.h
    SOURCES += $$PWD/sources/shared/modality/modalitybitalino.cpp \
        $$PWD/sources/shared/modality/parser/modalitybitalinoparser.cpp

    ios|android|unix|macx {
        QT += bluetooth

        DEFINES += MMR_MODALITY_BITALINO
    }
}


# Fitbit
contains(MMRModalities, "fitbit") {
    HEADERS += $$PWD/sources/shared/modality/modalityfitbit.h \
        $$PWD/sources/shared/modality/parser/modalityfitbitparser.h
    SOURCES += $$PWD/sources/shared/modality/modalityfitbit.cpp \
        $$PWD/sources/shared/modality/parser/modalityfitbitparser.cpp

    DEFINES += MMR_MODALITY_FITBIT
}

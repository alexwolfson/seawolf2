#include "qmlfileaccess.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>

QMLFileAccess::QMLFileAccess(QObject *parent) : QObject(parent)
{
}
QMLFileAccess::~QMLFileAccess(){
    if (!m_qfile.isOpen()){
        m_qfile.close();
    }
}

QMLFileAccess::QMLFileStatus QMLFileAccess::qmlOpenFile(const QString fileName){
    m_fileName = fileName;
    //m_qfile.setFileName(getAccessiblePath("sessions") + m_fileName);
    m_qfile.setFileName(m_fileName);
    m_qfile.open(QIODevice::ReadWrite);
    m_dataStream.setDevice(&m_qfile);
    return static_cast<QMLFileAccess::QMLFileStatus>(m_dataStream.status());
}

QString QMLFileAccess::qmlCloseFile(){
    m_dataStream.unsetDevice();
    m_qfile.close();
   return m_qfile.errorString();
}

QString QMLFileAccess::qmlRead(){

    QString s;
    m_qfile.seek(0);
    m_dataStream >> s;
    return s;
}

QMLFileAccess::QMLFileStatus QMLFileAccess::qmlWrite(const QString s){
    m_qfile.seek(m_qfile.size());
    m_dataStream << s;
    return static_cast<QMLFileAccess::QMLFileStatus>(m_dataStream.status());
}

QString QMLFileAccess::getAccessiblePath(const QString myDir){
    //QString path = QStandardPaths::standardLocations(QStandardPaths::DataLocation).value(0);
    QString path = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + "/" + myDir;
    QDir dir(path);
    if (!dir.exists())
    dir.mkpath(path);
    if (!path.isEmpty() && !path.endsWith("/"))
    path += "/";
    return path;
}

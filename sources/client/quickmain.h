#ifndef QUICKMAIN_H
#define QUICKMAIN_H

#include <QObject>
#include <QVariant>

class MMRClient;
class Modality;

class QuickMain : public QObject
{
    Q_OBJECT
public:
    explicit QuickMain(QObject *parent = nullptr);

    QMap<QString, MMRClient *> clientList;

    Q_INVOKABLE QVariantList getAvailableModalities();

    Q_INVOKABLE QString createClient(QVariantMap modality);
    Q_INVOKABLE void destroyClient(QString identifier);
    MMRClient *getClient(QString identifier);
    Q_INVOKABLE Modality *getClientModality(QString identifier);

    Q_INVOKABLE void clientSetConfiguration(QString identifier, QString key, QVariant value);
    Q_INVOKABLE void clientConnectServer(QString identifier, QString url);
    Q_INVOKABLE void clientDisconnectServer(QString identifier);

signals:

public slots:
};

extern QuickMain *qMain;

#endif // QUICKMAIN_H
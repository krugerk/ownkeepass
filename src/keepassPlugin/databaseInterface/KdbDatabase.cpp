/***************************************************************************
**
** Copyright (C) 2012 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass.  If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include <QtDeclarative/qdeclarative.h>
#include <QDebug>

#include "KdbDatabase.h"
#include "KdbListModel.h"
#include "private/KdbInterface.h"
//#include "private/KdbInterfaceWorker.h"

using namespace std;
using namespace kpxPublic;
using namespace kpxPrivate;

KdbDatabase::KdbDatabase(QObject *parent):
    QObject(parent),
    // set default values
    m_keyTransfRounds(50000),
    m_cryptAlgorithm(0),
    m_showUserNamePasswordsInListView(false)
{
    // connect signals and slots to global KdbInterface class
    Q_ASSERT(connect(this, SIGNAL(preCheckFilePaths(QString,QString)),
                       KdbInterface::getInstance()->getWorker(), SLOT(slot_preCheckFilePaths(QString,QString))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(preCheckFilePathsDone(int)),
                  this, SIGNAL(preCheckDone(int))));
    Q_ASSERT(connect(this, SIGNAL(openDatabase(QString,QString,QString,bool)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_openDatabase(QString,QString,QString,bool))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseOpened(int,QString)),
                  this, SIGNAL(databaseOpened(int,QString))));
    Q_ASSERT(connect(this, SIGNAL(createNewDatabase(QString,QString,QString,int,int)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_createNewDatabase(QString,QString,QString,int,int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(newDatabaseCreated(int,QString)),
                  this, SIGNAL(newDatabaseCreated(int,QString))));
    Q_ASSERT(connect(this, SIGNAL(closeDatabase()),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_closeDatabase())));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseClosed(int,QString)),
                  this, SIGNAL(databaseClosed(int,QString))));
    Q_ASSERT(connect(this, SIGNAL(setting_showUserNamePasswordsInListView(bool)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_setting_showUserNamePasswordsInListView(bool))));
    Q_ASSERT(connect(this, SIGNAL(changeDatabasePassword(QString)),
                  KdbInterface::getInstance()->getWorker(), SLOT(slot_changePassword(QString))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(passwordChanged(int,QString)),
                  this, SIGNAL(databasePasswordChanged(int,QString))));
    Q_ASSERT(connect(this, SIGNAL(changeDatabaseKeyTransfRounds(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_changeKeyTransfRounds(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseKeyTransfRoundsChanged(int)),
                     this, SLOT(slot_databaseKeyTransfRoundsChanged(int))));
    Q_ASSERT(connect(this, SIGNAL(changeDatabaseCryptAlgorithm(int)),
                     KdbInterface::getInstance()->getWorker(), SLOT(slot_changeCryptAlgorithm(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseCryptAlgorithmChanged(int)),
                     this, SLOT(slot_databaseCryptAlgorithmChanged(int))));
    Q_ASSERT(connect(KdbInterface::getInstance()->getWorker(), SIGNAL(databaseErrorOccured(int)),
                     this, SIGNAL(errorOccured(int))));
}

void KdbDatabase::preCheck(const QString& dbFilePath, const QString &keyFilePath)
{
    qDebug() << "KdbDatabase::preCheck()";
    emit preCheckFilePaths(dbFilePath, keyFilePath);
}

void KdbDatabase::open(const QString& dbFilePath, const QString &keyFilePath, const QString& password, bool readonly)
{
    qDebug() << "KdbDatabase::open()";
    // send signal to the global Keepass database interface component
    emit openDatabase(dbFilePath, password, keyFilePath, readonly);
}

void KdbDatabase::create(const QString& dbFilePath, const QString &keyFilePath, const QString& password)
{
    qDebug() << "KdbDatabase::create()";
    // send signal to the global Keepass database interface component
    emit createNewDatabase(dbFilePath, password, keyFilePath, m_cryptAlgorithm, m_keyTransfRounds);
}

void KdbDatabase::close()
{
    emit closeDatabase();
}

void KdbDatabase::changePassword(const QString &password)
{
    emit changeDatabasePassword(password);
}

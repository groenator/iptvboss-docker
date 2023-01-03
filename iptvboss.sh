#!/bin/bash

SOCKET=/tmp/xmltv.sock
set -euo

checkLastCommand() {
     if [ $? -eq 0 ]; then
          echo Jarvis job completed successfuly
     else
          echo Jarvis Job Failed
          exit 1
     fi
 }

removingSocketFile() {
    if [ -S "$SOCKET" ]; then
    echo The socket $SOCKET exists, removing the old socket file
    rm -rf $SOCKET
    sleep 1
    fi
}

creatingSocketFile() {
    if [ ! -S "$SOCKET" ]; then
      echo Creating a new XMLTV socket file
      socat - UNIX-LISTEN:$SOCKET &
    fi

}

#Removing exising socket file
removingSocketFile

#Creating a new socket file
creatingSocketFile

echo Updating JarvisTV EPG
cronitor exec BrEIdc "cd /nfs/software/iptvboss-v3/ && java -jar IPTVBoss.jar -noGui && ls -l &>/dev/null | socat - UNIX-CONNECT:/tmp/xmltv.sock"

#Checking last Command
checkLastCommand

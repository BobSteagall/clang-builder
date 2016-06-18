#!/bin/sh

SSH_ENV="$HOME/.ssh/environment"
SSH_START=""

# Source SSH settings, if they exist

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    SSH_UP=`ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$`

    if [ -z "${SSH_UP}" ]; then
        SSH_START="YES"
    fi
else
    SSH_START="YES"
fi

if [ -n "${SSH_START}" ]; then
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
fi

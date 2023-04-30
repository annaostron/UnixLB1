#!/bin/bash

TOMCAT_SERVER_DIR="/home/annavm/Downloads/tomcat"
WAR_FILE_NAME="/home/annavm/Downloads/mydemo/binary/NewApp.war"
APP_ENDPOINT="/NewApp"
TOMCAT_USERNAME="robot"
TOMCAT_PASSWORD="12345678"
TOMCAT_MANAGER_PORT="8080"
TOMCAT_MANAGER_PROTOCOL="http"
BACKUP_DIR="/home/annavm/Downloads/mydemo/backups"

start_server() {
    echo "Starting server..."
    $TOMCAT_SERVER_DIR/bin/startup.sh
}

stop_server() {
    echo "Stopping server..."
    $TOMCAT_SERVER_DIR/bin/shutdown.sh
}
deploy() {
    echo "Deploying $WAR_FILE_NAME..."
    curl -sS -u $TOMCAT_USERNAME:$TOMCAT_PASSWORD -X PUT "$TOMCAT_MANAGER_PROTOCOL://localhost:$TOMCAT_MANAGER_PORT/manager/text/deploy?path=$APP_ENDPOINT&update=true" --data-binary @$WAR_FILE_NAME
}

undeploy() {
    echo "Undeploying $WAR_FILE_NAME..."
    curl -sS -u $TOMCAT_USERNAME:$TOMCAT_PASSWORD -X GET "$TOMCAT_MANAGER_PROTOCOL://localhost:$TOMCAT_MANAGER_PORT/manager/text/undeploy?path=$APP_ENDPOINT&update=true"
}

create_backup() {
    echo "Backup of $WAR_FILE_NAME created..."
    mkdir -p $BACKUP_DIR
    BACKUP_FILE_NAME="NewApp-$(date +%Y%m%d%H%M%S).war"
    cp $WAR_FILE_NAME $BACKUP_DIR/$BACKUP_FILE_NAME
}

rollback() {
    echo "Previous version of $WAR_FILE_NAME..."
    latest_backup=$(ls -t $BACKUP_DIR | head -1)
    if [ -n "$latest_backup" ]; then
        cp $BACKUP_DIR/$latest_backup $WAR_FILE_NAME
        deploy
    else
        echo "No backups available for $WAR_FILE_NAME."
    fi
}

list_backups() {
    echo "List of backups:"
    ls $BACKUP_DIR
}

delete_backups() {
    echo "Deleting all backups of $WAR_FILE_NAME..."
    read -p "Are you sure? [y/n]: " confirm
    if [ "$confirm" == "y" ]; then
        find $BACKUP_DIR -name "*.war" -type f -delete
        echo "Backups deleted."
    else
        echo "No backups deleted."
    fi
}

get_status() {
    echo "Status of $APP_ENDPOINT..."
    curl -sS -u $TOMCAT_USERNAME:$TOMCAT_PASSWORD "$TOMCAT_MANAGER_PROTOCOL://localhost:$TOMCAT_MANAGER_PORT/manager/text/list" | grep $APP_ENDPOINT
}
help() {
    echo "Help: $0  [-s] [-t] [-d] [-u] [-n] [-b] [-r] [-x] [-l]"
    echo "  -s: Start the Tomcat server"
    echo "  -t: Stop the Tomcat server"
    echo "  -d: Deploy the application"
    echo "  -u: Undeploy the application"
    echo "  -n: Displays the status of the deployed application"
    echo "  -b: Creates a backup copy of the application"
    echo "  -r: Restores a previously created app backup"
    echo "  -x: Delete all backups"
    echo "  -l: List of backups"

}


while getopts ":dustbrnhxl:c:" opt; do
    case $opt in
        s)start_server;;
        t)stop_server;;
        d)deploy;;
        u)undeploy;;
        b)create_backup;;
        r)rollback;;
        n)get_status;;
        x)delete_backups "$OPTARG";;
        l)list_backups "$OPTARG";;
        h)help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            help
            exit 1
            ;;
    esac
done
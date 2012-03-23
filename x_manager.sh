#!/bin/bash
initialize_blank_project()
{
    echo "?Application name:"
    read app_name
    echo "?Application module name:"
    read app_module_name
    app_path="${PWD}/${app_name}"
    app_module_path="${app_path}/${app_module_name}"
    echo "App path=>${app_path"
    echo "App module path=>${app_module_path}"

    ## Initialize Django-Heroku project
    mkdir ${app_path} && cd ${app_path}
    virtualenv .ve --distribute
    source .ve/bin/activate
    pip install Django psycopg2
    #django-admin.py startproject ${app_module_name}
    chmod +x ${app_module_path}/manage.py

    # pip freeze -r xplusz-requirements.txt > requirements.txt
    echo "Initializing requirements.txt ........"
    pip freeze -r ${lib_path}/ini_data/requirements_basic.txt > requirements.txt

    ## For github
    echo "Initializing README.md"
    touch README.md

    django-admin.py startproject ${app_module_name}
}

echo "=======Welcome to Xplusz Manager bash======="
lib_path="${PWD}/`dirname $0`"
echo "Work path===>${PWD}"
echo "SDK path==>${lib_path}"
echo "==========Please make a choice========"
echo "1: Initialize blank Django-Heroku project?"
read type
case $type in
1)
    echo "Start initializing==========>"
    initialize_blank_project;;
*)
    echo "Error chose!";;
esac
exit 0

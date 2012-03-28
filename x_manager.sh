#!/bin/bash
initialize_folders()
{
    mkdir ${project_name}/${app_name}/views

}


initialize_files()
{
    # pip freeze -r xplusz-requirements.txt > requirements.txt
    echo "==>Initializing requirements.txt ........"
    pip freeze > dev_requirements.txt
    cp ${lib_path}/ini_data/requirements_basic.txt ${workspace_path}/requirements.txt

    # README
    echo "==>Initializing README.md"
    touch README.md

    # Procfile
    echo "==>Initializing Procfile"
    touch Procfile
    echo "web: python ${project_name}/manage.py run_gunicorn -b \"0.0.0.0:\$PORT\" -w 3" >> Procfile

    # DB config
    cp ${lib_path}/ini_data/pgurl.py ${project_path}/pgurl.py
    sed -ie "s/app_name/${project_name}/g" ${project_path}/pgurl.py

    # Enhance setting.py
    ## Module
    sed -ie '/INSTALLED_APPS/ a\
    \    "gunicorn",\
    \    "south",
    ' ${project_name}/settings.py
    line=`sed -n '/INSTALLED_APPS/=' ${project_name}/settings.py`
    let "start=$line+2"
    sed -ie "$start a\\
        \    \"${app_name}\",
        " ${project_name}/settings.py
    ## DB config
    line=`sed -n '/DATABASES/=' ${project_name}/settings.py`
    let "start=$line+1"
    let "end=$line+9"
    sed -ie "${start},${end}d" ${project_name}/settings.py
    sed -ie "s/.*DATABASES.*/DATABASES = pgurl.get_db_settings()/g" ${project_name}/settings.py
    sed -ie '1 i\
    \import pgurl, os
    ' ${project_name}/settings.py
    ## Debug module
    sed -ie 's/DEBUG = True/ \
\PROJECT_DIR = os.getcwd() \
\DEBUG = os.environ.get("DEBUG_MODE", "true") == "true" \
    /g' ${project_name}/settings.py
    ## TimeZone
    sed -ie 's/America.Chicago/UTC/g' ${project_name}/settings.py
    ## Template
    line=`sed -n '/TEMPLATE_DIRS/=' ${project_name}/settings.py`
    let "start=$line+3"
    view_dir="PROJECT_DIR + \"/${project_name}/${app_name}/views\""
    sed -ie "$start a\\
    \    ${view_dir}
    " ${project_name}/settings.py


    # Remove unused files
    rm ${project_path}/*.pyc
    rm ${project_path}/*.pye
    rm ${workspace_path}/*.pyc
    rm ${workspace_path}/*.pye

    # Local setup script
    echo "==>Locale environment setup"
    cp ${lib_path}/ini_data/.gitignore ${workspace_path}/.gitignore
    cp ${lib_path}/ini_data/setup.sh ${workspace_path}/setup.sh
}

initialize_blank_project()
{
    echo "?Workspace name:"
    read workspace_name
    echo "?Project name:"
    read project_name
    echo "?App name:"
    read app_name
    workspace_path="${PWD}/${workspace_name}"
    project_path="${workspace_path}/${project_name}"
    app_path="${project_path}/${app_name}"
    echo "Workspace path=>${workspace_path}"
    echo "Project path=>${project_path}"

    ## Initialize Django-Heroku project
    if [ -d ${workspace_path} ]; then
        cd ${workspace_path}
    else
        mkdir ${workspace_path} && cd ${workspace_path}
    fi
    if [ ! -e .ve ]; then
        virtualenv .ve --distribute
    fi
    source .ve/bin/activate
    pip install Django==1.3.1 psycopg2
    django-admin.py startproject ${project_name}
    chmod +x ${project_path}/manage.py
    ${project_name}/manage.py startapp ${app_name}

    # Initialize folders
    initialize_folders

    # Initialize files
    initialize_files


    # Execute Local setup
    #./setup.sh
}

echo "=======Welcome to Xplusz Manager bash======="
lib_path="${PWD}/`dirname $0`"
echo "Current path===>${PWD}"
echo "Kit path==>${lib_path}"
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

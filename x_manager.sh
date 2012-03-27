#!/bin/bash
initialize_files()
{
    # pip freeze -r xplusz-requirements.txt > requirements.txt
    echo "==>Initializing requirements.txt ........"
    pip freeze > dev_requirements.txt
    cp ${lib_path}/ini_data/requirements_basic.txt ${app_path}/requirements.txt

    # README
    echo "==>Initializing README.md"
    touch README.md

    # Procfile
    echo "==>Initializing Procfile"
    touch Procfile
    echo "web: python ${app_module_name}/manage.py run_gunicorn -b \"0.0.0.0:\$PORT\" -w 3" >> Procfile

    # DB config
    cp ${lib_path}/ini_data/pgurl.py ${app_module_path}/pgurl.py
    sed -ie "s/app_name/${app_name}/g" ${app_module_path}/pgurl.py

    # Enhance setting.py
    ## Module
    sed '/INSTALLED_APPS/ a\
    \    "gunicorn",
    ' ${app_module_name}/settings.py >> ${app_module_name}/settings_tmp.py
    rm ${app_module_name}/settings.py
    mv ${app_module_name}/settings_tmp.py ${app_module_name}/settings.py
    #cp ${lib_path}/ini_data/settings.py ${app_module_path}/settings.py
    ## DB config
    #sed -ie "s/DATABASES = {\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n}/DATABASES = pgurl.get_db_settings()/g" ${app_module_path}/settings.py

    rm ${app_module_path}/*.pye

    # Local setup script
    echo "==>Locale environment setup"
    cp ${lib_path}/ini_data/setup.sh ${app_path}/setup.sh
}

initialize_blank_project()
{
    echo "?Application name:"
    read app_name
    echo "?Application module name:"
    read app_module_name
    app_path="${PWD}/${app_name}"
    app_module_path="${app_path}/${app_module_name}"
    echo "App path=>${app_path}"
    echo "App module path=>${app_module_path}"

    ## Initialize Django-Heroku project
    if [ -d ${app_path} ]; then
        cd ${app_path}
    else
        mkdir ${app_path} && cd ${app_path}
    fi
    if [ ! -e .ve ]; then
        virtualenv .ve --distribute
    fi
    source .ve/bin/activate
    pip install Django==1.3.1 psycopg2
    django-admin.py startproject ${app_module_name}
    chmod +x ${app_module_path}/manage.py

    # Initialize files
    initialize_files

    # Execute Local setup
    #./setup.sh
}

echo "=======Welcome to Xplusz Manager bash======="
lib_path="${PWD}/`dirname $0`"
echo "Work path===>${PWD}"
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
